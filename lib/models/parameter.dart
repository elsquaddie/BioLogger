/// Represents a parameter that can be tracked in the bio logging system
class Parameter {
  /// Unique identifier for the parameter, null when creating new parameter
  final int? id;

  /// Name of the parameter (e.g., "Sleep", "Weight", "Mood")
  final String name;

  /// Type of data this parameter stores ("Number", "Text", "Rating", "Yes/No", "Time", "Date")
  final String dataType;

  /// Optional unit of measurement (e.g., "hours", "%", "kg")
  final String? unit;

  /// Optional list of possible values for "Rating" type parameters (e.g., ["1", "2", "3", "4", "5"])
  final List<String>? scaleOptions;

  /// Constructor for creating a Parameter instance
  Parameter({
    this.id,
    required this.name,
    required this.dataType,
    this.unit,
    this.scaleOptions,
  });

  /// Converts Parameter instance to JSON format for storage or export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data_type': dataType, // <--- ИЗМЕНЕНО: ключ теперь 'data_type' (snake_case)
      'unit': unit,
      'scaleOptions': scaleOptions,
    };
  }

  /// Creates a Parameter instance from JSON data
  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      id: json['id'] as int?,
      name: json['name'] as String,
      dataType: json['data_type'] as String? ?? '', // Changed from 'dataType' to 'data_type' to match DB column
      unit: json['unit'] as String? ?? '',
      scaleOptions: json['scale_options'] != null  // Changed from 'scaleOptions' to 'scale_options'
          ? List<String>.from(json['scale_options'])
          : null,
    );
  }

  /// Creates a copy of Parameter with optional field updates
  Parameter copyWith({
    int? id,
    String? name,
    String? dataType,
    String? unit,
    List<String>? scaleOptions,
  }) {
    return Parameter(
      id: id ?? this.id,
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      unit: unit ?? this.unit,
      scaleOptions: scaleOptions ?? this.scaleOptions,
    );
  }
}