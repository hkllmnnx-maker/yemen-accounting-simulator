import 'package:flutter/foundation.dart';
import '../data/models/progress.dart';
import '../data/repositories/database_service.dart';
import '../data/seed/lessons_content.dart';
import '../data/seed/trainings_content.dart';

/// مزوّد إدارة تقدم المستخدم والإنجازات
class ProgressProvider extends ChangeNotifier {
  UserProgress _progress = UserProgress();
  UserProgress get progress => _progress;

  Future<void> load() async {
    _progress = DatabaseService.getProgress();
    notifyListeners();
  }

  Future<void> _save() async {
    await DatabaseService.saveProgress(_progress);
    notifyListeners();
  }

  // ====== Lessons ======
  bool isLessonCompleted(String id) => _progress.completedLessons.contains(id);

  Future<void> completeLesson(String id) async {
    if (_progress.completedLessons.add(id)) {
      _progress.totalXp += 5;
    }
    await _save();
  }

  // ====== Quizzes ======
  int quizScore(String lessonId) => _progress.quizScores[lessonId] ?? 0;

  Future<void> setQuizScore(String lessonId, int percent) async {
    final prev = _progress.quizScores[lessonId] ?? 0;
    if (percent > prev) {
      _progress.quizScores[lessonId] = percent;
      _progress.totalXp += (percent / 10).round();
    }
    await _save();
  }

  bool isQuizPassed(String lessonId) => quizScore(lessonId) >= 70;

  // ====== Trainings ======
  bool isTrainingCompleted(String id) =>
      _progress.completedTrainings.contains(id);

  Future<void> completeTraining(String id, int xp) async {
    if (_progress.completedTrainings.add(id)) {
      _progress.totalXp += xp;
    }
    await _save();
  }

  // ====== Badges ======
  bool hasBadge(String id) => _progress.earnedBadges.contains(id);

  Future<void> awardBadge(String id) async {
    if (_progress.earnedBadges.add(id)) {
      _progress.totalXp += 20;
      await _save();
    }
  }

  // ====== Stats ======
  int get totalLessons => appLessons.length;
  int get completedLessons => _progress.completedLessons.length;

  int get totalTrainings => appTrainings.length;
  int get completedTrainings => _progress.completedTrainings.length;

  int get totalQuizzes => appLessons.length;
  int get passedQuizzes =>
      _progress.quizScores.values.where((v) => v >= 70).length;

  double get overallProgress {
    final total = totalLessons + totalTrainings + totalQuizzes;
    if (total == 0) return 0;
    final done = completedLessons + completedTrainings + passedQuizzes;
    return done / total;
  }

  Future<void> resetProgress() async {
    _progress = UserProgress();
    await _save();
  }
}
