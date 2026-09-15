class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String vin;
  final bool isConnected;
  final int? activeIssues;

  const VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    this.isConnected = false,
    this.activeIssues,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      vin: json['vin'] as String,
      isConnected: json['isConnected'] as bool? ?? false,
      activeIssues: json['activeIssues'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'isConnected': isConnected,
      'activeIssues': activeIssues,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? vin,
    bool? isConnected,
    int? activeIssues,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      isConnected: isConnected ?? this.isConnected,
      activeIssues: activeIssues ?? this.activeIssues,
    );
  }
}
