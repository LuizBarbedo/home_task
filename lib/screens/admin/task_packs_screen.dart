import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/task_packs.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';

class TaskPacksScreen extends StatefulWidget {
  const TaskPacksScreen({super.key});

  @override
  State<TaskPacksScreen> createState() => _TaskPacksScreenState();
}

class _TaskPacksScreenState extends State<TaskPacksScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacotes de Tarefas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: TaskPacks.all.length,
        itemBuilder: (context, index) {
          final pack = TaskPacks.all[index];
          final packColor = Color(pack.colorValue);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceColorDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.dividerColorDark : AppTheme.dividerColor,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openPackDetail(pack),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: packColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(pack.icon),
                          color: packColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pack.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pack.tasks.length} tarefas disponíveis',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openPackDetail(TaskPack pack) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PackDetailScreen(pack: pack),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'weekend':
        return Icons.weekend_rounded;
      case 'bed':
        return Icons.bed_rounded;
      case 'bathtub':
        return Icons.bathtub_rounded;
      case 'local_laundry_service':
        return Icons.local_laundry_service_rounded;
      case 'yard':
        return Icons.yard_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'pets':
        return Icons.pets_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class _PackDetailScreen extends StatefulWidget {
  final TaskPack pack;

  const _PackDetailScreen({required this.pack});

  @override
  State<_PackDetailScreen> createState() => _PackDetailScreenState();
}

class _PackDetailScreenState extends State<_PackDetailScreen> {
  late List<bool> _selectedTasks;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _selectedTasks = List.filled(widget.pack.tasks.length, true);
  }

  int get _selectedCount => _selectedTasks.where((s) => s).length;

  bool get _allSelected => _selectedTasks.every((s) => s);

  void _toggleAll() {
    setState(() {
      final newValue = !_allSelected;
      _selectedTasks = List.filled(widget.pack.tasks.length, newValue);
    });
  }

  Future<void> _addSelectedTasks() async {
    final appState = context.read<AppState>();
    final selectedItems = <TaskPackItem>[];

    for (int i = 0; i < widget.pack.tasks.length; i++) {
      if (_selectedTasks[i]) {
        selectedItems.add(widget.pack.tasks[i]);
      }
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma tarefa'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isAdding = true);

    int added = 0;
    for (final item in selectedItems) {
      final success = await appState.createTask(
        title: item.title,
        description: item.description,
        category: item.category,
        frequency: item.frequency,
        points: item.points,
      );
      if (success) added++;
    }

    setState(() => _isAdding = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$added tarefa${added != 1 ? 's' : ''} adicionada${added != 1 ? 's' : ''}!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final packColor = Color(widget.pack.colorValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pack.name),
        actions: [
          TextButton(
            onPressed: _toggleAll,
            child: Text(_allSelected ? 'Desmarcar todos' : 'Selecionar todos'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  packColor,
                  packColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconData(widget.pack.icon),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pack.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_selectedCount de ${widget.pack.tasks.length} selecionadas',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.pack.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.pack.tasks[index];
                final isSelected = _selectedTasks[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceColorDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? packColor.withValues(alpha: 0.5)
                          : isDark
                              ? AppTheme.dividerColorDark
                              : AppTheme.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        _selectedTasks[index] = value ?? false;
                      });
                    },
                    activeColor: packColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? null
                            : isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description!,
                            style: AppTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _TagChip(
                              label: _getCategoryName(task.category),
                              color: packColor,
                            ),
                            const SizedBox(width: 6),
                            _TagChip(
                              label: _getFrequencyName(task.frequency),
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: AppTheme.warningColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${task.points} pts',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceColorDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAdding || _selectedCount == 0
                      ? null
                      : _addSelectedTasks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: packColor,
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Adicionar $_selectedCount tarefa${_selectedCount != 1 ? 's' : ''}',
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'weekend':
        return Icons.weekend_rounded;
      case 'bed':
        return Icons.bed_rounded;
      case 'bathtub':
        return Icons.bathtub_rounded;
      case 'local_laundry_service':
        return Icons.local_laundry_service_rounded;
      case 'yard':
        return Icons.yard_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'pets':
        return Icons.pets_rounded;
      default:
        return Icons.category_rounded;
    }
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

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
