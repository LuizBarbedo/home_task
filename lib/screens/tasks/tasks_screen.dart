import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    if (_selectedCategory == null) return tasks;
    return tasks.where((t) => t.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final tasks = _filterTasks(appState.tasks);
        final completions = appState.completions;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tarefas'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Disponíveis'),
                Tab(text: 'Concluídas'),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryColor,
            ),
          ),
          body: Column(
            children: [
              // Category Filter
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'Todas',
                      isSelected: _selectedCategory == null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                    ...TaskCategory.values.map((category) {
                      return _CategoryChip(
                        label: _getCategoryName(category),
                        isSelected: _selectedCategory == category,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              // Task Lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Available Tasks
                    tasks.isEmpty
                        ? _EmptyState(
                            icon: Icons.task_outlined,
                            title: 'Nenhuma tarefa disponível',
                            subtitle: _selectedCategory != null
                                ? 'Tente selecionar outra categoria'
                                : 'O administrador pode criar novas tarefas',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              return _TaskCard(
                                task: tasks[index],
                                onComplete: () =>
                                    _showCompleteDialog(context, tasks[index]),
                              );
                            },
                          ),
                    // Completed Tasks
                    completions.isEmpty
                        ? const _EmptyState(
                            icon: Icons.check_circle_outline,
                            title: 'Nenhuma tarefa concluída',
                            subtitle: 'Complete tarefas para ganhar pontos',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: completions.length,
                            itemBuilder: (context, index) {
                              final completion = completions[completions.length - 1 - index];
                              final task = appState.tasks.firstWhere(
                                (t) => t.id == completion.taskId,
                                orElse: () => TaskModel(
                                  id: '',
                                  groupId: '',
                                  title: 'Tarefa removida',
                                  category: TaskCategory.other,
                                  frequency: TaskFrequency.once,
                                  points: completion.pointsEarned,
                                  createdBy: '',
                                ),
                              );
                              return _CompletedTaskCard(
                                task: task,
                                completion: completion,
                                userName: appState.groupMembers
                                    .firstWhere(
                                      (u) => u.id == completion.userId,
                                      orElse: () => UserModel(
                                        id: '',
                                        name: 'Usuário',
                                        email: '',
                                      ),
                                    )
                                    .name,
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.cleaning:
        return 'Limpeza';
      case TaskCategory.kitchen:
        return 'Cozinha';
      case TaskCategory.laundry:
        return 'Lavanderia';
      case TaskCategory.garden:
        return 'Jardim';
      case TaskCategory.organization:
        return 'Organização';
      case TaskCategory.pets:
        return 'Pets';
      case TaskCategory.shopping:
        return 'Compras';
      case TaskCategory.other:
        return 'Outros';
    }
  }

  void _showCompleteDialog(BuildContext context, TaskModel task) {
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completar Tarefa',
                          style: AppTheme.headingSmall,
                        ),
                        Text(
                          task.title,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Você ganhará ${task.points} pontos!',
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Adicione alguma observação...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<AppState>(
                      builder: (context, appState, child) {
                        return ElevatedButton(
                          onPressed: appState.isLoading
                              ? null
                              : () async {
                                  final success = await appState.completeTask(
                                    task,
                                    notes: notesController.text.isNotEmpty
                                        ? notesController.text
                                        : null,
                                  );

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Parabéns! +${task.points} pontos!',
                                              ),
                                            ],
                                          ),
                                          backgroundColor:
                                              AppTheme.successColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                          child: appState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Confirmar'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onComplete;

  const _TaskCard({
    required this.task,
    required this.onComplete,
  });

  IconData _getCategoryIcon() {
    switch (task.category) {
      case TaskCategory.cleaning:
        return Icons.cleaning_services_rounded;
      case TaskCategory.kitchen:
        return Icons.kitchen_rounded;
      case TaskCategory.laundry:
        return Icons.local_laundry_service_rounded;
      case TaskCategory.garden:
        return Icons.grass_rounded;
      case TaskCategory.organization:
        return Icons.inventory_2_rounded;
      case TaskCategory.pets:
        return Icons.pets_rounded;
      case TaskCategory.shopping:
        return Icons.shopping_cart_rounded;
      case TaskCategory.other:
        return Icons.task_rounded;
    }
  }

  Color _getCategoryColor() {
    switch (task.category) {
      case TaskCategory.cleaning:
        return Colors.blue;
      case TaskCategory.kitchen:
        return Colors.orange;
      case TaskCategory.laundry:
        return Colors.purple;
      case TaskCategory.garden:
        return Colors.green;
      case TaskCategory.organization:
        return Colors.teal;
      case TaskCategory.pets:
        return Colors.pink;
      case TaskCategory.shopping:
        return Colors.indigo;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onComplete,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.categoryName,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.frequencyName,
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.description!,
                          style: AppTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
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
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${task.points}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletedTaskCard extends StatelessWidget {
  final TaskModel task;
  final TaskCompletionModel completion;
  final String userName;

  const _CompletedTaskCard({
    required this.task,
    required this.completion,
    required this.userName,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (diff.inHours < 1) {
      return 'Há ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Há ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Há ${diff.inDays} dias';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successColor,
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      userName,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${_formatDate(completion.completedAt)}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                if (completion.notes != null && completion.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    completion.notes!,
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${completion.pointsEarned}',
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
