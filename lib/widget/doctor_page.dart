import 'package:flutter/material.dart';
import 'package:pillpall/widget/add_doctor.dart'; // Make sure this import is present
import 'package:pillpall/widget/doctor_list.dart'; // Import Doctor class
import 'package:pillpall/widget/global_homebar.dart';

class DoctorPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDDED),
      appBar: AppBar(
        title: const Text(
          'Doctors Directory',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: Color(0xFFFFDDED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Center(
              /* child: Text(
                "DOCTORS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: Colors.black87,
                ),
              ), */
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor image placeholder
                Container(
                  width: 90,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 18),
                // Doctor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialties.join(' •\n'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // HMO Accreditations Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.credit_card,
                          color: Colors.deepPurple,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "HMO Accreditations",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: const [
                        _HmoChip(label: "MediCard"),
                        _HmoChip(label: "MaxiCare"),
                        _HmoChip(label: "Asalus Corporation"),
                        _HmoChip(label: "Pacific Cross"),
                        _HmoChip(label: "Health Maintenance, Inc."),
                        _HmoChip(label: "Value Care Health Services"),
                        _HmoChip(label: "Life & Health HMP, Inc."),
                        _HmoChip(label: "Lacson & Lacson"),
                        _HmoChip(label: "IntelliCare"),
                        _HmoChip(label: "SunLife"),
                        _HmoChip(label: "PhilHealth"),
                        _HmoChip(label: "MediCard"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Clinic Schedule
            const Text(
              "Clinic Schedule",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _ScheduleRow(
              label: "Site",
              value: "Chong Hua Medical Mall (Cebu City)",
            ),
            _ScheduleRow(label: "Building", value: "Chong Hua Medical Mall"),
            _ScheduleRow(label: "Room #", value: "504 A"),
            _ScheduleRow(
              label: "Schedule",
              value: "Tue, Fri: 11:00AM TO 04:00PM",
            ),
            _ScheduleRow(label: "Contact #", value: "09692089584"),
            _ScheduleRow(label: "Secretary", value: "Ruby"),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF673AB7),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDoctorPage()),
          );
        },
        tooltip: 'Add Doctor',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 1, // Set the selected index for highlighting
        onTap: (index) {
          // Handle navigation here
        },
      ),
    );
  }
}

class _HmoChip extends StatelessWidget {
  final String label;
  const _HmoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFFF69B4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String label;
  final String value;
  const _ScheduleRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
