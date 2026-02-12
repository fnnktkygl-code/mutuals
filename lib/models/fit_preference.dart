enum FitPreference {
  slim,
  regular,
  oversize;

  String get label {
    switch (this) {
      case FitPreference.slim:
        return 'Slim';
      case FitPreference.regular:
        return 'Regular';
      case FitPreference.oversize:
        return 'Oversize';
    }
  }

  String toJson() => name;
  
  static FitPreference fromJson(String json) {
    return FitPreference.values.firstWhere(
      (e) => e.name == json,
      orElse: () => FitPreference.regular,
    );
  }
}
