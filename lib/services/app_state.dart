import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  
  UserModel? _currentUser;
  GroupModel? _currentGroup;
  List<TaskModel> _tasks = [];
  List<TaskCompletionModel> _completions = [];
  List<UserModel> _groupMembers = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  GroupModel? get currentGroup => _currentGroup;
  List<TaskModel> get tasks => _tasks;
  List<TaskCompletionModel> get completions => _completions;
  List<UserModel> get groupMembers => _groupMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> init() async {
    await _storage.init();
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _storage.getCurrentUser();
    if (_currentUser != null && _currentUser!.groupId != null) {
      await loadGroupData(_currentUser!.groupId!);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Authentication
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final existingUser = await _storage.getUserByEmail(email);
      if (existingUser != null) {
        _error = 'Email já cadastrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = UserModel(
        id: _generateId(),
        name: name,
        email: email,
      );

      await _storage.saveUser(user);
      await _storage.setCurrentUser(user);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao criar conta';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _storage.getUserByEmail(email);
      if (user == null) {
        _error = 'Usuário não encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _storage.setCurrentUser(user);
      _currentUser = user;

      if (user.groupId != null) {
        await loadGroupData(user.groupId!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao fazer login';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.setCurrentUser(null);
    _currentUser = null;
    _currentGroup = null;
    _tasks = [];
    _completions = [];
    _groupMembers = [];
    notifyListeners();
  }

  // Group Management
  Future<bool> createGroup(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final code = _generateGroupCode();
      final group = GroupModel(
        id: _generateId(),
        name: name,
        code: code,
        adminId: _currentUser!.id,
        memberIds: [_currentUser!.id],
      );

      await _storage.saveGroup(group);

      final updatedUser = _currentUser!.copyWith(
        groupId: group.id,
        isAdmin: true,
      );
      await _storage.saveUser(updatedUser);
      await _storage.setCurrentUser(updatedUser);
      _currentUser = updatedUser;

      await loadGroupData(group.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao criar grupo';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinGroup(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final group = await _storage.getGroupByCode(code);
      if (group == null) {
        _error = 'Código de grupo inválido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedGroup = group.copyWith(
        memberIds: [...group.memberIds, _currentUser!.id],
      );
      await _storage.saveGroup(updatedGroup);

      final updatedUser = _currentUser!.copyWith(
        groupId: group.id,
        isAdmin: false,
      );
      await _storage.saveUser(updatedUser);
      await _storage.setCurrentUser(updatedUser);
      _currentUser = updatedUser;

      await loadGroupData(group.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao entrar no grupo';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadGroupData(String groupId) async {
    _currentGroup = await _storage.getGroupById(groupId);
    _tasks = await _storage.getTasksByGroup(groupId);
    _completions = await _storage.getWeeklyCompletions(groupId);
    
    final users = await _storage.getUsers();
    _groupMembers = users.where((u) => u.groupId == groupId).toList();
    
    notifyListeners();
  }

  Future<void> leaveGroup() async {
    if (_currentUser == null || _currentGroup == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedGroup = _currentGroup!.copyWith(
        memberIds: _currentGroup!.memberIds.where((id) => id != _currentUser!.id).toList(),
      );
      await _storage.saveGroup(updatedGroup);

      final updatedUser = _currentUser!.copyWith(
        groupId: null,
        isAdmin: false,
        weeklyPoints: 0,
      );
      await _storage.saveUser(updatedUser);
      await _storage.setCurrentUser(updatedUser);
      _currentUser = updatedUser;

      _currentGroup = null;
      _tasks = [];
      _completions = [];
      _groupMembers = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao sair do grupo';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Task Management
  Future<bool> createTask({
    required String title,
    String? description,
    required TaskCategory category,
    required TaskFrequency frequency,
    required int points,
  }) async {
    if (_currentGroup == null || !isAdmin) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final task = TaskModel(
        id: _generateId(),
        groupId: _currentGroup!.id,
        title: title,
        description: description,
        category: category,
        frequency: frequency,
        points: points,
        createdBy: _currentUser!.id,
      );

      await _storage.saveTask(task);
      _tasks = await _storage.getTasksByGroup(_currentGroup!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao criar tarefa';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    if (!isAdmin) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _storage.saveTask(task);
      _tasks = await _storage.getTasksByGroup(_currentGroup!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar tarefa';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    if (!isAdmin) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _storage.deleteTask(taskId);
      _tasks = await _storage.getTasksByGroup(_currentGroup!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao excluir tarefa';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTask(TaskModel task, {String? notes}) async {
    if (_currentUser == null || _currentGroup == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final completion = TaskCompletionModel(
        id: _generateId(),
        taskId: task.id,
        userId: _currentUser!.id,
        groupId: _currentGroup!.id,
        pointsEarned: task.points,
        notes: notes,
      );

      await _storage.saveCompletion(completion);

      final updatedUser = _currentUser!.copyWith(
        weeklyPoints: _currentUser!.weeklyPoints + task.points,
        totalPoints: _currentUser!.totalPoints + task.points,
      );
      await _storage.saveUser(updatedUser);
      await _storage.setCurrentUser(updatedUser);
      _currentUser = updatedUser;

      await loadGroupData(_currentGroup!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao completar tarefa';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ranking
  List<UserModel> getWeeklyRanking() {
    final sorted = List<UserModel>.from(_groupMembers);
    sorted.sort((a, b) => b.weeklyPoints.compareTo(a.weeklyPoints));
    return sorted;
  }

  UserModel? getWeeklyWinner() {
    final ranking = getWeeklyRanking();
    if (ranking.isEmpty) return null;
    if (ranking.first.weeklyPoints == 0) return null;
    return ranking.first;
  }

  int getUserPosition(String? userId) {
    if (userId == null) return 0;
    final ranking = getWeeklyRanking();
    final index = ranking.indexWhere((u) => u.id == userId);
    return index >= 0 ? index + 1 : 0;
  }

  // Admin Functions
  Future<void> resetWeeklyRanking() async {
    if (!isAdmin || _currentGroup == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _storage.resetWeeklyPoints(_currentGroup!.id);
      await loadGroupData(_currentGroup!.id);
      
      // Reload current user
      _currentUser = await _storage.getUserById(_currentUser!.id);
      await _storage.setCurrentUser(_currentUser);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao resetar ranking';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeMember(String userId) async {
    if (!isAdmin || _currentGroup == null) return false;
    if (userId == _currentUser!.id) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _storage.getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          groupId: null,
          isAdmin: false,
          weeklyPoints: 0,
        );
        await _storage.saveUser(updatedUser);
      }

      final updatedGroup = _currentGroup!.copyWith(
        memberIds: _currentGroup!.memberIds.where((id) => id != userId).toList(),
      );
      await _storage.saveGroup(updatedGroup);

      await loadGroupData(_currentGroup!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao remover membro';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helpers
  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
