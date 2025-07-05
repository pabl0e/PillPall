import 'package:flutter/material.dart';
import 'package:pillpall/widget/add_doctor.dart';
import 'package:pillpall/widget/doctor_page.dart';
import 'package:pillpall/widget/global_homebar.dart';

void main() {
  runApp(const PillPalApp());
}

class PillPalApp extends StatelessWidget {
  const PillPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pill Pal',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[100],
      ),
      home: const DoctorListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final List<Doctor> doctors = [
    Doctor(
      name: "Dr. Rosana Ferolin",
      specialties: [
        "Obstetrics and Gynecology",
        "General Obstetrics and Gynecology",
      ],
    ),
    Doctor(
      name: "Dr. Rosana Ferolin",
      specialties: [
        "Obstetrics and Gynecology",
        "General Obstetrics and Gynecology",
      ],
    ),
    Doctor(
      name: "Dr. Rosana Ferolin",
      specialties: [
        "Obstetrics and Gynecology",
        "General Obstetrics and Gynecology",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDDED),
      appBar: AppBar(
        title: const Text(
          'Your Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFFFDDED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(height: 18),

          // Doctors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return DoctorCard(doctor: doctors[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 2, // Doctor page (was 1, now 2)
        onTap: (index) {
          // Navigation is handled by the GlobalHomeBar itself
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0), // Adjust value as needed
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to the AddDoctorPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddDoctorPage()),
            );
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.deepPurple,
          tooltip: 'Add Doctor',
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the doctor's detail page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorPage(doctor: doctor)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            ...doctor.specialties.map(
              (specialty) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  specialty,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Doctor {
  final String name;
  final List<String> specialties;

  Doctor({required this.name, required this.specialties});
}
