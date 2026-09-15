class DTCModel {
  final String code;
  final String description;
  final String severity;
  final String system;
  final DateTime? timestamp;
  final List<String> probableCauses;
  final List<String> symptoms;
  final String recommendedAction;

  const DTCModel({
    required this.code,
    required this.description,
    required this.severity,
    required this.system,
    this.timestamp,
    this.probableCauses = const [],
    this.symptoms = const [],
    this.recommendedAction = '',
  });

  factory DTCModel.fromJson(Map<String, dynamic> json) {
    return DTCModel(
      code: json['code'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      system: json['system'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      probableCauses: (json['probableCauses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recommendedAction: (json['recommendedAction'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'severity': severity,
      'system': system,
      'timestamp': timestamp?.toIso8601String(),
      'probableCauses': probableCauses,
      'symptoms': symptoms,
      'recommendedAction': recommendedAction,
    };
  }

  DTCModel copyWith({
    String? code,
    String? description,
    String? severity,
    String? system,
    DateTime? timestamp,
    List<String>? probableCauses,
    List<String>? symptoms,
    String? recommendedAction,
  }) {
    return DTCModel(
      code: code ?? this.code,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      system: system ?? this.system,
      timestamp: timestamp ?? this.timestamp,
      probableCauses: probableCauses ?? this.probableCauses,
      symptoms: symptoms ?? this.symptoms,
      recommendedAction: recommendedAction ?? this.recommendedAction,
    );
  }
}
