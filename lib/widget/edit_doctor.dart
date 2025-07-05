import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/doctor_model.dart';
import '../services/doctor_service.dart';

class EditDoctorPage extends StatefulWidget {
  final Doctor doctor;

  const EditDoctorPage({super.key, required this.doctor});

  @override
  State<EditDoctorPage> createState() => _EditDoctorPageState();
}

class _EditDoctorPageState extends State<EditDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _secretaryController = TextEditingController();
  final _mobileController = TextEditingController();

  // HMO Accreditation variables
  List<String> selectedHMOs = [];
  final List<String> availableHMOs = [
    'MediCard',
    'MaxiCare',
    'Asalus Corporation',
    'Pacific Cross',
    'Health Maintenance, Inc.',
    'Value Care Health Services',
    'Life & Health HMP, Inc.',
    'Lacson & Lacson',
    'IntelliCare',
    'SunLife',
    'PhilHealth',
  ];

  // Specialty variables
  List<String> selectedSpecialties = [];
  final List<String> availableSpecialties = [
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'General Practice',
    'Gynecology',
    'Hematology',
    'Internal Medicine',
    'Neurology',
    'Oncology',
    'Ophthalmology',
    'Orthopedics',
    'Otolaryngology',
    'Pediatrics',
    'Psychiatry',
    'Pulmonology',
    'Radiology',
    'Rheumatology',
    'Surgery',
    'Urology',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = widget.doctor.name;
    _emailController.text = widget.doctor.email ?? '';
    _secretaryController.text = widget.doctor.secretaryNumber ?? '';
    _mobileController.text = widget.doctor.mobileNumber ?? '';

    selectedSpecialties = List.from(widget.doctor.specialties);
    selectedHMOs = List.from(widget.doctor.hmoAccreditations ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _secretaryController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _updateDoctor() async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Updating doctor...'),
              ],
            ),
          );
        },
      );

      try {
        // Create updated doctor object
        Doctor updatedDoctor = widget.doctor.copyWith(
          name: _nameController.text.trim(),
          specialties: selectedSpecialties,
          hmoAccreditations: selectedHMOs,
          mobileNumber: _mobileController.text.trim().isEmpty
              ? null
              : _mobileController.text.trim(),
          secretaryNumber: _secretaryController.text.trim().isEmpty
              ? null
              : _secretaryController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          updatedAt: DateTime.now(),
        );

        // Update the doctor in Firestore
        await DoctorService().updateDoctor(widget.doctor.id!, updatedDoctor);

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Dr. ${updatedDoctor.name} has been updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Return the updated doctor
          Navigator.of(context).pop(updatedDoctor);
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update doctor: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFDDED),
      appBar: AppBar(
        title: const Text(
          'Edit Doctor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFFFDDED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6A8F7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    today,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Edit doctor's information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _DoctorInputField(
                        label: "Full Name",
                        controller: _nameController,
                      ),
                      const SizedBox(height: 18),
                      _SpecialtySelectionField(
                        selectedSpecialties: selectedSpecialties,
                        availableSpecialties: availableSpecialties,
                        onSpecialtiesChanged: (updatedSpecialties) {
                          setState(() {
                            selectedSpecialties = updatedSpecialties;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      _HMOSelectionField(
                        selectedHMOs: selectedHMOs,
                        availableHMOs: availableHMOs,
                        onHMOsChanged: (updatedHMOs) {
                          setState(() {
                            selectedHMOs = updatedHMOs;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      _DoctorInputField(
                        label: "Email address",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      _DoctorInputField(
                        label: "Secretary's #",
                        controller: _secretaryController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),
                      _DoctorInputField(
                        label: "Mobile Number",
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 140,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6A8F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _updateDoctor,
                    child: const Text(
                      "UPDATE",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        fontSize: 16,
                      ),
                    ),
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

// Reuse the same input field widgets from add_doctor.dart
class _DoctorInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _DoctorInputField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            validator: (value) {
              if (label == "Full Name" && (value == null || value.isEmpty)) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class _SpecialtySelectionField extends StatefulWidget {
  final List<String> selectedSpecialties;
  final List<String> availableSpecialties;
  final Function(List<String>) onSpecialtiesChanged;

  const _SpecialtySelectionField({
    required this.selectedSpecialties,
    required this.availableSpecialties,
    required this.onSpecialtiesChanged,
  });

  @override
  State<_SpecialtySelectionField> createState() =>
      _SpecialtySelectionFieldState();
}

class _SpecialtySelectionFieldState extends State<_SpecialtySelectionField> {
  final TextEditingController _customSpecialtyController =
      TextEditingController();
  List<String> workingList = [];

  @override
  void initState() {
    super.initState();
    workingList = List.from(widget.selectedSpecialties);
  }

  void _showSpecialtySelectionDialog() {
    List<String> allSpecialties = List.from(widget.availableSpecialties);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Specialties'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: allSpecialties.map((specialty) {
                          return CheckboxListTile(
                            title: Text(specialty),
                            value: workingList.contains(specialty),
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  if (!workingList.contains(specialty)) {
                                    workingList.add(specialty);
                                  }
                                } else {
                                  workingList.remove(specialty);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customSpecialtyController,
                            decoration: const InputDecoration(
                              hintText: 'Add custom specialty',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_customSpecialtyController.text.isNotEmpty) {
                              String customSpecialty =
                                  _customSpecialtyController.text.trim();
                              if (!allSpecialties.contains(customSpecialty) &&
                                  !workingList.contains(customSpecialty)) {
                                setDialogState(() {
                                  allSpecialties.add(customSpecialty);
                                  workingList.add(customSpecialty);
                                });
                                _customSpecialtyController.clear();
                              }
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSpecialtiesChanged(workingList);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialties',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: _showSpecialtySelectionDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: widget.selectedSpecialties.isEmpty
                        ? const Text(
                            'Select Specialties',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: widget.selectedSpecialties.map((
                              specialty,
                            ) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6A8F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      specialty,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        // Remove this specialty from the list
                                        List<String> updatedSpecialties =
                                            List.from(
                                              widget.selectedSpecialties,
                                            );
                                        updatedSpecialties.remove(specialty);
                                        widget.onSpecialtiesChanged(
                                          updatedSpecialties,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HMOSelectionField extends StatefulWidget {
  final List<String> selectedHMOs;
  final List<String> availableHMOs;
  final Function(List<String>) onHMOsChanged;

  const _HMOSelectionField({
    required this.selectedHMOs,
    required this.availableHMOs,
    required this.onHMOsChanged,
  });

  @override
  State<_HMOSelectionField> createState() => _HMOSelectionFieldState();
}

class _HMOSelectionFieldState extends State<_HMOSelectionField> {
  final TextEditingController _customHMOController = TextEditingController();
  List<String> workingList = [];

  @override
  void initState() {
    super.initState();
    workingList = List.from(widget.selectedHMOs);
  }

  void _showHMOSelectionDialog() {
    List<String> allHMOs = List.from(widget.availableHMOs);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select HMO Accreditations'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: allHMOs.map((hmo) {
                          return CheckboxListTile(
                            title: Text(hmo),
                            value: workingList.contains(hmo),
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  if (!workingList.contains(hmo)) {
                                    workingList.add(hmo);
                                  }
                                } else {
                                  workingList.remove(hmo);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customHMOController,
                            decoration: const InputDecoration(
                              hintText: 'Add custom HMO',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_customHMOController.text.isNotEmpty) {
                              String customHMO = _customHMOController.text
                                  .trim();
                              if (!allHMOs.contains(customHMO) &&
                                  !workingList.contains(customHMO)) {
                                setDialogState(() {
                                  allHMOs.add(customHMO);
                                  workingList.add(customHMO);
                                });
                                _customHMOController.clear();
                              }
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onHMOsChanged(workingList);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HMO Accreditations',
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: _showHMOSelectionDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: widget.selectedHMOs.isEmpty
                        ? const Text(
                            'Select HMO Accreditations',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: widget.selectedHMOs.map((hmo) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6A8F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      hmo,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        // Remove this HMO from the list
                                        List<String> updatedHMOs = List.from(
                                          widget.selectedHMOs,
                                        );
                                        updatedHMOs.remove(hmo);
                                        widget.onHMOsChanged(updatedHMOs);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
