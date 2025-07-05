import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/widget/add_edit_symptom.dart';
import 'package:pillpall/widget/global_homebar.dart';

import '../debug/firestore_test.dart';
import '../models/symptom_model.dart';
import '../services/symptom_service.dart';

class SymptomWidget extends StatefulWidget {
  const SymptomWidget({super.key});

  @override
  State<SymptomWidget> createState() => _SymptomWidgetState();
}

class _SymptomWidgetState extends State<SymptomWidget> {
  DateTime _selectedDate = DateTime.now();
  final SymptomService _symptomService = SymptomService();
  List<Symptom> _allSymptoms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // First check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final symptoms = await _symptomService.getAllSymptoms();

      if (mounted) {
        setState(() {
          _allSymptoms = symptoms;
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

  Future<void> _refreshSymptoms() async {
    await _loadSymptoms();
  }

  List<Symptom> get todaySymptoms {
    final today = DateTime.now();
    return _allSymptoms.where((symptom) => symptom.isFromDate(today)).toList();
  }

  List<Symptom> get selectedDateSymptoms {
    return _allSymptoms
        .where((symptom) => symptom.isFromDate(_selectedDate))
        .toList();
  }

  bool get isSelectedDateToday {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  Future<void> _addSymptom([DateTime? forDate]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditSymptomPage(selectedDate: forDate ?? _selectedDate),
      ),
    );

    if (result == true) {
      _refreshSymptoms();
    }
  }

  Future<void> _editSymptom(Symptom symptom) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSymptomPage(symptom: symptom),
      ),
    );

    if (result == true) {
      _refreshSymptoms();
    }
  }

  Future<void> _deleteSymptom(Symptom symptom) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Symptom'),
        content: const Text(
          'Are you sure you want to delete this symptom? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && symptom.id != null) {
      try {
        await _symptomService.deleteSymptom(symptom.id!);
        _refreshSymptoms();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Symptom deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete symptom: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showSymptomDetails(Symptom symptom) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getSeverityColor(symptom.severity),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Symptom Details')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Symptom', symptom.text),
                const SizedBox(height: 12),
                _buildDetailRow('Date', symptom.formattedDate),
                const SizedBox(height: 12),
                _buildDetailRow('Time', symptom.formattedTime),
                if (symptom.severity != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('Severity', symptom.severity!.toUpperCase()),
                ],
                if (symptom.tags != null && symptom.tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('Tags', symptom.tags!.join(', ')),
                ],
                if (symptom.createdAt != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Created',
                    '${symptom.createdAt!.day}/${symptom.createdAt!.month}/${symptom.createdAt!.year} at ${symptom.createdAt!.hour.toString().padLeft(2, '0')}:${symptom.createdAt!.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editSymptom(symptom);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDDED),
      appBar: AppBar(
        title: const Text(
          'Symptom Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFFFDDED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onPressed: () => testFirestoreConnection(),
            tooltip: 'Debug Connection',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.deepPurple),
            onPressed: () => _addSymptom(),
            tooltip: 'Add Symptom',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading symptoms',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error ?? 'Unknown error',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshSymptoms,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshSymptoms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    // Calendar Section
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CalendarDatePicker(
                            initialDate: _selectedDate,
                            firstDate: DateTime(DateTime.now().year - 1),
                            lastDate: DateTime(DateTime.now().year + 2),
                            onDateChanged: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Today's Symptoms Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'How are you feeling today?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () => _addSymptom(DateTime.now()),
                                tooltip: 'Add symptom for today',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          todaySymptoms.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No symptoms logged for today',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: todaySymptoms
                                      .map(
                                        (symptom) =>
                                            _buildSymptomEntry(symptom),
                                      )
                                      .toList(),
                                ),
                        ],
                      ),
                    ),

                    // Selected Date Symptoms Section (only show if different from today)
                    if (!isSelectedDateToday) ...[
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Symptoms for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            selectedDateSymptoms.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No symptoms logged for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: selectedDateSymptoms
                                        .map(
                                          (symptom) =>
                                              _buildSymptomEntry(symptom),
                                        )
                                        .toList(),
                                  ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const GlobalHomeBar(
        selectedIndex: 1, // Symptom page
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSymptom(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Symptom',
      ),
    );
  }

  Widget _buildSymptomEntry(Symptom symptom) {
    return GestureDetector(
      onTap: () => _showSymptomDetails(symptom),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getSeverityColor(symptom.severity),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    symptom.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editSymptom(symptom);
                        break;
                      case 'delete':
                        _deleteSymptom(symptom);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  symptom.formattedTime,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (symptom.severity != null) ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: _getSeverityColor(symptom.severity),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Severity: ${symptom.severity!.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getSeverityColor(symptom.severity),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            if (symptom.tags != null && symptom.tags!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.label, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        ...symptom.tags!.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                          );
                        }),
                        if (symptom.tags!.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              '+${symptom.tags!.length - 3} more',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap for details',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.info_outline, size: 12, color: Colors.grey[500]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }
}
