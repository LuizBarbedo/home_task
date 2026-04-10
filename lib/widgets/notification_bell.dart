import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/notifications/notifications_screen.dart';
import '../services/services.dart';
import '../theme/theme.dart';

/// Sininho de notificações com badge de contagem.
/// Mostra a quantidade de notificações não lidas.
class NotificationBell extends StatelessWidget {
  final Color? iconColor;
  final double iconSize;

  const NotificationBell({
    super.key,
    this.iconColor,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final unread = appState.unreadNotificationCount;

        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    unread > 0
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: iconColor ?? AppTheme.textPrimary,
                    size: iconSize,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: unread > 9 ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius:
                              unread > 9 ? BorderRadius.circular(10) : null,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
