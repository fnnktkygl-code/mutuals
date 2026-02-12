/// Represents a family unit that shares data across devices
class Family {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy; // Firebase UID
  final DateTime createdAt;
  final List<String> memberUids; // Firebase UIDs of family members

  const Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    this.memberUids = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'memberUids': memberUids,
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
    );
  }

  Family copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberUids,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberUids: memberUids ?? this.memberUids,
    );
  }
}
