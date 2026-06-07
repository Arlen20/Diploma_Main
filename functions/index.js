const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const GEMINI_GENERATE_CONTENT_BASE_URL =
  "https://generativelanguage.googleapis.com/v1beta/models";
const DEFAULT_MODEL = "gemini-2.5-flash";

exports.analyzeMeal = onRequest(
  {
    cors: true,
    secrets: ["GEMINI_API_KEY"],
    timeoutSeconds: 60,
    maxInstances: 10,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      res.status(500).json({ error: "GEMINI_API_KEY is not configured" });
      return;
    }

    const imageBase64 = req.body && req.body.imageBase64;
    const mimeType = (req.body && req.body.mimeType) || "image/jpeg";

    if (!imageBase64 || typeof imageBase64 !== "string") {
      res.status(400).json({ error: "imageBase64 is required" });
      return;
    }

    try {
      const nutrition = await analyzeMealWithGemini({
        apiKey,
        imageBase64,
        mimeType,
      });

      res.status(200).json(nutrition);
    } catch (error) {
      logger.error("Meal analysis failed", error);
      res.status(500).json({
        error: error && error.message ? error.message : "Meal analysis failed",
      });
    }
  },
);

async function analyzeMealWithGemini({ apiKey, imageBase64, mimeType }) {
  const model = process.env.GEMINI_MODEL || DEFAULT_MODEL;
  const url = `${GEMINI_GENERATE_CONTENT_BASE_URL}/${model}:generateContent`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "x-goog-api-key": apiKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      contents: [
        {
          parts: [
            {
              inline_data: {
                mime_type: mimeType,
                data: imageBase64,
              },
            },
            { text: buildNutritionPrompt() },
          ],
        },
      ],
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error && data.error.message ? data.error.message : "Gemini request failed");
  }

  const outputText = extractOutputText(data);
  const parsed = parseJsonObject(outputText);

  return normalizeNutrition(parsed);
}

function buildNutritionPrompt() {
  return (
    "Analyze this meal photo. Estimate nutrition for the visible portion. " +
    "Return only valid JSON with this exact shape: " +
    '{"title":"Meal name","calories":0,"protein":0,"carbs":0,"fat":0}. ' +
    "Use integer grams for protein, carbs, and fat. Use integer kcal. " +
    "Do not include markdown, comments, or extra text."
  );
}

function extractOutputText(data) {
  const parts = [];
  for (const candidate of data.candidates || []) {
    for (const part of (candidate.content && candidate.content.parts) || []) {
      if (typeof part.text === "string") {
        parts.push(part.text);
      }
    }
  }

  return parts.join("\n");
}

function parseJsonObject(text) {
  const trimmed = String(text || "").trim();
  const withoutFence = trimmed
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/\s*```$/i, "");
  const start = withoutFence.indexOf("{");
  const end = withoutFence.lastIndexOf("}");

  if (start === -1 || end === -1 || end <= start) {
    throw new Error("Gemini did not return JSON");
  }

  return JSON.parse(withoutFence.slice(start, end + 1));
}

function normalizeNutrition(value) {
  const title = typeof value.title === "string" && value.title.trim()
    ? value.title.trim()
    : "Estimated meal";

  return {
    title,
    calories: toNonNegativeInt(value.calories),
    protein: toNonNegativeInt(value.protein),
    carbs: toNonNegativeInt(value.carbs),
    fat: toNonNegativeInt(value.fat),
  };
}

function toNonNegativeInt(value) {
  const number = Number(value);
  if (!Number.isFinite(number) || number < 0) {
    return 0;
  }
  return Math.round(number);
}
