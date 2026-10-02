import 'dart:convert';

class RoutineTask {
  final String id;
  final String title;
  final String category;
  final String icon;
  final String? lastCompletedDate; // yyyy-MM-dd
  final int streak;
  final String createdAt;

  RoutineTask({
    required this.id,
    required this.title,
    this.category = 'General',
    this.icon = '⭐',
    this.lastCompletedDate,
    this.streak = 0,
    required this.createdAt,
  });

  /// Helper to get today's formatted date string (yyyy-MM-dd)
  static String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String get todayString => formatDate(DateTime.now());

  static String get yesterdayString =>
      formatDate(DateTime.now().subtract(const Duration(days: 1)));

  /// Checks if task was completed today
  bool get isCompletedToday => lastCompletedDate == todayString;

  /// Effective streak: resets to 0 if missed yesterday & today
  int get effectiveStreak {
    if (lastCompletedDate == null) return 0;
    if (lastCompletedDate == todayString || lastCompletedDate == yesterdayString) {
      return streak;
    }
    // Skipped more than 1 day
    return 0;
  }

  /// Create a copy with modified fields
  RoutineTask copyWith({
    String? id,
    String? title,
    String? category,
    String? icon,
    String? lastCompletedDate,
    bool clearLastCompletedDate = false,
    int? streak,
    String? createdAt,
  }) {
    return RoutineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      lastCompletedDate: clearLastCompletedDate
          ? null
          : (lastCompletedDate ?? this.lastCompletedDate),
      streak: streak ?? this.streak,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert object to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'icon': icon,
      'lastCompletedDate': lastCompletedDate,
      'streak': streak,
      'createdAt': createdAt,
    };
  }

  /// Factory from JSON map
  factory RoutineTask.fromMap(Map<String, dynamic> map) {
    return RoutineTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'General',
      icon: map['icon'] ?? '⭐',
      lastCompletedDate: map['lastCompletedDate'],
      streak: map['streak'] ?? 0,
      createdAt: map['createdAt'] ?? todayString,
    );
  }

  String toJson() => json.encode(toMap());

  factory RoutineTask.fromJson(String source) =>
      RoutineTask.fromMap(json.decode(source));
}
