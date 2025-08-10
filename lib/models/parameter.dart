import 'dart:convert';

/// Represents a parameter that can be tracked in the bio logging system
class Parameter {
  /// Unique identifier for the parameter, null when creating new parameter
  final int? id;

  /// Name of the parameter (e.g., "Sleep", "Weight", "Mood")
  final String name;

  /// Type of data this parameter stores ("Number", "Text", "Rating", "YesNo")
  /// Note: "Date" and "Time" types removed as per requirements
  final String dataType;

  /// Optional unit of measurement (e.g., "hours", "%", "kg")
  final String? unit;

  /// Optional list of possible values for "Rating" type parameters (e.g., ["1", "2", "3", "4", "5"])
  final List<String>? scaleOptions;

  /// Whether this parameter is a preset (default) parameter
  final bool isPreset;

  /// Whether this parameter is currently enabled/active
  final bool isEnabled;

  /// Sort order for displaying parameters (lower numbers first)
  final int sortOrder;

  /// Icon name for preset parameters (e.g., "bedtime", "medication")
  final String? iconName;

  /// When this parameter was created
  final DateTime createdAt;

  /// Constructor for creating a Parameter instance
  Parameter({
    this.id,
    required this.name,
    required this.dataType,
    this.unit,
    this.scaleOptions,
    this.isPreset = false,
    this.isEnabled = true,
    this.sortOrder = 0,
    this.iconName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converts Parameter instance to JSON format for storage or export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data_type': dataType,
      'unit': unit,
      'scale_options': scaleOptions == null ? null : jsonEncode(scaleOptions),
      'is_preset': isPreset ? 1 : 0,
      'is_enabled': isEnabled ? 1 : 0,
      'sort_order': sortOrder,
      'icon_name': iconName,
      // Убираем created_at временно для совместимости
    };
  }
  
  /// Converts Parameter instance to JSON format for database insert without created_at field
  Map<String, dynamic> toJsonForInsert() {
    return {
      'id': id,
      'name': name,
      'data_type': dataType,
      'unit': unit,
      'scale_options': scaleOptions == null ? null : jsonEncode(scaleOptions),
      'is_preset': isPreset ? 1 : 0,
      'is_enabled': isEnabled ? 1 : 0,
      'sort_order': sortOrder,
      'icon_name': iconName,
    };
  }

  /// Creates a Parameter instance from JSON data
  factory Parameter.fromJson(Map<String, dynamic> json) {
    List<String>? decodedScaleOptions;
    final scaleOptionsJson = json['scale_options'];

    if (scaleOptionsJson != null && scaleOptionsJson is String && scaleOptionsJson.isNotEmpty) {
      try {
        final decodedList = jsonDecode(scaleOptionsJson);
        if (decodedList is List) {
          decodedScaleOptions = List<String>.from(decodedList.map((item) => item.toString()));
        }
      } catch (e) {
        print("Ошибка декодирования scale_options JSON: $e, JSON: $scaleOptionsJson");
      }
    }

    return Parameter(
      id: json['id'] as int?,
      name: json['name'] as String,
      dataType: json['data_type'] as String? ?? '',
      unit: json['unit'] as String?,
      scaleOptions: decodedScaleOptions,
      isPreset: (json['is_preset'] as int?) == 1,
      isEnabled: (json['is_enabled'] as int?) != 0, // Default to true if null
      sortOrder: json['sort_order'] as int? ?? 0,
      iconName: json['icon_name'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Creates a copy of Parameter with optional field updates
  Parameter copyWith({
    int? id,
    String? name,
    String? dataType,
    String? unit,
    List<String>? scaleOptions,
    bool? isPreset,
    bool? isEnabled,
    int? sortOrder,
    String? iconName,
    DateTime? createdAt,
  }) {
    return Parameter(
      id: id ?? this.id,
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      unit: unit ?? this.unit,
      scaleOptions: scaleOptions ?? this.scaleOptions,
      isPreset: isPreset ?? this.isPreset,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Parameter(id: $id, name: $name, dataType: $dataType, isPreset: $isPreset, isEnabled: $isEnabled, sortOrder: $sortOrder)';
  }
}