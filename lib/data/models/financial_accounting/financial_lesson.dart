// نماذج محتوى قسم "المحاسبة المالية من القيد إلى التحليل المالي".
// تُستخدم هذه النماذج لتعريف المستويات (Levels) داخل القسم،
// وما يصاحبها من شرح وأمثلة محلولة وتلميحات واختبارات.

/// مستوى تعليمي داخل قسم المحاسبة المالية.
class FinancialLesson {
  /// معرّف فريد للمستوى (يُستخدم لحفظ التقدّم).
  final String id;

  /// رقم المستوى التسلسلي (1..14).
  final int order;

  /// عنوان المستوى.
  final String title;

  /// عنوان فرعي يوصف باختصار محتوى المستوى.
  final String subtitle;

  /// ملخص قصير قبل المحتوى الكامل.
  final String summary;

  /// فقرات الشرح المطوّل.
  final List<String> sections;

  /// أمثلة محلولة (نص جاهز يُعرض كما هو، يحوي القيود والأرقام).
  final List<String> solvedExamples;

  /// أخطاء شائعة على المتدرّب الانتباه لها.
  final List<String> commonMistakes;

  /// تلميحات مفيدة قبل أو خلال الحل.
  final List<String> tips;

  /// ملخص ختامي يُعرض في نهاية المستوى.
  final String wrapUp;

  /// قائمة معرّفات التمارين المرتبطة بهذا المستوى
  /// (تطابق `FinancialExercise.id` في seed التمارين).
  final List<String> exerciseIds;

  /// شارة تُمنح عند إتمام جميع تمارين المستوى (اختيارية).
  final String? badgeId;

  /// نقاط XP تُمنح عند إنهاء المستوى لأول مرة.
  final int xpReward;

  const FinancialLesson({
    required this.id,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.sections,
    required this.solvedExamples,
    required this.commonMistakes,
    required this.tips,
    required this.wrapUp,
    required this.exerciseIds,
    this.badgeId,
    this.xpReward = 10,
  });
}
