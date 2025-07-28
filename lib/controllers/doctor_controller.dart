import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pillpall/models/doctor_model.dart';
import 'package:pillpall/services/doctor_service.dart';

class DoctorController extends ChangeNotifier {
  final DoctorService _doctorService = DoctorService();
  Doctor? _currentDoctor;
  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Doctor? get currentDoctor => _currentDoctor;
  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set current doctor
  void setCurrentDoctor(Doctor doctor) {
    _currentDoctor = doctor;
    notifyListeners();
  }

  // Load all doctors
  Future<void> loadDoctors() async {
    _setLoading(true);
    try {
      _doctors = await _doctorService.getAllDoctors();
      _clearError();
    } catch (e) {
      _setError('Failed to load doctors: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new doctor
  Future<bool> addDoctor(Doctor doctor) async {
    try {
      await _doctorService.createDoctor(doctor);
      await loadDoctors(); // Refresh the list
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add doctor: $e');
      return false;
    }
  }

  // Update doctor
  Future<bool> updateDoctor(Doctor doctor) async {
    try {
      if (doctor.id == null) {
        _setError('Doctor ID is required for update');
        return false;
      }
      await _doctorService.updateDoctor(doctor.id!, doctor);
      if (_currentDoctor?.id == doctor.id) {
        _currentDoctor = doctor;
      }
      await loadDoctors(); // Refresh the list
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update doctor: $e');
      return false;
    }
  }

  // Delete doctor
  Future<bool> deleteDoctor(String doctorId) async {
    try {
      await _doctorService.deleteDoctor(doctorId);
      await loadDoctors(); // Refresh the list
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete doctor: $e');
      return false;
    }
  }

  // Email validation helper
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Phone number validation helper
  bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    // Remove all non-digit characters for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it has at least 10 digits (common minimum for phone numbers)
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  // Safe string getter with validation
  String getSafeContactInfo(String? value, String type) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final trimmedValue = value.trim();

    switch (type.toLowerCase()) {
      case 'email':
        return isValidEmail(trimmedValue) ? trimmedValue : '';
      case 'phone':
        return isValidPhoneNumber(trimmedValue) ? trimmedValue : '';
      default:
        return trimmedValue;
    }
  }

  // HMO accreditations validation
  List<String> getValidHmoAccreditations(Doctor doctor) {
    if (doctor.hmoAccreditations == null) return [];

    return doctor.hmoAccreditations!
        .where((hmo) => hmo.trim().isNotEmpty)
        .map((hmo) => hmo.trim())
        .toList();
  }

  // Copy to clipboard with error handling
  Future<void> copyToClipboard(String text, String type, BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type copied to clipboard'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy $type: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Check if any contact info exists (even if invalid)
  bool hasAnyContactInfo(Doctor doctor) {
    return (doctor.email != null && doctor.email!.isNotEmpty) ||
        (doctor.mobileNumber != null && doctor.mobileNumber!.isNotEmpty) ||
        (doctor.secretaryNumber != null && doctor.secretaryNumber!.isNotEmpty);
  }

  // Show delete confirmation dialog
  Future<bool?> showDeleteConfirmation(BuildContext context, Doctor doctor) async {
    return await showDialog<bool>(
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Show loading dialog
  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Show success message
  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show error message
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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

  // Validate doctor form data
  Map<String, String?> validateDoctorForm({
    required String name,
    required List<String> specialties,
    String? email,
    String? mobileNumber,
    String? secretaryNumber,
    List<String>? hmoAccreditations,
  }) {
    Map<String, String?> errors = {};

    // Required field validations
    if (name.trim().isEmpty) {
      errors['name'] = 'Doctor name is required';
    }

    if (specialties.isEmpty) {
      errors['specialties'] = 'At least one specialization is required';
    }

    // Optional field validations
    if (email != null && email.isNotEmpty && !isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    if (mobileNumber != null && mobileNumber.isNotEmpty && !isValidPhoneNumber(mobileNumber)) {
      errors['mobileNumber'] = 'Please enter a valid mobile number';
    }

    if (secretaryNumber != null && secretaryNumber.isNotEmpty && !isValidPhoneNumber(secretaryNumber)) {
      errors['secretaryNumber'] = 'Please enter a valid secretary number';
    }

    return errors;
  }

  // Format doctor display name
  String formatDoctorName(Doctor doctor) {
    return 'Dr. ${doctor.name}';
  }

  // Format doctor specialization display
  String formatSpecialization(Doctor doctor) {
    if (doctor.specialties.isEmpty) return 'General Practice';
    return doctor.specialties.join(', ');
  }

  // Format hospital display
  String formatHospital(Doctor doctor) {
    return 'Hospital not specified'; // No hospital field in model
  }

  // Get doctor initials for avatar
  String getDoctorInitials(Doctor doctor) {
    final nameParts = doctor.name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'D';
  }

  // Search doctors by name or specialization
  List<Doctor> searchDoctors(String query) {
    if (query.isEmpty) return _doctors;
    
    final lowercaseQuery = query.toLowerCase();
    return _doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(lowercaseQuery) ||
          doctor.specialties.any((specialty) => specialty.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Sort doctors by name
  List<Doctor> sortDoctorsByName(List<Doctor> doctors) {
    final sortedDoctors = List<Doctor>.from(doctors);
    sortedDoctors.sort((a, b) => a.name.compareTo(b.name));
    return sortedDoctors;
  }

  // Sort doctors by specialization
  List<Doctor> sortDoctorsBySpecialization(List<Doctor> doctors) {
    final sortedDoctors = List<Doctor>.from(doctors);
    sortedDoctors.sort((a, b) => 
      a.specialties.isNotEmpty && b.specialties.isNotEmpty ? 
      a.specialties.first.compareTo(b.specialties.first) : 0);
    return sortedDoctors;
  }
}
