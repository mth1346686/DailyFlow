import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/routine_task.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<RoutineTask> _tasks = [];
  List<String> _categories = ['All'];
  Set<String> _perfectDates = {};
  String? _firstCreatedDate;
  
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _lastCheckedToday = RoutineTask.todayString;

  Timer? _autoRefreshTimer;

  List<RoutineTask> get tasks => _tasks;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  TaskProvider() {
    init();
    _startAutoRefreshTimer();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// Start a 10-second periodic timer to auto-refresh tasks at midnight live
  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final currentToday = RoutineTask.todayString;
      if (currentToday != _lastCheckedToday) {
        _lastCheckedToday = currentToday;
        // Midnight transition detected! Notify listeners so uncompleted checkmarks update live
        notifyListeners();
      }
    });
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _storageService.loadTasks();
    _categories = await _storageService.loadCategories();
    final perfectList = await _storageService.loadPerfectDates();
    _perfectDates = Set.from(perfectList);
    _firstCreatedDate = await _storageService.loadFirstCreatedDate();

    _lastCheckedToday = RoutineTask.todayString;
    _isLoading = false;
    notifyListeners();
  }

  /// Total number of routines
  int get totalCount => _tasks.length;

  /// Number of routines completed today
  int get completedCount =>
      _tasks.where((t) => t.isCompletedToday).length;

  /// Check if ALL routines are completed today
  bool get isAllCompletedToday =>
      totalCount > 0 && completedCount == totalCount;

  /// Daily completion percentage ratio (0.0 to 1.0)
  double get completionRatio =>
      totalCount == 0 ? 0.0 : completedCount / totalCount;

  /// Days count since building the first task (resets to 1 if all tasks deleted)
  int get daysSinceFirstTask {
    if (_tasks.isEmpty || _firstCreatedDate == null) return 1;
    try {
      final firstDate = DateTime.parse(_firstCreatedDate!);
      final today = DateTime.parse(RoutineTask.todayString);
      final difference = today.difference(firstDate).inDays + 1;
      return difference < 1 ? 1 : difference;
    } catch (e) {
      return 1;
    }
  }

  /// Total number of 100% perfect completed days
  int get perfectDaysCount => _perfectDates.length;

  /// Filtered tasks based on category and search string
  List<RoutineTask> get filteredTasks {
    return _tasks.where((task) {
      final matchesCategory =
          _selectedCategory == 'All' || task.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Add a new custom category
  Future<void> addCategory(String categoryName) async {
    final trimmed = categoryName.trim();
    if (trimmed.isEmpty || _categories.contains(trimmed)) return;

    _categories.add(trimmed);
    notifyListeners();
    await _storageService.saveCategories(_categories);
  }

  /// Delete a custom category
  Future<void> deleteCategory(String categoryName) async {
    if (categoryName == 'All') return;

    _categories.remove(categoryName);
    if (_selectedCategory == categoryName) {
      _selectedCategory = 'All';
    }

    // Reassign tasks under deleted category to General
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].category == categoryName) {
        _tasks[i] = _tasks[i].copyWith(category: 'General');
      }
    }

    notifyListeners();
    await _storageService.saveCategories(_categories);
    await _storageService.saveTasks(_tasks);
  }

  /// Toggle task completion for today
  Future<void> toggleTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final currentTask = _tasks[index];
    final today = RoutineTask.todayString;
    final wasDoneBefore = currentTask.isCompletedToday;

    RoutineTask updatedTask;

    if (wasDoneBefore) {
      // Undo completion
      final newStreak = (currentTask.streak > 0) ? currentTask.streak - 1 : 0;
      updatedTask = currentTask.copyWith(
        clearLastCompletedDate: true,
        streak: newStreak,
      );
      // Remove from perfect dates if it was marked today
      _perfectDates.remove(today);
    } else {
      // Mark complete
      int newStreak = 1;
      if (currentTask.lastCompletedDate == RoutineTask.yesterdayString) {
        newStreak = currentTask.streak + 1;
      } else if (currentTask.effectiveStreak > 0) {
        newStreak = currentTask.effectiveStreak + 1;
      }

      updatedTask = currentTask.copyWith(
        lastCompletedDate: today,
        streak: newStreak,
      );
    }

    _tasks[index] = updatedTask;

    // Audio Feedback & Perfect Day Logic
    if (!wasDoneBefore) {
      // Check if this action completed ALL tasks today
      if (isAllCompletedToday) {
        _perfectDates.add(today);
        AudioService.playAllTasksDoneSound(); // 🥳 All completed fanfare sound!
      } else {
        AudioService.playTaskDoneSound(); // 🔔 Single task chime!
      }
    }

    notifyListeners();
    await _storageService.saveTasks(_tasks);
    await _storageService.savePerfectDates(_perfectDates.toList());
  }

  /// Add a new routine task
  Future<void> addTask({
    required String title,
    required String category,
    required String icon,
  }) async {
    final today = RoutineTask.todayString;

    if (_tasks.isEmpty || _firstCreatedDate == null) {
      _firstCreatedDate = today;
      await _storageService.saveFirstCreatedDate(today);
    }

    final newTask = RoutineTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      category: category,
      icon: icon,
      lastCompletedDate: null,
      streak: 0,
      createdAt: today,
    );

    _tasks.insert(0, newTask);
    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  /// Edit/Update an existing task
  Future<void> updateTask({
    required String id,
    required String title,
    required String category,
    required String icon,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      title: title.trim(),
      category: category,
      icon: icon,
    );

    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  /// Delete a task by ID
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);

    if (_tasks.isEmpty) {
      // Reset start date if all tasks are wiped out!
      _firstCreatedDate = null;
      await _storageService.resetFirstCreatedDate();
    }

    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  /// Undo deletion
  Future<void> reinsertTask(RoutineTask task, int index) async {
    final today = RoutineTask.todayString;
    if (_firstCreatedDate == null) {
      _firstCreatedDate = today;
      await _storageService.saveFirstCreatedDate(today);
    }

    if (index >= 0 && index <= _tasks.length) {
      _tasks.insert(index, task);
    } else {
      _tasks.add(task);
    }
    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  /// Reset all tasks to unchecked for today
  Future<void> resetAllForTesting() async {
    _tasks = _tasks.map((t) => t.copyWith(clearLastCompletedDate: true)).toList();
    _perfectDates.remove(RoutineTask.todayString);
    notifyListeners();
    await _storageService.saveTasks(_tasks);
    await _storageService.savePerfectDates(_perfectDates.toList());
  }
}
