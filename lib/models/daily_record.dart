/// Represents a daily record containing values for tracked parameters
class DailyRecord {
  /// Unique identifier for the record, null when creating new record
  final int? id;
  
  /// Date when this record was created
  final DateTime date;
  
  /// Map storing parameter values where:
  /// - key is parameter.id.toString()
  /// - value is the user input (type depends on parameter.dataType)
  final Map<String, dynamic> dataValues;

  /// Constructor for creating a DailyRecord instance
  DailyRecord({
    this.id,
    required this.date,
    required this.dataValues,
  });

  /// Converts DailyRecord instance to JSON format for storage or export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'dataValues': dataValues,
    };
  }

  /// Creates a DailyRecord instance from JSON data
  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      id: json['id'] as int?,
      date: DateTime.parse(json['date'] as String), // Parse ISO 8601 string back to DateTime
      dataValues: Map<String, dynamic>.from(json['dataValues']),
    );
  }

  /// Creates a copy of DailyRecord with optional field updates
  DailyRecord copyWith({
    int? id,
    DateTime? date,
    Map<String, dynamic>? dataValues,
  }) {
    return DailyRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      dataValues: dataValues ?? this.dataValues,
    );
  }
}
