enum WishStatus {
  pending,
  gifted;

  String toJson() => name;
  
  static WishStatus fromJson(String json) {
    return WishStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => WishStatus.pending,
    );
  }
}

class MonthlyWish {
  final String monthKey; // Format: YYYY-MM
  final String text;
  final WishStatus status;

  MonthlyWish({
    required this.monthKey,
    required this.text,
    this.status = WishStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'monthKey': monthKey,
      'text': text,
      'status': status.toJson(),
    };
  }

  factory MonthlyWish.fromJson(Map<String, dynamic> json) {
    return MonthlyWish(
      monthKey: json['monthKey'] ?? '',
      text: json['text'] ?? '',
      status: WishStatus.fromJson(json['status'] ?? 'pending'),
    );
  }

  MonthlyWish copyWith({
    String? monthKey,
    String? text,
    WishStatus? status,
  }) {
    return MonthlyWish(
      monthKey: monthKey ?? this.monthKey,
      text: text ?? this.text,
      status: status ?? this.status,
    );
  }
}
