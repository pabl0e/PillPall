import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
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
    'Anesthesiology',
    'ENT (Otorhinolaryngology)',
    'Family and Community Medicine',
    'Internal Medicine',
    'Obstetrics and Gynecology',
    'Ophthalmology',
    'Orthopedics',
    'Pathology',
    'Pediatrics',
    'Radiology',
    'Surgery',
  ];

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFDDED),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Date and Back Icon (left)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                  "Enter your doctor's contact information",
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
                      backgroundColor: Color(0xFFE6A8F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle submit logic here
                        print('Doctor Name: ${_nameController.text}');
                        print('Selected Specialties: $selectedSpecialties');
                        print('Selected HMOs: $selectedHMOs');
                        print('Email: ${_emailController.text}');
                        print('Secretary: ${_secretaryController.text}');
                        print('Mobile: ${_mobileController.text}');

                        // You can process the selectedHMOs list here
                        // For example, save to database or pass to another screen

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Doctor information saved successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "SUBMIT",
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _DoctorInputField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            style: const TextStyle(fontSize: 15),
            validator: (value) {
              if (value == null || value.isEmpty) {
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
                                child: Text(
                                  hmo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
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
                                child: Text(
                                  specialty,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
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
