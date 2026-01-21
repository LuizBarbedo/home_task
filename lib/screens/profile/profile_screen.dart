import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';
import '../auth/login_screen.dart';
import '../group/group_screen.dart';
import '../premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser;
        final group = appState.currentGroup;
        final position = appState.getUserPosition(user?.id);
        final completions = appState.completions.where((c) => c.userId == user?.id).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            actions: [
              IconButton(
                onPressed: () => _showSettingsSheet(context),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      if (user?.isAdmin == true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Administrador',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_rounded,
                        value: '${user?.weeklyPoints ?? 0}',
                        label: 'Pontos\nSemana',
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events_rounded,
                        value: position > 0 ? '#$position' : '-',
                        label: 'Posição\nRanking',
                        color: position == 1
                            ? const Color(0xFFFFD700)
                            : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.workspace_premium_rounded,
                        value: '${user?.totalPoints ?? 0}',
                        label: 'Pontos\nTotal',
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Group Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Meu Grupo',
                                  style: AppTheme.bodySmall,
                                ),
                                Text(
                                  group?.name ?? '',
                                  style: AppTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Código do Grupo',
                                  style: AppTheme.bodySmall,
                                ),
                                Text(
                                  group?.code ?? '',
                                  style: AppTheme.labelLarge.copyWith(
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Membros',
                                  style: AppTheme.bodySmall,
                                ),
                                Text(
                                  '${appState.groupMembers.length} pessoas',
                                  style: AppTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Activity Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.timeline_rounded,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Atividade da Semana',
                            style: AppTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ActivityItem(
                            icon: Icons.check_circle_rounded,
                            value: '${completions.length}',
                            label: 'Tarefas',
                            color: AppTheme.successColor,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.dividerColor,
                          ),
                          _ActivityItem(
                            icon: Icons.star_rounded,
                            value: '${user?.weeklyPoints ?? 0}',
                            label: 'Pontos',
                            color: AppTheme.warningColor,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.dividerColor,
                          ),
                          _ActivityItem(
                            icon: Icons.local_fire_department_rounded,
                            value: _getStreak(completions),
                            label: 'Sequência',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Actions
                _ActionButton(
                  icon: Icons.logout_rounded,
                  label: 'Sair do Grupo',
                  color: AppTheme.warningColor,
                  onTap: () => _showLeaveGroupDialog(context),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.exit_to_app_rounded,
                  label: 'Sair da Conta',
                  color: AppTheme.errorColor,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStreak(List completions) {
    if (completions.isEmpty) return '0';
    
    // Simple streak calculation based on days with completions
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final hasCompletion = completions.any((c) {
        final completedDate = c.completedAt as DateTime;
        return completedDate.year == day.year &&
            completedDate.month == day.month &&
            completedDate.day == day.day;
      });
      
      if (hasCompletion) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    
    return '$streak';
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opção Premium
              Consumer<PurchaseService>(
                builder: (context, purchaseService, child) {
                  return ListTile(
                    leading: Icon(
                      Icons.workspace_premium,
                      color: purchaseService.isPremium 
                          ? Colors.amber 
                          : Colors.grey,
                    ),
                    title: Text(
                      purchaseService.isPremium 
                          ? 'Você é Premium!' 
                          : 'Seja Premium',
                    ),
                    subtitle: Text(
                      purchaseService.isPremium 
                          ? 'Sem anúncios' 
                          : 'Remova os anúncios',
                    ),
                    trailing: purchaseService.isPremium
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PremiumScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notificações'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Modo Escuro'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre o App'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Tarefas em Casa',
                    applicationVersion: '1.0.0',
                    applicationIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                      ),
                    ),
                    children: [
                      const Text(
                        'Um aplicativo para organizar tarefas domésticas '
                        'e motivar toda a família!',
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Excluir minha conta',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Remove permanentemente sua conta e dados'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red),
              SizedBox(width: 12),
              Text('Excluir Conta'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tem certeza que deseja excluir sua conta?\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Esta ação é PERMANENTE e irá:'),
              SizedBox(height: 8),
              Text('• Remover seu perfil e dados pessoais'),
              Text('• Excluir seu histórico de tarefas'),
              Text('• Remover você de todos os grupos'),
              SizedBox(height: 12),
              Text(
                'Não será possível recuperar sua conta após a exclusão.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _deleteAccount(context);
              },
              child: const Text('Excluir Conta'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.deleteAccount();

      Navigator.pop(context); // Fecha o loading

      if (success) {
        // Redireciona para login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir conta. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fecha o loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.warningColor),
              SizedBox(width: 12),
              Text('Sair do Grupo'),
            ],
          ),
          content: const Text(
            'Deseja sair do grupo?\n\n'
            'Você poderá entrar novamente com o código do grupo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            Consumer<AppState>(
              builder: (context, appState, child) {
                return ElevatedButton(
                  onPressed: appState.isLoading
                      ? null
                      : () async {
                          await appState.leaveGroup();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const GroupScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor,
                  ),
                  child: const Text('Sair'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.exit_to_app_rounded, color: AppTheme.errorColor),
              SizedBox(width: 12),
              Text('Sair da Conta'),
            ],
          ),
          content: const Text(
            'Deseja sair da sua conta?\n\n'
            'Você precisará fazer login novamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            Consumer<AppState>(
              builder: (context, appState, child) {
                return ElevatedButton(
                  onPressed: () async {
                    await appState.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  child: const Text('Sair'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
