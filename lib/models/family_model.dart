/// Represents a family unit that shares data across devices
class Family {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberUids;
  final String? emoji; // v2
  final String? background; // v2
  final bool isPersonal; // v3

  const Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    this.memberUids = const [],
    this.emoji,
    this.background,
    this.isPersonal = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'memberUids': memberUids,
      if (emoji != null) 'emoji': emoji,
      if (background != null) 'background': background,
      'isPersonal': isPersonal,
    };
  }

  factory Family.fromJson(String id, Map<String, dynamic> json) {
    return Family(
      id: id,
      name: json['name'] ?? '',
      inviteCode: json['inviteCode'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      memberUids: List<String>.from(json['memberUids'] ?? []),
      emoji: json['emoji'],
      background: json['background'],
      isPersonal: json['isPersonal'] ?? false,
    );
  }

  factory Family.fromMap(Map<String, dynamic> map) {
    return Family(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      memberUids: List<String>.from(map['memberUids'] ?? []),
      emoji: map['emoji'],
      background: map['background'],
      isPersonal: map['isPersonal'] ?? false,
    );
  }

  Family copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberUids,
    String? emoji,
    String? background,
    bool? isPersonal,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberUids: memberUids ?? this.memberUids,
      emoji: emoji ?? this.emoji,
      background: background ?? this.background,
      isPersonal: isPersonal ?? this.isPersonal,
    );
  }
}
