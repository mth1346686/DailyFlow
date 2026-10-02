import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine_task.dart';

class StorageService {
  static const String _tasksKey = 'daily_flow_tasks_v3';
  static const String _categoriesKey = 'daily_flow_categories_v3';
  static const String _perfectDatesKey = 'daily_flow_perfect_dates_v3';
  static const String _firstCreatedDateKey = 'daily_flow_first_created_v3';

  /// Save tasks to local storage
  Future<void> saveTasks(List<RoutineTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_tasksKey, jsonList);
  }

  /// Load tasks from local storage (default is EMPTY array [])
  Future<List<RoutineTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_tasksKey);

    if (jsonList == null || jsonList.isEmpty) {
      return []; // Start completely empty as requested!
    }

    try {
      return jsonList.map((item) => RoutineTask.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save categories to local storage
  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey, categories);
  }

  /// Load categories from local storage (default ONLY ['All'])
  Future<List<String>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_categoriesKey);
    if (list == null || list.isEmpty) {
      return ['All']; // Keep ONLY 'All' as default!
    }
    if (!list.contains('All')) {
      list.insert(0, 'All');
    }
    return list;
  }

  /// Save perfect completed dates set
  Future<void> savePerfectDates(List<String> dates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_perfectDatesKey, dates);
  }

  /// Load perfect completed dates
  Future<List<String>> loadPerfectDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_perfectDatesKey) ?? [];
  }

  /// Save first task created date
  Future<void> saveFirstCreatedDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_firstCreatedDateKey)) {
      await prefs.setString(_firstCreatedDateKey, date);
    }
  }

  /// Reset first created date
  Future<void> resetFirstCreatedDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstCreatedDateKey);
  }

  /// Load first task created date
  Future<String?> loadFirstCreatedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_firstCreatedDateKey);
  }
}
