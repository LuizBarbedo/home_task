import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';
import '../tasks/tasks_screen.dart';
import '../ranking/ranking_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isAdmin = appState.isAdmin;
        
        final screens = [
          const HomeTab(),
          const TasksScreen(),
          const RankingScreen(),
          if (isAdmin) const AdminScreen(),
          const ProfileScreen(),
        ];

        final items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task_rounded),
            label: 'Tarefas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard_rounded),
            label: 'Ranking',
          ),
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Admin',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: items,
            ),
          ),
        );
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser;
        final group = appState.currentGroup;
        final ranking = appState.getWeeklyRanking();
        final position = appState.getUserPosition(user?.id);
        final tasks = appState.tasks;
        final completions = appState.completions;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              if (group != null) {
                await appState.loadGroupData(group.id);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, ${user?.name.split(' ').first ?? ''}!',
                              style: AppTheme.headingSmall,
                            ),
                            Text(
                              group?.name ?? '',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user?.weeklyPoints ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events_rounded,
                          label: 'Posição',
                          value: position > 0 ? '#$position' : '-',
                          color: position == 1
                              ? const Color(0xFFFFD700)
                              : position == 2
                                  ? const Color(0xFFC0C0C0)
                                  : position == 3
                                      ? const Color(0xFFCD7F32)
                                      : AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Completadas',
                          value:
                              '${completions.where((c) => c.userId == user?.id).length}',
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.task_alt_rounded,
                          label: 'Tarefas',
                          value: '${tasks.length}',
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Weekly Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Progresso Semanal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user?.weeklyPoints ?? 0} pontos',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Esta semana',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                position > 0 ? '#$position' : '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Top 3 Ranking
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ranking da Semana',
                        style: AppTheme.headingSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to ranking tab
                        },
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (ranking.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhum membro ainda',
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...ranking.take(3).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      return _RankingItem(
                        position: index + 1,
                        name: member.name,
                        points: member.weeklyPoints,
                        isCurrentUser: member.id == user?.id,
                      );
                    }),
                  const SizedBox(height: 24),
                  // Recent Tasks
                  const Text(
                    'Tarefas Disponíveis',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 12),
                  if (tasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Nenhuma tarefa criada',
                              style: AppTheme.bodyMedium,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'O administrador pode criar tarefas',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...tasks.take(3).map((task) {
                      return _TaskPreviewCard(task: task);
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
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
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final int position;
  final String name;
  final int points;
  final bool isCurrentUser;

  const _RankingItem({
    required this.position,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? AppTheme.primaryColor : AppTheme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: position == 1
                  ? AppTheme.goldGradient
                  : position == 2
                      ? AppTheme.silverGradient
                      : position == 3
                          ? AppTheme.bronzeGradient
                          : null,
              color: position > 3 ? AppTheme.textSecondary : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTheme.labelLarge.copyWith(
                color: isCurrentUser ? AppTheme.primaryColor : null,
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 18,
                color: position == 1
                    ? const Color(0xFFFFD700)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '$points pts',
                style: AppTheme.labelLarge.copyWith(
                  color: isCurrentUser
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskPreviewCard extends StatelessWidget {
  final dynamic task;

  const _TaskPreviewCard({required this.task});

  IconData _getCategoryIcon() {
    switch (task.category.index) {
      case 0:
        return Icons.cleaning_services_rounded;
      case 1:
        return Icons.kitchen_rounded;
      case 2:
        return Icons.local_laundry_service_rounded;
      case 3:
        return Icons.grass_rounded;
      case 4:
        return Icons.inventory_2_rounded;
      case 5:
        return Icons.pets_rounded;
      case 6:
        return Icons.shopping_cart_rounded;
      default:
        return Icons.task_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTheme.labelLarge,
                ),
                Text(
                  task.categoryName,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${task.points}',
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
