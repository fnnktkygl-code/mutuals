class WardrobeItem {
  final String type;
  final String size;
  final String brandNote;
  final String sizeNote; // Context-specific notes (e.g., "Prefer S for jackets")
  final String? waist; // For bottoms (e.g., "32")
  final String? length; // For bottoms (e.g., "34")
  final String? shoeSizeCm; // Shoe size in cm (e.g., "26.5")

  WardrobeItem({
    required this.type,
    required this.size,
    this.brandNote = '',
    this.sizeNote = '',
    this.waist,
    this.length,
    this.shoeSizeCm,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'size': size,
      'brandNote': brandNote,
      'sizeNote': sizeNote,
      if (waist != null) 'waist': waist,
      if (length != null) 'length': length,
      if (shoeSizeCm != null) 'shoeSizeCm': shoeSizeCm,
    };
  }

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      type: json['type'] ?? '',
      size: json['size'] ?? '',
      brandNote: json['brandNote'] ?? '',
      sizeNote: json['sizeNote'] ?? '',
      waist: json['waist'],
      length: json['length'],
      shoeSizeCm: json['shoeSizeCm'],
    );
  }

  WardrobeItem copyWith({
    String? type,
    String? size,
    String? brandNote,
    String? sizeNote,
    String? waist,
    String? length,
    String? shoeSizeCm,
  }) {
    return WardrobeItem(
      type: type ?? this.type,
      size: size ?? this.size,
      brandNote: brandNote ?? this.brandNote,
      sizeNote: sizeNote ?? this.sizeNote,
      waist: waist ?? this.waist,
      length: length ?? this.length,
      shoeSizeCm: shoeSizeCm ?? this.shoeSizeCm,
    );
  }
}
