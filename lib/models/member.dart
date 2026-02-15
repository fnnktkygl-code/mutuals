import 'fit_preference.dart';
import 'wardrobe_item.dart';
import 'monthly_wish.dart';

class Member {
  final String id;
  final String name;
  final String relationship;
  // groupIds removed
  final String gradient;
  final FitPreference fitPreference;
  final bool isOwner;

  // Wardrobe items
  final List<WardrobeItem> tops;
  final List<WardrobeItem> bottoms;
  final List<WardrobeItem> shoes;
  final List<WardrobeItem> accessories;

  // Favorite brands
  final String topBrands;
  final String bottomBrands;
  final String shoeBrands;

  // Wishes
  final List<String> wishlist;
  final List<MonthlyWish> wishHistory;

  // General sizes
  final String generalTopSize;
  final String generalBottomSize;
  final String generalShoeSize;

  // New v4.0 Fields
  final DateTime? birthday;
  final String avatarType;
  final String avatarValue;
  final String? avatarCharacterId;
  final String? avatarBackgroundColor;

  // New v5.0 Fields
  final DateTime? lastUpdated;
  final Map<String, bool> shareAccess;

  // New v8.0 Fields
  final List<String> tags;
  final DateTime? lastContacted;

  // New v11.0 Fields - Structured Address
  final String addressStreet;
  final String addressCity;
  final String addressCountry;
  final String addressVisibility;

  // New v12.0 Fields - Mondial Relay
  final String? pickupPointId;
  final String? pickupPointName;
  final String? pickupPointAddress;

  // New v13.0 Fields - Privacy/Isolation
  final String? ownerId; // IF SET: managed by this user (Restricted Profile)
  final List<String> sharedWith; // List of user IDs who can also see this profile

  Member({
    required this.id,
    required this.name,
    this.relationship = '',
    required this.gradient,
    this.avatarType = 'gradient',
    this.avatarValue = 'from-purple-400 to-purple-600',
    this.avatarCharacterId,
    this.avatarBackgroundColor,
    this.birthday,
    this.tags = const [],
    this.fitPreference = FitPreference.regular,
    // groupIds removed
    this.shareAccess = const {'age': true, 'sizes': true},
    this.lastUpdated,
    this.isOwner = false,
    this.tops = const [],
    this.bottoms = const [],
    this.shoes = const [],
    this.accessories = const [],
    this.topBrands = '',
    this.bottomBrands = '',
    this.shoeBrands = '',
    this.wishlist = const [],
    this.wishHistory = const [],
    this.generalTopSize = '',
    this.generalBottomSize = '',
    this.generalShoeSize = '',
    this.lastContacted,
    this.addressStreet = '',
    this.addressCity = '',
    this.addressCountry = '',
    this.addressVisibility = 'family',
    this.pickupPointId,
    this.pickupPointName,
    this.pickupPointAddress,
    this.ownerId,
    this.sharedWith = const [],
  });

  /// Check if a user can view this profile
  bool canView(String userId) {
    if (ownerId == null) return true; // Public family member
    if (ownerId == userId) return true; // Owner/Manager
    if (sharedWith.contains(userId)) return true; // Shared with user
    return false; // Restricted
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      // groupIds removed
      'gradient': gradient, // Kept for backward compatibility
      'fitPreference': fitPreference.toJson(),
      'isOwner': isOwner,
      'tops': tops.map((item) => item.toJson()).toList(),
      'bottoms': bottoms.map((item) => item.toJson()).toList(),
      'shoes': shoes.map((item) => item.toJson()).toList(),
      'accessories': accessories.map((item) => item.toJson()).toList(),
      'topBrands': topBrands,
      'bottomBrands': bottomBrands,
      'shoeBrands': shoeBrands,
      'wishlist': wishlist,
      'wishHistory': wishHistory.map((wish) => wish.toJson()).toList(),
      'generalTopSize': generalTopSize,
      'generalBottomSize': generalBottomSize,
      'generalShoeSize': generalShoeSize,
      'birthday': birthday?.toIso8601String(),
      'avatarType': avatarType,
      'avatarValue': avatarValue,
      if (avatarCharacterId != null) 'avatarCharacterId': avatarCharacterId,
      if (avatarBackgroundColor != null) 'avatarBackgroundColor': avatarBackgroundColor,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'shareAccess': shareAccess,
      'tags': tags,
      'lastContacted': lastContacted?.toIso8601String(),
      'addressStreet': addressStreet,
      'addressCity': addressCity,
      'addressCountry': addressCountry,
      'addressVisibility': addressVisibility,
      if (pickupPointId != null) 'pickupPointId': pickupPointId,
      if (pickupPointName != null) 'pickupPointName': pickupPointName,
      if (pickupPointAddress != null) 'pickupPointAddress': pickupPointAddress,
      if (ownerId != null) 'ownerId': ownerId,
    };
  }

  // Helper methods
  int get age {
    if (birthday == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month || (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  int get daysUntilBirthday {
    if (birthday == null) return 365;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextBirthday = DateTime(today.year, birthday!.month, birthday!.day);
    
    if (nextBirthday.isBefore(today)) {
      final nextYearBirthday = DateTime(today.year + 1, birthday!.month, birthday!.day);
      return nextYearBirthday.difference(today).inDays;
    }
    return nextBirthday.difference(today).inDays;
  }

  /// Profile completion as a 0.0–1.0 value.
  double get completionPercentage {
    int filled = 0;
    const total = 8;
    if (name.trim().isNotEmpty) filled++;
    if (birthday != null) filled++;
    if (relationship.isNotEmpty && relationship != 'Membre') filled++;
    if (avatarType != 'gradient' || avatarValue != 'from-purple-400 to-purple-600') filled++;
    if (generalTopSize.isNotEmpty) filled++;
    if (generalBottomSize.isNotEmpty) filled++;
    if (generalShoeSize.isNotEmpty) filled++;
    if (wishHistory.isNotEmpty) filled++;
    return filled / total;
  }

  /// List of missing profile fields (French labels).
  List<String> get missingFields {
    final missing = <String>[];
    if (name.trim().isEmpty) missing.add('Prénom');
    if (birthday == null) missing.add('Anniversaire');
    if (relationship.isEmpty || relationship == 'Membre') missing.add('Relation');
    if (avatarType == 'gradient' && avatarValue == 'from-purple-400 to-purple-606') missing.add('Avatar');
    if (generalTopSize.isEmpty) missing.add('Taille haut');
    if (generalBottomSize.isEmpty) missing.add('Taille bas');
    if (generalShoeSize.isEmpty) missing.add('Pointure');
    if (wishHistory.isEmpty) missing.add('Envie du mois');
    return missing;
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      // groupIds removed
      gradient: json['gradient'] ?? 'from-purple-400 to-purple-600',
      fitPreference: FitPreference.fromJson(json['fitPreference'] ?? 'regular'),
      isOwner: json['isOwner'] ?? false,
      tops: (json['tops'] as List?)?.map((item) => WardrobeItem.fromJson(item)).toList() ?? [],
      bottoms: (json['bottoms'] as List?)?.map((item) => WardrobeItem.fromJson(item)).toList() ?? [],
      shoes: (json['shoes'] as List?)?.map((item) => WardrobeItem.fromJson(item)).toList() ?? [],
      accessories: (json['accessories'] as List?)?.map((item) => WardrobeItem.fromJson(item)).toList() ?? [],
      topBrands: json['topBrands'] ?? '',
      bottomBrands: json['bottomBrands'] ?? '',
      shoeBrands: json['shoeBrands'] ?? '',
      wishlist: (json['wishlist'] as List?)?.map((item) => item.toString()).toList() ?? [],
      wishHistory: (json['wishHistory'] as List?)?.map((wish) => MonthlyWish.fromJson(wish)).toList() ?? [],
      generalTopSize: json['generalTopSize'] ?? '',
      generalBottomSize: json['generalBottomSize'] ?? '',
      generalShoeSize: json['generalShoeSize'] ?? '',
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      avatarType: json['avatarType'] ?? 'gradient',
      avatarValue: json['avatarValue'] ?? (json['gradient'] ?? 'from-purple-400 to-purple-600'),
      avatarCharacterId: json['avatarCharacterId'],
      avatarBackgroundColor: json['avatarBackgroundColor'],
      lastUpdated: json['lastUpdated'] != null ? DateTime.tryParse(json['lastUpdated']) : null,
      shareAccess: json['shareAccess'] != null ? Map<String, bool>.from(json['shareAccess']) : {'age': true, 'sizes': true},
      tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      lastContacted: json['lastContacted'] != null ? DateTime.tryParse(json['lastContacted']) : null,
      addressStreet: json['addressStreet'] ?? json['deliveryAddress'] ?? '',
      addressCity: json['addressCity'] ?? '',
      addressCountry: json['addressCountry'] ?? '',
      addressVisibility: json['addressVisibility'] ?? 'full',
      pickupPointId: json['pickupPointId'],
      pickupPointName: json['pickupPointName'],
      pickupPointAddress: json['pickupPointAddress'],
      ownerId: json['ownerId'],
      sharedWith: (json['sharedWith'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Member copyWith({
    String? id,
    String? name,
    String? relationship,
    // groupIds removed
    String? gradient,
    FitPreference? fitPreference,
    bool? isOwner,
    List<WardrobeItem>? tops,
    List<WardrobeItem>? bottoms,
    List<WardrobeItem>? shoes,
    List<WardrobeItem>? accessories,
    String? topBrands,
    String? bottomBrands,
    String? shoeBrands,
    List<String>? wishlist,
    List<MonthlyWish>? wishHistory,
    String? generalTopSize,
    String? generalBottomSize,
    String? generalShoeSize,
    DateTime? birthday,
    String? avatarType,
    String? avatarValue,
    String? avatarCharacterId,
    String? avatarBackgroundColor,
    DateTime? lastUpdated,
    Map<String, bool>? shareAccess,
    List<String>? tags,
    DateTime? lastContacted,
    String? addressStreet,
    String? addressCity,
    String? addressCountry,
    String? addressVisibility,
    String? pickupPointId,
    String? pickupPointName,
    String? pickupPointAddress,
    String? ownerId,
    List<String>? sharedWith,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      // groupIds removed
      gradient: gradient ?? this.gradient,
      fitPreference: fitPreference ?? this.fitPreference,
      isOwner: isOwner ?? this.isOwner,
      tops: tops ?? this.tops,
      bottoms: bottoms ?? this.bottoms,
      shoes: shoes ?? this.shoes,
      accessories: accessories ?? this.accessories,
      topBrands: topBrands ?? this.topBrands,
      bottomBrands: bottomBrands ?? this.bottomBrands, // Fixed potential bug in original copyWith
      shoeBrands: shoeBrands ?? this.shoeBrands, // Fixed potential bug in original copyWith
      
      wishlist: wishlist ?? this.wishlist,
      wishHistory: wishHistory ?? this.wishHistory,
      generalTopSize: generalTopSize ?? this.generalTopSize,
      generalBottomSize: generalBottomSize ?? this.generalBottomSize,
      generalShoeSize: generalShoeSize ?? this.generalShoeSize,
      birthday: birthday ?? this.birthday,
      avatarType: avatarType ?? this.avatarType,
      avatarValue: avatarValue ?? this.avatarValue,
      avatarCharacterId: avatarCharacterId ?? this.avatarCharacterId,
      avatarBackgroundColor: avatarBackgroundColor ?? this.avatarBackgroundColor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      shareAccess: shareAccess ?? this.shareAccess,
      tags: tags ?? this.tags,
      lastContacted: lastContacted ?? this.lastContacted,
      addressStreet: addressStreet ?? this.addressStreet,
      addressCity: addressCity ?? this.addressCity,
      addressCountry: addressCountry ?? this.addressCountry,
      addressVisibility: addressVisibility ?? this.addressVisibility,
      pickupPointId: pickupPointId ?? this.pickupPointId,
      pickupPointName: pickupPointName ?? this.pickupPointName,
      pickupPointAddress: pickupPointAddress ?? this.pickupPointAddress,
      ownerId: ownerId ?? this.ownerId,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }
}
