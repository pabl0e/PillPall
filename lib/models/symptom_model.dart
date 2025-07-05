import 'package:cloud_firestore/cloud_firestore.dart';

class Symptom {
  final String? id;
  final String text;
  final String? severity; // mild, moderate, severe
  final List<String>? tags; // e.g., ['headache', 'fatigue', 'nausea']
  final DateTime timestamp;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userId; // To associate symptoms with specific users

  Symptom({
    this.id,
    required this.text,
    this.severity,
    this.tags,
    required this.timestamp,
    this.createdAt,
    this.updatedAt,
    required this.userId,
  });

  // Convert Symptom to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'severity': severity,
      'tags': tags ?? [],
      'timestamp': Timestamp.fromDate(timestamp),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }

  // Create Symptom from Firestore DocumentSnapshot
  factory Symptom.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Symptom(
      id: doc.id,
      text: data['text'] ?? '',
      severity: data['severity'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      userId: data['userId'] ?? '',
    );
  }

  // Create Symptom from Map
  factory Symptom.fromMap(Map<String, dynamic> map, {String? id}) {
    return Symptom(
      id: id ?? map['id'],
      text: map['text'] ?? '',
      severity: map['severity'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp']),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      userId: map['userId'] ?? '',
    );
  }

  // Copy with method for updates
  Symptom copyWith({
    String? id,
    String? text,
    String? severity,
    List<String>? tags,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Symptom(
      id: id ?? this.id,
      text: text ?? this.text,
      severity: severity ?? this.severity,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  // Helper method to check if symptom is from today
  bool get isFromToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  // Helper method to check if symptom is from a specific date
  bool isFromDate(DateTime date) {
    return timestamp.year == date.year &&
        timestamp.month == date.month &&
        timestamp.day == date.day;
  }

  // Helper method to get formatted time
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to get formatted date
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Symptom && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Symptom{id: $id, text: $text, severity: $severity, timestamp: $timestamp}';
  }
}
