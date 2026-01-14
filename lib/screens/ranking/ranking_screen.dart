import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final ranking = appState.getWeeklyRanking();
        final currentUser = appState.currentUser;
        final winner = appState.getWeeklyWinner();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ranking'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (appState.currentGroup != null) {
                await appState.loadGroupData(appState.currentGroup!.id);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header with Top 3 Podium
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Ranking da Semana',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getWeekRange(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Podium
                        if (ranking.length >= 3)
                          _buildPodium(ranking.take(3).toList(), currentUser?.id)
                        else if (ranking.isNotEmpty)
                          _buildSimplePodium(ranking, currentUser?.id)
                        else
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Aguardando participantes...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Winner Announcement
                  if (winner != null) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🏆 Líder da Semana',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    winner.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFD700),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${winner.weeklyPoints}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // Full Ranking List
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Classificação Geral',
                          style: AppTheme.headingSmall,
                        ),
                        const Spacer(),
                        Text(
                          '${ranking.length} participantes',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: ranking.length,
                    itemBuilder: (context, index) {
                      final user = ranking[index];
                      return _RankingListItem(
                        position: index + 1,
                        user: user,
                        isCurrentUser: user.id == currentUser?.id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getWeekRange() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
  }

  Widget _buildPodium(List<UserModel> topThree, String? currentUserId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        _PodiumItem(
          user: topThree[1],
          position: 2,
          height: 80,
          isCurrentUser: topThree[1].id == currentUserId,
        ),
        const SizedBox(width: 8),
        // 1st Place
        _PodiumItem(
          user: topThree[0],
          position: 1,
          height: 110,
          isCurrentUser: topThree[0].id == currentUserId,
        ),
        const SizedBox(width: 8),
        // 3rd Place
        _PodiumItem(
          user: topThree[2],
          position: 3,
          height: 60,
          isCurrentUser: topThree[2].id == currentUserId,
        ),
      ],
    );
  }

  Widget _buildSimplePodium(List<UserModel> users, String? currentUserId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: users.asMap().entries.map((entry) {
        final index = entry.key;
        final user = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _PodiumItem(
            user: user,
            position: index + 1,
            height: index == 0 ? 110 : index == 1 ? 80 : 60,
            isCurrentUser: user.id == currentUserId,
          ),
        );
      }).toList(),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final UserModel user;
  final int position;
  final double height;
  final bool isCurrentUser;

  const _PodiumItem({
    required this.user,
    required this.position,
    required this.height,
    this.isCurrentUser = false,
  });

  LinearGradient _getGradient() {
    switch (position) {
      case 1:
        return AppTheme.goldGradient;
      case 2:
        return AppTheme.silverGradient;
      case 3:
        return AppTheme.bronzeGradient;
      default:
        return AppTheme.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Crown for 1st place
        if (position == 1)
          const Text(
            '👑',
            style: TextStyle(fontSize: 28),
          ),
        const SizedBox(height: 4),
        // Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentUser ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: position == 1 ? 32 : 24,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: position == 1 ? 24 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Name
        SizedBox(
          width: 80,
          child: Text(
            user.name.split(' ').first,
            style: TextStyle(
              color: Colors.white,
              fontSize: position == 1 ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Points
        Text(
          '${user.weeklyPoints} pts',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        // Pedestal
        Container(
          width: position == 1 ? 90 : 70,
          height: height,
          decoration: BoxDecoration(
            gradient: _getGradient(),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingListItem extends StatelessWidget {
  final int position;
  final UserModel user;
  final bool isCurrentUser;

  const _RankingListItem({
    required this.position,
    required this.user,
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
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: isCurrentUser ? AppTheme.cardShadow : null,
      ),
      child: Row(
        children: [
          // Position Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: position <= 3
                  ? position == 1
                      ? AppTheme.goldGradient
                      : position == 2
                          ? AppTheme.silverGradient
                          : AppTheme.bronzeGradient
                  : null,
              color: position > 3 ? AppTheme.textSecondary.withValues(alpha: 0.2) : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: position <= 3 ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrentUser
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isCurrentUser ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: AppTheme.labelLarge.copyWith(
                        color:
                            isCurrentUser ? AppTheme.primaryColor : null,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Você',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Total: ${user.totalPoints} pontos',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Weekly Points
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: position == 1
                  ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                  : AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: position == 1
                      ? const Color(0xFFFFD700)
                      : AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.weeklyPoints}',
                  style: TextStyle(
                    color: position == 1
                        ? const Color(0xFFFFD700)
                        : AppTheme.successColor,
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
