import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _usersKey = 'users';
  static const String _groupsKey = 'groups';
  static const String _tasksKey = 'tasks';
  static const String _completionsKey = 'completions';
  static const String _currentUserKey = 'currentUser';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Methods
  Future<void> saveUser(UserModel user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  Future<List<UserModel>> getUsers() async {
    final data = _prefs.getString(_usersKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<UserModel?> getUserById(String id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> setCurrentUser(UserModel? user) async {
    if (user == null) {
      await _prefs.remove(_currentUserKey);
    } else {
      await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final data = _prefs.getString(_currentUserKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  // Group Methods
  Future<void> saveGroup(GroupModel group) async {
    final groups = await getGroups();
    final index = groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      groups[index] = group;
    } else {
      groups.add(group);
    }
    await _prefs.setString(
      _groupsKey,
      jsonEncode(groups.map((g) => g.toJson()).toList()),
    );
  }

  Future<List<GroupModel>> getGroups() async {
    final data = _prefs.getString(_groupsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GroupModel?> getGroupById(String id) async {
    final groups = await getGroups();
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<GroupModel?> getGroupByCode(String code) async {
    final groups = await getGroups();
    try {
      return groups.firstWhere((g) => g.code.toUpperCase() == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  // Task Methods
  Future<void> saveTask(TaskModel task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<List<TaskModel>> getTasks() async {
    final data = _prefs.getString(_tasksKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TaskModel>> getTasksByGroup(String groupId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.groupId == groupId && t.isActive).toList();
  }

  // Task Completion Methods
  Future<void> saveCompletion(TaskCompletionModel completion) async {
    final completions = await getCompletions();
    completions.add(completion);
    await _prefs.setString(
      _completionsKey,
      jsonEncode(completions.map((c) => c.toJson()).toList()),
    );
  }

  Future<List<TaskCompletionModel>> getCompletions() async {
    final data = _prefs.getString(_completionsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => TaskCompletionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TaskCompletionModel>> getCompletionsByGroup(String groupId) async {
    final completions = await getCompletions();
    return completions.where((c) => c.groupId == groupId).toList();
  }

  Future<List<TaskCompletionModel>> getWeeklyCompletions(String groupId) async {
    final completions = await getCompletionsByGroup(groupId);
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return completions.where((c) => c.completedAt.isAfter(weekStart)).toList();
  }

  Future<void> resetWeeklyPoints(String groupId) async {
    final users = await getUsers();
    for (var user in users) {
      if (user.groupId == groupId) {
        await saveUser(user.copyWith(weeklyPoints: 0));
      }
    }
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
