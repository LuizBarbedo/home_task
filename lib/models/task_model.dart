enum TaskCategory {
  cleaning,
  kitchen,
  laundry,
  garden,
  organization,
  pets,
  shopping,
  other,
}

enum TaskFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  once,
}

class TaskModel {
  final String id;
  final String groupId;
  final String title;
  final String? description;
  final TaskCategory category;
  final TaskFrequency frequency;
  final int points;
  final String createdBy;
  final DateTime createdAt;
  final bool isActive;

  TaskModel({
    required this.id,
    required this.groupId,
    required this.title,
    this.description,
    required this.category,
    required this.frequency,
    required this.points,
    required this.createdBy,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    TaskCategory? category,
    TaskFrequency? frequency,
    int? points,
    String? createdBy,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return TaskModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      points: points ?? this.points,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'category': category.index,
      'frequency': frequency.index,
      'points': points,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: TaskCategory.values[json['category'] as int],
      frequency: TaskFrequency.values[json['frequency'] as int],
      points: json['points'] as int,
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  String get categoryName {
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

  String get frequencyName {
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
