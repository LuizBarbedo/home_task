import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';
import 'ad_service.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

/// Modo de operação do app
enum AppMode {
  /// Dados salvos apenas localmente (offline)
  local,
  /// Dados sincronizados com Supabase (online)
  cloud,
}

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  
  UserModel? _currentUser;
  GroupModel? _currentGroup;
  List<TaskModel> _tasks = [];
  List<TaskCompletionModel> _completions = [];
  List<UserModel> _groupMembers = [];
  bool _isLoading = false;
  String? _error;
  AppMode _mode = AppMode.local;
  
  // Subscriptions para real-time (Supabase)
  RealtimeChannel? _tasksSubscription;
  RealtimeChannel? _completionsSubscription;
  RealtimeChannel? _membersSubscription;

  UserModel? get currentUser => _currentUser;
  GroupModel? get currentGroup => _currentGroup;
  List<TaskModel> get tasks => _tasks;
  List<TaskCompletionModel> get completions => _completions;
  List<UserModel> get groupMembers => _groupMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  AppMode get mode => _mode;
  bool get isCloudMode => _mode == AppMode.cloud;

  Future<void> init() async {
    try {
      await _storage.init();
    } catch (e) {
      debugPrint('Erro ao inicializar storage: $e');
    }
    
    // Tenta inicializar Supabase se estiver configurado
    if (SupabaseConfig.isConfigured) {
      try {
        await SupabaseService.initialize();
        _mode = AppMode.cloud;
        
        // Verifica se há usuário autenticado
        final authUser = SupabaseService.currentAuthUser;
        if (authUser != null) {
          _currentUser = await SupabaseService.getUserById(authUser.id);
          if (_currentUser?.groupId != null) {
            await loadGroupData(_currentUser!.groupId!);
          }
        }
      } catch (e) {
        // Se falhar, usa modo local
        debugPrint('Erro ao inicializar Supabase: $e');
        _mode = AppMode.local;
        try {
          await _loadCurrentUserLocal();
        } catch (e2) {
          debugPrint('Erro ao carregar usuário local: $e2');
        }
      }
    } else {
      // Supabase não configurado, usa modo local
      _mode = AppMode.local;
      try {
        await _loadCurrentUserLocal();
      } catch (e) {
        debugPrint('Erro ao carregar usuário local: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> _loadCurrentUserLocal() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _storage.getCurrentUser();
    if (_currentUser != null && _currentUser!.groupId != null) {
      await loadGroupData(_currentUser!.groupId!);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // AUTENTICAÇÃO
  // ============================================================
  
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_mode == AppMode.cloud) {
        // Registro via Supabase
        final user = await SupabaseService.signUp(
          email: email,
          password: password,
          name: name,
        );
        
        if (user == null) {
          _error = 'Erro ao criar conta. Verifique seu email.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _currentUser = user;
      } else {
        // Registro local
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
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
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
      if (_mode == AppMode.cloud) {
        // Login via Supabase
        final user = await SupabaseService.signIn(
          email: email,
          password: password,
        );
        
        if (user == null) {
          _error = 'Email ou senha incorretos';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _currentUser = user;
        
        if (user.groupId != null) {
          await loadGroupData(user.groupId!);
        }
      } else {
        // Login local
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
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _cancelSubscriptions();
    
    if (_mode == AppMode.cloud) {
      await SupabaseService.signOut();
    }
    
    await _storage.setCurrentUser(null);
    _currentUser = null;
    _currentGroup = null;
    _tasks = [];
    _completions = [];
    _groupMembers = [];
    notifyListeners();
  }

  // ============================================================
  // GERENCIAMENTO DE GRUPO
  // ============================================================
  
  Future<bool> createGroup(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final code = _generateGroupCode();
      
      if (_mode == AppMode.cloud) {
        // Criar grupo no Supabase
        final group = await SupabaseService.createGroup(
          name: name,
          adminId: _currentUser!.id,
          code: code,
        );
        
        // Atualizar usuário
        final updatedUser = _currentUser!.copyWith(
          groupId: group.id,
          isAdmin: true,
        );
        await SupabaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
        
        await loadGroupData(group.id);
      } else {
        // Criar grupo local
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
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
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
      GroupModel? group;
      
      if (_mode == AppMode.cloud) {
        group = await SupabaseService.getGroupByCode(code);
      } else {
        group = await _storage.getGroupByCode(code);
      }
      
      if (group == null) {
        _error = 'Código de grupo inválido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (_mode == AppMode.cloud) {
        // Adicionar membro no Supabase
        await SupabaseService.addMemberToGroup(group.id, _currentUser!.id);
        
        final updatedUser = _currentUser!.copyWith(
          groupId: group.id,
          isAdmin: false,
        );
        await SupabaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
      } else {
        // Adicionar membro local
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
      }

      await loadGroupData(group.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadGroupData(String groupId) async {
    if (_mode == AppMode.cloud) {
      _currentGroup = await SupabaseService.getGroupById(groupId);
      _tasks = await SupabaseService.getTasksByGroup(groupId);
      _completions = await SupabaseService.getCompletionsByGroup(groupId);
      _groupMembers = await SupabaseService.getGroupMembers(groupId);
      
      // Configurar subscriptions para real-time
      _setupRealtimeSubscriptions(groupId);
    } else {
      _currentGroup = await _storage.getGroupById(groupId);
      _tasks = await _storage.getTasksByGroup(groupId);
      _completions = await _storage.getWeeklyCompletions(groupId);
      
      final users = await _storage.getUsers();
      _groupMembers = users.where((u) => u.groupId == groupId).toList();
    }
    
    notifyListeners();
  }

  void _setupRealtimeSubscriptions(String groupId) {
    _cancelSubscriptions();
    
    _tasksSubscription = SupabaseService.subscribeToTasks(groupId, (tasks) {
      _tasks = tasks;
      notifyListeners();
    });
    
    _completionsSubscription = SupabaseService.subscribeToCompletions(groupId, (completions) {
      _completions = completions;
      notifyListeners();
    });
    
    _membersSubscription = SupabaseService.subscribeToGroupMembers(groupId, (members) {
      _groupMembers = members;
      notifyListeners();
    });
  }

  void _cancelSubscriptions() {
    if (_tasksSubscription != null) {
      SupabaseService.unsubscribe(_tasksSubscription!);
      _tasksSubscription = null;
    }
    if (_completionsSubscription != null) {
      SupabaseService.unsubscribe(_completionsSubscription!);
      _completionsSubscription = null;
    }
    if (_membersSubscription != null) {
      SupabaseService.unsubscribe(_membersSubscription!);
      _membersSubscription = null;
    }
  }

  Future<void> leaveGroup() async {
    if (_currentUser == null || _currentGroup == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_mode == AppMode.cloud) {
        await SupabaseService.removeMemberFromGroup(
          _currentGroup!.id, 
          _currentUser!.id,
        );
        
        final updatedUser = _currentUser!.copyWith(
          groupId: null,
          isAdmin: false,
          weeklyPoints: 0,
        );
        await SupabaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
      } else {
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
      }

      _cancelSubscriptions();
      _currentGroup = null;
      _tasks = [];
      _completions = [];
      _groupMembers = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // GERENCIAMENTO DE TAREFAS
  // ============================================================
  
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

      if (_mode == AppMode.cloud) {
        await SupabaseService.createTask(task);
        _tasks = await SupabaseService.getTasksByGroup(_currentGroup!.id);
      } else {
        await _storage.saveTask(task);
        _tasks = await _storage.getTasksByGroup(_currentGroup!.id);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
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
      if (_mode == AppMode.cloud) {
        await SupabaseService.updateTask(task);
        _tasks = await SupabaseService.getTasksByGroup(_currentGroup!.id);
      } else {
        await _storage.saveTask(task);
        _tasks = await _storage.getTasksByGroup(_currentGroup!.id);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
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
      if (_mode == AppMode.cloud) {
        await SupabaseService.deleteTask(taskId);
        _tasks = await SupabaseService.getTasksByGroup(_currentGroup!.id);
      } else {
        await _storage.deleteTask(taskId);
        _tasks = await _storage.getTasksByGroup(_currentGroup!.id);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
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

      if (_mode == AppMode.cloud) {
        await SupabaseService.createCompletion(completion);
        
        final updatedUser = _currentUser!.copyWith(
          weeklyPoints: _currentUser!.weeklyPoints + task.points,
          totalPoints: _currentUser!.totalPoints + task.points,
        );
        await SupabaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
        
        await loadGroupData(_currentGroup!.id);
      } else {
        await _storage.saveCompletion(completion);

        final updatedUser = _currentUser!.copyWith(
          weeklyPoints: _currentUser!.weeklyPoints + task.points,
          totalPoints: _currentUser!.totalPoints + task.points,
        );
        await _storage.saveUser(updatedUser);
        await _storage.setCurrentUser(updatedUser);
        _currentUser = updatedUser;

        await loadGroupData(_currentGroup!.id);
      }

      // Notifica o serviço de anúncios (pode mostrar intersticial)
      await AdService().onTaskCompleted();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // RANKING
  // ============================================================
  
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

  // ============================================================
  // FUNÇÕES DE ADMIN
  // ============================================================
  
  Future<void> resetWeeklyRanking() async {
    if (!isAdmin || _currentGroup == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_mode == AppMode.cloud) {
        // Reset points para todos os membros
        for (final member in _groupMembers) {
          final updatedMember = member.copyWith(weeklyPoints: 0);
          await SupabaseService.updateUser(updatedMember);
        }
        
        _currentUser = _currentUser!.copyWith(weeklyPoints: 0);
        await loadGroupData(_currentGroup!.id);
      } else {
        await _storage.resetWeeklyPoints(_currentGroup!.id);
        await loadGroupData(_currentGroup!.id);
        
        _currentUser = await _storage.getUserById(_currentUser!.id);
        await _storage.setCurrentUser(_currentUser);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _parseError(e);
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
      if (_mode == AppMode.cloud) {
        final user = await SupabaseService.getUserById(userId);
        if (user != null) {
          final updatedUser = user.copyWith(
            groupId: null,
            isAdmin: false,
            weeklyPoints: 0,
          );
          await SupabaseService.updateUser(updatedUser);
        }
        
        await SupabaseService.removeMemberFromGroup(_currentGroup!.id, userId);
        await loadGroupData(_currentGroup!.id);
      } else {
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
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // EXCLUSÃO DE CONTA
  // ============================================================
  
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Se estiver em um grupo, sair primeiro
      if (_currentGroup != null) {
        await leaveGroup();
      }
      
      if (_mode == AppMode.cloud) {
        await SupabaseService.deleteAccount(_currentUser!.id);
        await SupabaseService.signOut();
      }
      
      await _storage.setCurrentUser(null);
      _currentUser = null;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  
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

  String _parseError(dynamic e) {
    if (e is AuthException) {
      switch (e.message) {
        case 'Invalid login credentials':
          return 'Email ou senha incorretos';
        case 'User already registered':
          return 'Este email já está cadastrado';
        case 'Email not confirmed':
          return 'Confirme seu email antes de fazer login';
        default:
          return e.message;
      }
    }
    return 'Ocorreu um erro. Tente novamente.';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
