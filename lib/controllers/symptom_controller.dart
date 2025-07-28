import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/models/symptom_model.dart';
import 'package:pillpall/services/symptom_service.dart';

class SymptomController extends ChangeNotifier {
  final SymptomService _symptomService = SymptomService();
  DateTime _selectedDate = DateTime.now();
  List<Symptom> _allSymptoms = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<Symptom> get allSymptoms => _allSymptoms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Update selected date
  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Load all symptoms
  Future<void> loadSymptoms() async {
    try {
      _setLoading(true);
      _clearError();

      // First check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final symptoms = await _symptomService.getAllSymptoms();
      _allSymptoms = symptoms;
    } catch (e) {
      String errorMessage = _getErrorMessage(e.toString());
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Refresh symptoms
  Future<void> refreshSymptoms() async {
    try {
      await loadSymptoms();
    } catch (e) {
      _setError('Failed to refresh symptoms: ${e.toString()}');
    }
  }

  // Get symptoms for today
  List<Symptom> get todaySymptoms {
    final today = DateTime.now();
    return _allSymptoms.where((symptom) => symptom.isFromDate(today)).toList();
  }

  // Get symptoms for selected date
  List<Symptom> getSymptomsForDate(DateTime date) {
    return _allSymptoms.where((symptom) => symptom.isFromDate(date)).toList();
  }

  // Add new symptom
  Future<bool> addSymptom(Symptom symptom) async {
    try {
      await _symptomService.createSymptom(symptom);
      await loadSymptoms(); // Refresh the list
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add symptom: $e');
      return false;
    }
  }

  // Update symptom
  Future<bool> updateSymptom(Symptom symptom) async {
    try {
      await _symptomService.updateSymptom(symptom);
      await loadSymptoms(); // Refresh the list
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update symptom: $e');
      return false;
    }
  }

  // Delete symptom
  Future<bool> deleteSymptom(String symptomId) async {
    try {
      await _symptomService.deleteSymptom(symptomId);
      await loadSymptoms(); // Refresh the list
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete symptom: $e');
      return false;
    }
  }

  // Show refresh error with retry action
  void showRefreshError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to refresh symptoms: $error'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => refreshSymptoms(),
        ),
      ),
    );
  }

  // Show success message
  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error message
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Format date for display
  String formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  // Format date short
  String formatDateShort(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  // Check if date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is yesterday
  bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  // Get relative date string
  String getRelativeDateString(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return formatDate(date);
  }

  // Filter symptoms by severity level (using severity string)
  List<Symptom> filterSymptomsBySeverity(List<Symptom> symptoms, String severity) {
    return symptoms.where((symptom) => symptom.severity == severity).toList();
  }

  // Group symptoms by date
  Map<DateTime, List<Symptom>> groupSymptomsByDate(List<Symptom> symptoms) {
    Map<DateTime, List<Symptom>> grouped = {};
    
    for (final symptom in symptoms) {
      final date = DateTime(symptom.timestamp.year, symptom.timestamp.month, symptom.timestamp.day);
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(symptom);
    }
    
    return grouped;
  }

  // Get symptoms count for date
  int getSymptomsCountForDate(DateTime date) {
    return getSymptomsForDate(date).length;
  }

  // Get severity color (string-based)
  Color getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
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

  // Get severity label
  String getSeverityLabel(String? severity) {
    if (severity == null) return 'Unknown';
    return severity.substring(0, 1).toUpperCase() + severity.substring(1).toLowerCase();
  }

  // Search symptoms by text
  List<Symptom> searchSymptoms(String query) {
    if (query.isEmpty) return _allSymptoms;
    
    final lowercaseQuery = query.toLowerCase();
    return _allSymptoms.where((symptom) {
      return symptom.text.toLowerCase().contains(lowercaseQuery) ||
          (symptom.tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ?? false);
    }).toList();
  }

  // Sort symptoms by date (newest first)
  List<Symptom> sortSymptomsByDate(List<Symptom> symptoms, {bool ascending = false}) {
    final sortedSymptoms = List<Symptom>.from(symptoms);
    if (ascending) {
      sortedSymptoms.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } else {
      sortedSymptoms.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return sortedSymptoms;
  }

  // Sort symptoms by severity
  List<Symptom> sortSymptomsBySeverity(List<Symptom> symptoms, {bool ascending = false}) {
    final sortedSymptoms = List<Symptom>.from(symptoms);
    final severityOrder = {'mild': 1, 'moderate': 2, 'severe': 3};
    
    if (ascending) {
      sortedSymptoms.sort((a, b) => 
        (severityOrder[a.severity?.toLowerCase()] ?? 0).compareTo(
          severityOrder[b.severity?.toLowerCase()] ?? 0));
    } else {
      sortedSymptoms.sort((a, b) => 
        (severityOrder[b.severity?.toLowerCase()] ?? 0).compareTo(
          severityOrder[a.severity?.toLowerCase()] ?? 0));
    }
    return sortedSymptoms;
  }

  // Get statistics for symptoms
  Map<String, dynamic> getSymptomStatistics(List<Symptom> symptoms) {
    if (symptoms.isEmpty) {
      return {
        'total': 0,
        'averageSeverity': 0.0,
        'mostCommonSeverity': 'mild',
        'mildCount': 0,
        'moderateCount': 0,
        'severeCount': 0,
      };
    }

    int total = symptoms.length;
    
    // Calculate average severity based on string values
    final severityValues = {'mild': 1, 'moderate': 2, 'severe': 3};
    final validSeverities = symptoms
        .where((s) => s.severity != null && severityValues.containsKey(s.severity!.toLowerCase()))
        .map((s) => severityValues[s.severity!.toLowerCase()]!)
        .toList();
    
    double averageSeverity = validSeverities.isNotEmpty 
        ? validSeverities.reduce((a, b) => a + b) / validSeverities.length
        : 0.0;
    
    Map<String, int> severityCounts = {};
    for (final symptom in symptoms) {
      final severity = symptom.severity?.toLowerCase() ?? 'unknown';
      severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
    }
    
    String mostCommonSeverity = severityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    int mildCount = symptoms.where((s) => s.severity?.toLowerCase() == 'mild').length;
    int moderateCount = symptoms.where((s) => s.severity?.toLowerCase() == 'moderate').length;
    int severeCount = symptoms.where((s) => s.severity?.toLowerCase() == 'severe').length;

    return {
      'total': total,
      'averageSeverity': averageSeverity,
      'mostCommonSeverity': mostCommonSeverity,
      'mildCount': mildCount,
      'moderateCount': moderateCount,
      'severeCount': severeCount,
    };
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(String error) {
    // Provide more specific error messages
    if (error.contains('User not authenticated')) {
      return 'Please log in to view your symptoms.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('permission-denied')) {
      return 'Access denied. Please try logging in again.';
    } else if (error.contains('index')) {
      return 'Database is being set up. Please try again in a moment.';
    } else {
      return 'Unable to load symptoms. Please try again.';
    }
  }
}
