/// Tipos de notificação interativa do app
enum AppNotificationType {
  /// Alguém te ultrapassou no ranking
  overtaken,

  /// Alguém te tirou do 1º lugar
  throneStolen,

  /// Você está perto de ser ultrapassado
  closeCall,

  /// Alguém completou uma tarefa (ping engraçado)
  taskCompleted,

  /// Você bateu uma marca de pontos
  milestone,

  /// Alguém entrou no grupo
  newMember,

  /// Reset semanal aconteceu
  weeklyReset,
}

extension AppNotificationTypeX on AppNotificationType {
  String get key {
    switch (this) {
      case AppNotificationType.overtaken:
        return 'overtaken';
      case AppNotificationType.throneStolen:
        return 'throne_stolen';
      case AppNotificationType.closeCall:
        return 'close_call';
      case AppNotificationType.taskCompleted:
        return 'task_completed';
      case AppNotificationType.milestone:
        return 'milestone';
      case AppNotificationType.newMember:
        return 'new_member';
      case AppNotificationType.weeklyReset:
        return 'weekly_reset';
    }
  }

  static AppNotificationType fromKey(String? key) {
    switch (key) {
      case 'overtaken':
        return AppNotificationType.overtaken;
      case 'throne_stolen':
        return AppNotificationType.throneStolen;
      case 'close_call':
        return AppNotificationType.closeCall;
      case 'task_completed':
        return AppNotificationType.taskCompleted;
      case 'milestone':
        return AppNotificationType.milestone;
      case 'new_member':
        return AppNotificationType.newMember;
      case 'weekly_reset':
        return AppNotificationType.weeklyReset;
      default:
        return AppNotificationType.taskCompleted;
    }
  }
}

class NotificationModel {
  final String id;

  /// Quem recebe a notificação
  final String userId;

  /// Quem disparou a notificação (pode ser null para eventos do sistema)
  final String? fromUserId;
  final String? fromUserName;

  final String groupId;
  final AppNotificationType type;

  /// Mensagem engraçada já formatada
  final String message;

  /// Emoji destacado pra mostrar como ícone
  final String emoji;

  final bool isRead;
  final DateTime createdAt;

  /// Dados extras: pontos, posição, etc.
  final Map<String, dynamic> metadata;

  NotificationModel({
    required this.id,
    required this.userId,
    this.fromUserId,
    this.fromUserName,
    required this.groupId,
    required this.type,
    required this.message,
    this.emoji = '🔔',
    this.isRead = false,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  })  : createdAt = createdAt ?? DateTime.now(),
        metadata = metadata ?? const {};

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? fromUserId,
    String? fromUserName,
    String? groupId,
    AppNotificationType? type,
    String? message,
    String? emoji,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      message: message ?? this.message,
      emoji: emoji ?? this.emoji,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'from_user_id': fromUserId,
      'from_user_name': fromUserName,
      'group_id': groupId,
      'type': type.key,
      'message': message,
      'emoji': emoji,
      'is_read': isRead,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromSupabase(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as String,
      fromUserId: json['from_user_id'] as String?,
      fromUserName: json['from_user_name'] as String?,
      groupId: json['group_id'] as String,
      type: AppNotificationTypeX.fromKey(json['type'] as String?),
      message: json['message'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🔔',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      metadata: (json['metadata'] is Map<String, dynamic>)
          ? json['metadata'] as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }
}
