class MedicationModel {
  final String? id;
  final String name;
  final String dosage;
  final String date;
  final String time;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicationModel({
    this.id,
    required this.name,
    required this.dosage,
    required this.date,
    required this.time,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dosage': dosage,
      'date': date,
      'time': time,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static MedicationModel fromFirestore(Map<String, dynamic> map, String id) {
    return MedicationModel(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : map['createdAt']?.toDate(),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt']
          : map['updatedAt']?.toDate(),
    );
  }
}
