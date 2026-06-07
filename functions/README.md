# Meal Analysis Function

This Firebase Function exposes `analyzeMeal`.

It accepts:

```json
{
  "imageBase64": "...",
  "mimeType": "image/jpeg"
}
```

It returns:

```json
{
  "title": "Estimated meal",
  "calories": 540,
  "protein": 28,
  "carbs": 62,
  "fat": 18
}
```

Set the Gemini API key before deploying:

```bash
firebase functions:secrets:set GEMINI_API_KEY
```

For local emulator testing, create `functions/.env`:

```bash
GEMINI_API_KEY=your_key_here
GEMINI_MODEL=gemini-2.5-flash
```

Run the full app locally from the project root:

```bash
start_local_meal_tracker.cmd
```

This starts the Firebase Functions emulator on `127.0.0.1:5001` and then
starts Flutter Web in Chrome.

You can also use VS Code Run and Debug:

```text
flutter_application_1 + Meal Emulator
```

Manual local backend run:

```bash
cd functions
npm install
npm run serve
```
