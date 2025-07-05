import 'package:flutter/material.dart';

import '../models/symptom_model.dart';
import '../services/symptom_service.dart';

class AddEditSymptomPage extends StatefulWidget {
  final Symptom? symptom; // null for add, existing symptom for edit
  final DateTime? selectedDate;

  const AddEditSymptomPage({super.key, this.symptom, this.selectedDate});

  @override
  State<AddEditSymptomPage> createState() => _AddEditSymptomPageState();
}

class _AddEditSymptomPageState extends State<AddEditSymptomPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _symptomService = SymptomService();

  String? _selectedSeverity;
  DateTime _selectedDateTime = DateTime.now();
  List<String> _selectedTags = [];
  bool _isLoading = false;

  final List<String> _severityOptions = ['Mild', 'Moderate', 'Severe'];
  final List<String> _commonTags = [
    'Headache',
    'Fatigue',
    'Nausea',
    'Fever',
    'Cough',
    'Sore Throat',
    'Muscle Pain',
    'Joint Pain',
    'Dizziness',
    'Insomnia',
    'Anxiety',
    'Stress',
  ];

  bool get _isEditing => widget.symptom != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditing) {
      // Editing existing symptom
      _textController.text = widget.symptom!.text;
      _selectedSeverity = widget.symptom!.severity;
      _selectedDateTime = widget.symptom!.timestamp;
      _selectedTags = List<String>.from(widget.symptom!.tags ?? []);
    } else {
      // Adding new symptom
      if (widget.selectedDate != null) {
        _selectedDateTime = DateTime(
          widget.selectedDate!.year,
          widget.selectedDate!.month,
          widget.selectedDate!.day,
          DateTime.now().hour,
          DateTime.now().minute,
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveSymptom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final symptom = Symptom(
        id: _isEditing ? widget.symptom!.id : null,
        text: _textController.text.trim(),
        severity: _selectedSeverity,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
        timestamp: _selectedDateTime,
        userId: '', // Will be set by the service
      );

      if (_isEditing) {
        await _symptomService.updateSymptom(symptom);
      } else {
        await _symptomService.createSymptom(symptom);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving symptom: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDDED),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Symptom' : 'Add Symptom',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFFFDDED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSymptom,
            child: Text(
              _isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Symptom Description
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Symptom Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _textController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Describe how you\'re feeling...',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please describe your symptom';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date and Time
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date & Time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _selectDateTime,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} at ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Severity
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Severity (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: _severityOptions.map((severity) {
                                final isSelected =
                                    _selectedSeverity == severity;
                                return FilterChip(
                                  label: Text(severity),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSeverity = selected
                                          ? severity
                                          : null;
                                    });
                                  },
                                  selectedColor: _getSeverityColor(
                                    severity,
                                  ).withOpacity(0.3),
                                  checkmarkColor: _getSeverityColor(severity),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tags (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _commonTags.map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isSelected,
                                  onSelected: (selected) => _toggleTag(tag),
                                  selectedColor: Colors.deepPurple.withOpacity(
                                    0.3,
                                  ),
                                  checkmarkColor: Colors.deepPurple,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
