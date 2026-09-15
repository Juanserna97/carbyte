class DTCModel {
  final String code;
  final String description;
  final String severity;
  final String system;
  final DateTime? timestamp;

  const DTCModel({
    required this.code,
    required this.description,
    required this.severity,
    required this.system,
    this.timestamp,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'severity': severity,
      'system': system,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  DTCModel copyWith({
    String? code,
    String? description,
    String? severity,
    String? system,
    DateTime? timestamp,
  }) {
    return DTCModel(
      code: code ?? this.code,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      system: system ?? this.system,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
