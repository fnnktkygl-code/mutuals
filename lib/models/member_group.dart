import 'package:uuid/uuid.dart';

/// Represents a custom group/category for organizing members
class MemberGroup {
  final String id; // UUID for unique identification
  final String name; // Display name (e.g., "Famille", "Collègues")
  final String icon; // Emoji character (e.g., "❤️", "💼")
  final String color; // Hex color (e.g., "#EF4444")
  final String? ownerId; // If null, visible to everyone. If set, private to that user.
  final int order; // Sort order for display
  final bool isDefault; // Cannot be deleted if true

  const MemberGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
    this.isDefault = false,
    this.ownerId,
  });

  /// Create default groups for new installations
  static List<MemberGroup> createDefaults() {
    const uuid = Uuid();
    return [
      MemberGroup(
        id: uuid.v4(),
        name: 'Le Sang',
        icon: '🩸',
        color: '#EF4444',
        order: 0,
        isDefault: true,
        ownerId: null, // Shared/System default
      ),
      MemberGroup(
        id: uuid.v4(),
        name: 'Amis',
        icon: '🤞',
        color: '#3B82F6',
        order: 1,
        isDefault: true,
        ownerId: null,
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'order': order,
      'isDefault': isDefault,
      if (ownerId != null) 'ownerId': ownerId,
    };
  }

  factory MemberGroup.fromJson(Map<String, dynamic> json) {
    return MemberGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '⭐',
      color: json['color'] ?? '#6366F1',
      order: json['order'] ?? 0,
      isDefault: json['isDefault'] ?? false,
      ownerId: json['ownerId'],
    );
  }

  MemberGroup copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    int? order,
    bool? isDefault,
    String? ownerId,
  }) {
    return MemberGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      isDefault: isDefault ?? this.isDefault,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberGroup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
