class GroupModel {
  final String id;
  final String name;
  final String code;
  final String adminId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime weekStartDate;

  GroupModel({
    required this.id,
    required this.name,
    required this.code,
    required this.adminId,
    this.memberIds = const [],
    DateTime? createdAt,
    DateTime? weekStartDate,
  })  : createdAt = createdAt ?? DateTime.now(),
        weekStartDate = weekStartDate ?? _getWeekStart(DateTime.now());

  static DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return DateTime(date.year, date.month, date.day - (dayOfWeek - 1));
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? code,
    String? adminId,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? weekStartDate,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      adminId: adminId ?? this.adminId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      weekStartDate: weekStartDate ?? this.weekStartDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'adminId': adminId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'weekStartDate': weekStartDate.toIso8601String(),
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      adminId: json['adminId'] as String,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      weekStartDate: json['weekStartDate'] != null
          ? DateTime.parse(json['weekStartDate'] as String)
          : null,
    );
  }
}
