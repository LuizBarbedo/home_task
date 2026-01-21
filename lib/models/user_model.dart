class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? groupId;
  final bool isAdmin;
  final int weeklyPoints;
  final int totalPoints;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.groupId,
    this.isAdmin = false,
    this.weeklyPoints = 0,
    this.totalPoints = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? groupId,
    bool? isAdmin,
    int? weeklyPoints,
    int? totalPoints,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      groupId: groupId ?? this.groupId,
      isAdmin: isAdmin ?? this.isAdmin,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'groupId': groupId,
      'isAdmin': isAdmin,
      'weeklyPoints': weeklyPoints,
      'totalPoints': totalPoints,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      groupId: json['groupId'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      weeklyPoints: json['weeklyPoints'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Supabase serialization (snake_case)
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'group_id': groupId,
      'is_admin': isAdmin,
      'weekly_points': weeklyPoints,
      'total_points': totalPoints,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromSupabase(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      groupId: json['group_id'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      weeklyPoints: json['weekly_points'] as int? ?? 0,
      totalPoints: json['total_points'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
