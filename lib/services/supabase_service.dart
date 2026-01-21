import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Serviço para comunicação com o Supabase
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;
  
  /// Inicializa a conexão com o Supabase
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase não configurado. Edite o arquivo lib/config/supabase_config.dart'
      );
    }
    
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }
  
  /// Verifica se o Supabase está configurado
  static bool get isConfigured => SupabaseConfig.isConfigured;
  
  // ============================================================
  // AUTENTICAÇÃO
  // ============================================================
  
  /// Registra um novo usuário
  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    
    if (response.user == null) return null;
    
    // Cria o perfil do usuário na tabela users
    final user = UserModel(
      id: response.user!.id,
      name: name,
      email: email,
    );
    
    await _client.from('users').upsert(user.toSupabase());
    
    return user;
  }
  
  /// Faz login com email e senha
  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) return null;
    
    // Busca o perfil do usuário
    return await getUserById(response.user!.id);
  }
  
  /// Faz logout
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  /// Retorna o usuário atual autenticado
  static User? get currentAuthUser => _client.auth.currentUser;
  
  /// Stream de mudanças de autenticação
  static Stream<AuthState> get authStateChanges => 
      _client.auth.onAuthStateChange;
  
  // ============================================================
  // USUÁRIOS
  // ============================================================
  
  /// Busca um usuário por ID
  static Future<UserModel?> getUserById(String id) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return UserModel.fromSupabase(response);
  }
  
  /// Atualiza os dados do usuário
  static Future<void> updateUser(UserModel user) async {
    await _client
        .from('users')
        .update(user.toSupabase())
        .eq('id', user.id);
  }
  
  /// Busca todos os membros de um grupo
  static Future<List<UserModel>> getGroupMembers(String groupId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('group_id', groupId);
    
    return (response as List)
        .map((e) => UserModel.fromSupabase(e))
        .toList();
  }
  
  /// Exclui a conta do usuário
  static Future<void> deleteAccount(String userId) async {
    // Remove o usuário da tabela users (o auth é gerenciado separadamente)
    await _client.from('users').delete().eq('id', userId);
  }
  
  // ============================================================
  // GRUPOS
  // ============================================================
  
  /// Cria um novo grupo
  static Future<GroupModel> createGroup({
    required String name,
    required String adminId,
    required String code,
  }) async {
    final group = GroupModel(
      id: '', // Será gerado pelo Supabase
      name: name,
      code: code,
      adminId: adminId,
      memberIds: [adminId],
    );
    
    final response = await _client
        .from('groups')
        .insert(group.toSupabase())
        .select()
        .single();
    
    return GroupModel.fromSupabase(response);
  }
  
  /// Busca um grupo por ID
  static Future<GroupModel?> getGroupById(String id) async {
    final response = await _client
        .from('groups')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return GroupModel.fromSupabase(response);
  }
  
  /// Busca um grupo pelo código de convite
  static Future<GroupModel?> getGroupByCode(String code) async {
    final response = await _client
        .from('groups')
        .select()
        .eq('code', code.toUpperCase())
        .maybeSingle();
    
    if (response == null) return null;
    return GroupModel.fromSupabase(response);
  }
  
  /// Atualiza os dados do grupo
  static Future<void> updateGroup(GroupModel group) async {
    await _client
        .from('groups')
        .update(group.toSupabase())
        .eq('id', group.id);
  }
  
  /// Adiciona um membro ao grupo
  static Future<void> addMemberToGroup(String groupId, String userId) async {
    final group = await getGroupById(groupId);
    if (group == null) return;
    
    final updatedMemberIds = [...group.memberIds, userId];
    await _client
        .from('groups')
        .update({'member_ids': updatedMemberIds})
        .eq('id', groupId);
  }
  
  /// Remove um membro do grupo
  static Future<void> removeMemberFromGroup(String groupId, String userId) async {
    final group = await getGroupById(groupId);
    if (group == null) return;
    
    final updatedMemberIds = group.memberIds.where((id) => id != userId).toList();
    await _client
        .from('groups')
        .update({'member_ids': updatedMemberIds})
        .eq('id', groupId);
  }
  
  // ============================================================
  // TAREFAS
  // ============================================================
  
  /// Cria uma nova tarefa
  static Future<TaskModel> createTask(TaskModel task) async {
    final response = await _client
        .from('tasks')
        .insert(task.toSupabase())
        .select()
        .single();
    
    return TaskModel.fromSupabase(response);
  }
  
  /// Busca todas as tarefas de um grupo
  static Future<List<TaskModel>> getTasksByGroup(String groupId) async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('group_id', groupId)
        .eq('is_active', true);
    
    return (response as List)
        .map((e) => TaskModel.fromSupabase(e))
        .toList();
  }
  
  /// Atualiza uma tarefa
  static Future<void> updateTask(TaskModel task) async {
    await _client
        .from('tasks')
        .update(task.toSupabase())
        .eq('id', task.id);
  }
  
  /// Deleta uma tarefa (soft delete)
  static Future<void> deleteTask(String taskId) async {
    await _client
        .from('tasks')
        .update({'is_active': false})
        .eq('id', taskId);
  }
  
  // ============================================================
  // CONCLUSÕES DE TAREFAS
  // ============================================================
  
  /// Registra a conclusão de uma tarefa
  static Future<TaskCompletionModel> createCompletion(
    TaskCompletionModel completion,
  ) async {
    final response = await _client
        .from('task_completions')
        .insert(completion.toSupabase())
        .select()
        .single();
    
    return TaskCompletionModel.fromSupabase(response);
  }
  
  /// Busca todas as conclusões de um grupo
  static Future<List<TaskCompletionModel>> getCompletionsByGroup(
    String groupId,
  ) async {
    final response = await _client
        .from('task_completions')
        .select()
        .eq('group_id', groupId)
        .order('completed_at', ascending: false);
    
    return (response as List)
        .map((e) => TaskCompletionModel.fromSupabase(e))
        .toList();
  }
  
  /// Busca as conclusões de um grupo em um período
  static Future<List<TaskCompletionModel>> getCompletionsByPeriod(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client
        .from('task_completions')
        .select()
        .eq('group_id', groupId)
        .gte('completed_at', startDate.toIso8601String())
        .lte('completed_at', endDate.toIso8601String())
        .order('completed_at', ascending: false);
    
    return (response as List)
        .map((e) => TaskCompletionModel.fromSupabase(e))
        .toList();
  }
  
  // ============================================================
  // REAL-TIME SUBSCRIPTIONS
  // ============================================================
  
  /// Escuta mudanças nas tarefas do grupo
  static RealtimeChannel subscribeToTasks(
    String groupId,
    void Function(List<TaskModel>) onData,
  ) {
    return _client
        .channel('tasks:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) async {
            final tasks = await getTasksByGroup(groupId);
            onData(tasks);
          },
        )
        .subscribe();
  }
  
  /// Escuta mudanças nas conclusões do grupo
  static RealtimeChannel subscribeToCompletions(
    String groupId,
    void Function(List<TaskCompletionModel>) onData,
  ) {
    return _client
        .channel('completions:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'task_completions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) async {
            final completions = await getCompletionsByGroup(groupId);
            onData(completions);
          },
        )
        .subscribe();
  }
  
  /// Escuta mudanças nos membros do grupo
  static RealtimeChannel subscribeToGroupMembers(
    String groupId,
    void Function(List<UserModel>) onData,
  ) {
    return _client
        .channel('members:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) async {
            final members = await getGroupMembers(groupId);
            onData(members);
          },
        )
        .subscribe();
  }
  
  /// Remove uma subscription
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
