import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Marca tudo como lido ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markAllNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, _) {
              if (appState.notifications.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: 'Limpar tudo',
                onPressed: () => _confirmClear(context, appState),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final notifications = appState.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_off_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tudo calmo por aqui!',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quando rolar uma ultrapassagem épica\nou um marco importante, você vai saber 😎',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (appState.currentGroup != null) {
                await appState.loadGroupData(appState.currentGroup!.id);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    appState.deleteNotification(n.id);
                  },
                  child: _NotificationCard(notification: n),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar notificações?'),
        content: const Text(
          'Isso vai apagar todas as notificações. Não dá pra desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await appState.clearNotifications();
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  Color _accentColor() {
    switch (notification.type) {
      case AppNotificationType.throneStolen:
        return const Color(0xFFFFD700);
      case AppNotificationType.overtaken:
        return AppTheme.errorColor;
      case AppNotificationType.closeCall:
        return AppTheme.warningColor;
      case AppNotificationType.milestone:
        return AppTheme.successColor;
      case AppNotificationType.newMember:
        return AppTheme.accentColor;
      case AppNotificationType.weeklyReset:
        return AppTheme.secondaryColor;
      case AppNotificationType.taskCompleted:
        return AppTheme.primaryColor;
    }
  }

  String _typeLabel() {
    switch (notification.type) {
      case AppNotificationType.throneStolen:
        return '👑 GOLPE NO TRONO';
      case AppNotificationType.overtaken:
        return '😤 ULTRAPASSAGEM';
      case AppNotificationType.closeCall:
        return '👀 ALERTA';
      case AppNotificationType.milestone:
        return '🏆 CONQUISTA';
      case AppNotificationType.newMember:
        return '🎉 NOVO MEMBRO';
      case AppNotificationType.weeklyReset:
        return '🔄 NOVA SEMANA';
      case AppNotificationType.taskCompleted:
        return '✅ TAREFA';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final isUnread = !notification.isRead;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? accent.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? accent.withValues(alpha: 0.5) : AppTheme.dividerColor,
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: isUnread ? AppTheme.cardShadow : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                notification.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _typeLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
