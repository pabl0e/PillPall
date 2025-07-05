import 'package:flutter/material.dart';
import 'package:pillpall/widget/add_doctor.dart';
import 'package:pillpall/widget/doctor_page.dart';
import 'package:pillpall/widget/edit_doctor.dart';
import 'package:pillpall/widget/global_homebar.dart';

import '../models/doctor_model.dart';
import '../services/doctor_service.dart';

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
  final DoctorService _doctorService = DoctorService();
  List<Doctor> doctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Doctor> loadedDoctors = await _doctorService.getAllDoctors();

      if (mounted) {
        setState(() {
          doctors = loadedDoctors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshDoctors() async {
    await _loadDoctors();
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading doctors',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDoctors,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : doctors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No doctors added yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first doctor',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshDoctors,
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  // Doctors List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        return DoctorCard(
                          doctor: doctors[index],
                          onDoctorDeleted: _refreshDoctors,
                        );
                      },
                    ),
                  ),
                ],
              ),
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
          onPressed: () async {
            // Navigate to the AddDoctorPage and refresh list if doctor was added
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddDoctorPage()),
            );

            // If result is true, refresh the doctor list
            if (result == true) {
              _refreshDoctors();
            }
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
  final VoidCallback? onDoctorDeleted;

  const DoctorCard({super.key, required this.doctor, this.onDoctorDeleted});

  void _showEditDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Doctor'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDoctorPage(doctor: doctor),
                    ),
                  );

                  if (result != null && onDoctorDeleted != null) {
                    onDoctorDeleted!(); // Refresh the list to show updated data
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Doctor'),
                onTap: () async {
                  Navigator.pop(context);

                  if (doctor.id == null) return;

                  // Show confirmation dialog
                  bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Doctor'),
                        content: Text(
                          'Are you sure you want to delete Dr. ${doctor.name}? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    try {
                      await DoctorService().deleteDoctor(doctor.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Dr. ${doctor.name} has been deleted successfully',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        if (onDoctorDeleted != null) {
                          onDoctorDeleted!();
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete doctor: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('doctor_${doctor.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Doctor'),
              content: Text(
                'Are you sure you want to delete Dr. ${doctor.name}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        if (doctor.id != null) {
          try {
            await DoctorService().deleteDoctor(doctor.id!);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dr. ${doctor.name} has been deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete doctor: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      child: InkWell(
        onTap: () async {
          // Navigate to the doctor's detail page and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorPage(doctor: doctor)),
          );

          // If doctor was deleted, refresh the list
          if (result == true && onDoctorDeleted != null) {
            onDoctorDeleted!();
          }
        },
        onLongPress: () {
          _showEditDeleteMenu(context);
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
      ),
    );
  }
}
