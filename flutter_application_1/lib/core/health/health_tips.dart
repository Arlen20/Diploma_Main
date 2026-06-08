/// Rotating health tips. A new one is shown each day (stable per calendar day).
class HealthTips {
  static const _tips = [
    'Aim for a protein source in every meal to stay full longer.',
    'Drink a glass of water before each meal to help portion control.',
    'A 10-minute walk after eating helps regulate blood sugar.',
    'Sleep 7–9 hours — recovery is when muscle is built.',
    'Fill half your plate with vegetables for more fiber and fewer calories.',
    'Log your meals right after eating so nothing gets forgotten.',
    'Strength training 3x a week preserves muscle while losing fat.',
    'Swap sugary drinks for water or tea to cut hidden calories.',
    'Eat slowly — it takes ~20 minutes to feel full.',
    'Consistency beats perfection. One off day won’t undo your progress.',
  ];

  static String today() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return _tips[dayOfYear % _tips.length];
  }
}
