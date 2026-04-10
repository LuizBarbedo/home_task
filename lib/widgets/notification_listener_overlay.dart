import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../theme/theme.dart';

/// Widget invisível que escuta a stream de novas notificações em tempo real
/// e mostra um snackbar engraçado quando algo acontece.
///
/// Coloque na raiz de uma tela com Scaffold no contexto (ex: dentro do
/// MainScreen body) para que possa exibir SnackBars.
class NotificationListenerOverlay extends StatefulWidget {
  final Widget child;

  const NotificationListenerOverlay({super.key, required this.child});

  @override
  State<NotificationListenerOverlay> createState() =>
      _NotificationListenerOverlayState();
}

class _NotificationListenerOverlayState
    extends State<NotificationListenerOverlay> {
  StreamSubscription<NotificationModel>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribe();
    });
  }

  void _subscribe() {
    final appState = context.read<AppState>();
    _subscription?.cancel();
    _subscription = appState.newNotificationStream.listen(_handleNotification);
  }

  void _handleNotification(NotificationModel notification) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final accent = _accentColor(notification.type);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        content: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  notification.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // marca como lida; o usuário pode abrir a tela de notificações pelo sino
            context.read<AppState>().markNotificationAsRead(notification.id);
          },
        ),
      ),
    );
  }

  Color _accentColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.throneStolen:
        return const Color(0xFFE6A800);
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
