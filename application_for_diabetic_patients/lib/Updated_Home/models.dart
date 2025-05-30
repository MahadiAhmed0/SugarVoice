import 'package:intl/intl.dart';

// --- MedicineSchedule Model ---
/// Represents a scheduled medicine.
class MedicineSchedule {
  final String id; // Unique ID for each scheduled medicine
  final String name;
  final String dosage;
  final String frequency; // e.g., "Once daily", "Before meals", "Every 8 hours"

  MedicineSchedule({
    String? id,
    required this.name,
    required this.dosage,
    required this.frequency,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(); // Simple unique ID

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
    };
  }
}

// --- MedicineLog Model ---
/// Represents a record of a medicine being taken.
class MedicineLog {
  final String id; // Unique ID for each log entry
  final String medicineName;
  final String timestamp; // ISO 8601 string

  MedicineLog({
    String? id,
    required this.medicineName,
    required this.timestamp,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(); // Simple unique ID

  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    return MedicineLog(
      id: json['id'] as String,
      medicineName: json['medicineName'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      'timestamp': timestamp,
    };
  }

  /// Returns a human-readable formatted timestamp.
  String get formattedTimestamp {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}