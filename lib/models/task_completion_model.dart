class TaskCompletionModel {
  final String id;
  final String taskId;
  final String userId;
  final String groupId;
  final int pointsEarned;
  final DateTime completedAt;
  final String? notes;
  final String? photoUrl;

  TaskCompletionModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.groupId,
    required this.pointsEarned,
    DateTime? completedAt,
    this.notes,
    this.photoUrl,
  }) : completedAt = completedAt ?? DateTime.now();

  TaskCompletionModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? groupId,
    int? pointsEarned,
    DateTime? completedAt,
    String? notes,
    String? photoUrl,
  }) {
    return TaskCompletionModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'groupId': groupId,
      'pointsEarned': pointsEarned,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
      'photoUrl': photoUrl,
    };
  }

  factory TaskCompletionModel.fromJson(Map<String, dynamic> json) {
    return TaskCompletionModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      groupId: json['groupId'] as String,
      pointsEarned: json['pointsEarned'] as int,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
