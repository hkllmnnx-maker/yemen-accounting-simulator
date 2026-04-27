/// تقدم المستخدم - يخزن في SharedPreferences كـ JSON
class UserProgress {
  Set<String> completedLessons;
  Set<String> completedTrainings;
  Map<String, int> quizScores; // أعلى درجة لكل اختبار (نسبة 0-100)
  Set<String> earnedBadges;
  int totalXp;

  UserProgress({
    Set<String>? completedLessons,
    Set<String>? completedTrainings,
    Map<String, int>? quizScores,
    Set<String>? earnedBadges,
    this.totalXp = 0,
  })  : completedLessons = completedLessons ?? {},
        completedTrainings = completedTrainings ?? {},
        quizScores = quizScores ?? {},
        earnedBadges = earnedBadges ?? {};

  Map<String, dynamic> toMap() => {
        'completedLessons': completedLessons.toList(),
        'completedTrainings': completedTrainings.toList(),
        'quizScores': quizScores,
        'earnedBadges': earnedBadges.toList(),
        'totalXp': totalXp,
      };

  factory UserProgress.fromMap(Map<String, dynamic> m) => UserProgress(
        completedLessons: ((m['completedLessons'] as List?) ?? [])
            .map((e) => e.toString())
            .toSet(),
        completedTrainings: ((m['completedTrainings'] as List?) ?? [])
            .map((e) => e.toString())
            .toSet(),
        quizScores: (m['quizScores'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ??
            {},
        earnedBadges: ((m['earnedBadges'] as List?) ?? [])
            .map((e) => e.toString())
            .toSet(),
        totalXp: m['totalXp'] as int? ?? 0,
      );
}
