import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final group = appState.currentGroup;
        final members = appState.groupMembers;
        final tasks = appState.tasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Administração'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group?.name ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${members.length} membros',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Group Code
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.vpn_key_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Código do Grupo',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    group?.code ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: group?.code ?? ''),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Código copiado!'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.add_task_rounded,
                        label: 'Nova Tarefa',
                        color: AppTheme.successColor,
                        onTap: () => _showCreateTaskDialog(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.restart_alt_rounded,
                        label: 'Resetar Semana',
                        color: AppTheme.warningColor,
                        onTap: () => _showResetConfirmDialog(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Tasks Management
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tarefas',
                      style: AppTheme.headingSmall,
                    ),
                    TextButton.icon(
                      onPressed: () => _showCreateTaskDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
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
                            'Crie tarefas para sua família',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...tasks.map((task) => _TaskManageCard(task: task)),
                const SizedBox(height: 24),
                // Members Management
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Membros',
                      style: AppTheme.headingSmall,
                    ),
                    Text(
                      '${members.length} pessoas',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...members.map((member) => _MemberCard(
                      member: member,
                      isAdmin: member.id == group?.adminId,
                      isCurrentUser: member.id == appState.currentUser?.id,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final pointsController = TextEditingController(text: '10');
    TaskCategory selectedCategory = TaskCategory.cleaning;
    TaskFrequency selectedFrequency = TaskFrequency.daily;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nova Tarefa',
                      style: AppTheme.headingSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Tarefa',
                        hintText: 'Ex: Lavar a louça',
                        prefixIcon: Icon(Icons.task_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        hintText: 'Detalhes da tarefa...',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Dropdown
                    DropdownButtonFormField<TaskCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: TaskCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryName(category)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Frequency Dropdown
                    DropdownButtonFormField<TaskFrequency>(
                      value: selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequência',
                        prefixIcon: Icon(Icons.repeat_outlined),
                      ),
                      items: TaskFrequency.values.map((frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(_getFrequencyName(frequency)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedFrequency = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Points Field
                    TextFormField(
                      controller: pointsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Pontos',
                        hintText: '10',
                        prefixIcon: Icon(Icons.star_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<AppState>(
                      builder: (context, appState, child) {
                        return ElevatedButton(
                          onPressed: appState.isLoading
                              ? null
                              : () async {
                                  if (titleController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Digite o nome da tarefa'),
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                    );
                                    return;
                                  }

                                  final points =
                                      int.tryParse(pointsController.text) ?? 10;

                                  final success = await appState.createTask(
                                    title: titleController.text.trim(),
                                    description:
                                        descriptionController.text.isNotEmpty
                                            ? descriptionController.text.trim()
                                            : null,
                                    category: selectedCategory,
                                    frequency: selectedFrequency,
                                    points: points,
                                  );

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Tarefa criada!'),
                                          backgroundColor: AppTheme.successColor,
                                        ),
                                      );
                                    }
                                  }
                                },
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
                              : const Text('Criar Tarefa'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: AppTheme.warningColor),
              SizedBox(width: 12),
              Text('Resetar Semana'),
            ],
          ),
          content: const Text(
            'Isso irá zerar os pontos semanais de todos os membros. '
            'Essa ação não pode ser desfeita.\n\n'
            'Deseja continuar?',
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
                          await appState.resetWeeklyRanking();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ranking semanal resetado!'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor,
                  ),
                  child: const Text('Resetar'),
                );
              },
            ),
          ],
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

  String _getFrequencyName(TaskFrequency frequency) {
    switch (frequency) {
      case TaskFrequency.daily:
        return 'Diária';
      case TaskFrequency.weekly:
        return 'Semanal';
      case TaskFrequency.biweekly:
        return 'Quinzenal';
      case TaskFrequency.monthly:
        return 'Mensal';
      case TaskFrequency.once:
        return 'Única';
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
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

class _TaskManageCard extends StatelessWidget {
  final TaskModel task;

  const _TaskManageCard({required this.task});

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
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.categoryName,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${task.points} pts',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                _showEditTaskDialog(context, task);
              } else if (value == 'delete') {
                _showDeleteConfirmDialog(context, task);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, size: 20, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, TaskModel task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description ?? '');
    final pointsController = TextEditingController(text: task.points.toString());
    TaskCategory selectedCategory = task.category;
    TaskFrequency selectedFrequency = task.frequency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Editar Tarefa',
                      style: AppTheme.headingSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Tarefa',
                        prefixIcon: Icon(Icons.task_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: TaskCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryName(category)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskFrequency>(
                      value: selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequência',
                        prefixIcon: Icon(Icons.repeat_outlined),
                      ),
                      items: TaskFrequency.values.map((frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(_getFrequencyName(frequency)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedFrequency = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: pointsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Pontos',
                        prefixIcon: Icon(Icons.star_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<AppState>(
                      builder: (context, appState, child) {
                        return ElevatedButton(
                          onPressed: appState.isLoading
                              ? null
                              : () async {
                                  if (titleController.text.isEmpty) {
                                    return;
                                  }

                                  final points =
                                      int.tryParse(pointsController.text) ?? task.points;

                                  final updatedTask = task.copyWith(
                                    title: titleController.text.trim(),
                                    description: descriptionController.text.isNotEmpty
                                        ? descriptionController.text.trim()
                                        : null,
                                    category: selectedCategory,
                                    frequency: selectedFrequency,
                                    points: points,
                                  );

                                  final success = await appState.updateTask(updatedTask);

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Tarefa atualizada!'),
                                          backgroundColor: AppTheme.successColor,
                                        ),
                                      );
                                    }
                                  }
                                },
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
                              : const Text('Salvar'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_outlined, color: AppTheme.errorColor),
              SizedBox(width: 12),
              Text('Excluir Tarefa'),
            ],
          ),
          content: Text(
            'Deseja excluir a tarefa "${task.title}"?\n\n'
            'Essa ação não pode ser desfeita.',
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
                          final success = await appState.deleteTask(task.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tarefa excluída!'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  child: const Text('Excluir'),
                );
              },
            ),
          ],
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

  String _getFrequencyName(TaskFrequency frequency) {
    switch (frequency) {
      case TaskFrequency.daily:
        return 'Diária';
      case TaskFrequency.weekly:
        return 'Semanal';
      case TaskFrequency.biweekly:
        return 'Quinzenal';
      case TaskFrequency.monthly:
        return 'Mensal';
      case TaskFrequency.once:
        return 'Única';
    }
  }
}

class _MemberCard extends StatelessWidget {
  final UserModel member;
  final bool isAdmin;
  final bool isCurrentUser;

  const _MemberCard({
    required this.member,
    this.isAdmin = false,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin ? AppTheme.primaryColor : AppTheme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isAdmin
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              member.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isAdmin ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: AppTheme.labelLarge,
                    ),
                    if (isAdmin) ...[
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
                          'Admin',
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
                Text(
                  member.email,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${member.weeklyPoints}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'esta semana',
                style: AppTheme.bodySmall.copyWith(fontSize: 10),
              ),
            ],
          ),
          if (!isAdmin && !isCurrentUser) ...[
            const SizedBox(width: 8),
            Consumer<AppState>(
              builder: (context, appState, child) {
                return IconButton(
                  onPressed: () => _showRemoveMemberDialog(context, member),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.errorColor,
                  ),
                  tooltip: 'Remover membro',
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, UserModel member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_remove_outlined, color: AppTheme.errorColor),
              SizedBox(width: 12),
              Text('Remover Membro'),
            ],
          ),
          content: Text(
            'Deseja remover "${member.name}" do grupo?\n\n'
            'O usuário poderá entrar novamente com o código do grupo.',
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
                          final success = await appState.removeMember(member.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Membro removido!'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  child: const Text('Remover'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
