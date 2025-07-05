import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String? id;
  final String name;
  final List<String> specialties;
  final List<String>? hmoAccreditations;
  final String? mobileNumber;
  final String? secretaryNumber;
  final String? email;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Doctor({
    this.id,
    required this.name,
    required this.specialties,
    this.hmoAccreditations,
    this.mobileNumber,
    this.secretaryNumber,
    this.email,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Doctor to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialties': specialties,
      'hmoAccreditations': hmoAccreditations ?? [],
      'mobileNumber': mobileNumber,
      'secretaryNumber': secretaryNumber,
      'email': email,
      'address': address,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create Doctor from Firestore DocumentSnapshot
  factory Doctor.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      name: data['name'] ?? '',
      specialties: List<String>.from(data['specialties'] ?? []),
      hmoAccreditations: List<String>.from(data['hmoAccreditations'] ?? []),
      mobileNumber: data['mobileNumber'],
      secretaryNumber: data['secretaryNumber'],
      email: data['email'],
      address: data['address'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Create Doctor from Map
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      hmoAccreditations: List<String>.from(map['hmoAccreditations'] ?? []),
      mobileNumber: map['mobileNumber'],
      secretaryNumber: map['secretaryNumber'],
      email: map['email'],
      address: map['address'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  // Copy with method for updates
  Doctor copyWith({
    String? id,
    String? name,
    List<String>? specialties,
    List<String>? hmoAccreditations,
    String? mobileNumber,
    String? secretaryNumber,
    String? email,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialties: specialties ?? this.specialties,
      hmoAccreditations: hmoAccreditations ?? this.hmoAccreditations,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      secretaryNumber: secretaryNumber ?? this.secretaryNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
