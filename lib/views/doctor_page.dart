import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pillpall/views/global_homebar.dart';

import '../models/doctor_model.dart';
import '../services/doctor_service.dart';
import 'edit_doctor.dart';

class DoctorPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorPage({super.key, required this.doctor});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  late Doctor currentDoctor;

  @override
  void initState() {
    super.initState();
    currentDoctor = widget.doctor;
  }

  // Email validation helper
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Phone number validation helper
  bool _isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    // Remove all non-digit characters for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it has at least 10 digits (common minimum for phone numbers)
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  // Safe string getter with validation
  String _getSafeContactInfo(String? value, String type) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final trimmedValue = value.trim();

    switch (type.toLowerCase()) {
      case 'email':
        return _isValidEmail(trimmedValue) ? trimmedValue : '';
      case 'phone':
        return _isValidPhoneNumber(trimmedValue) ? trimmedValue : '';
      default:
        return trimmedValue;
    }
  }

  // HMO accreditations validation
  List<String> _getValidHmoAccreditations() {
    if (currentDoctor.hmoAccreditations == null) return [];

    return currentDoctor.hmoAccreditations!
        .where((hmo) => hmo.trim().isNotEmpty)
        .map((hmo) => hmo.trim())
        .toList();
  }

  // Copy to clipboard with error handling
  Future<void> _copyToClipboard(String text, String type) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type copied to clipboard'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
  bool _hasAnyContactInfo() {
    return (currentDoctor.email != null && currentDoctor.email!.isNotEmpty) ||
        (currentDoctor.mobileNumber != null &&
            currentDoctor.mobileNumber!.isNotEmpty) ||
        (currentDoctor.secretaryNumber != null &&
            currentDoctor.secretaryNumber!.isNotEmpty);
  }

  Future<void> _editDoctor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDoctorPage(doctor: currentDoctor),
      ),
    );

    if (result != null && result is Doctor) {
      setState(() {
        currentDoctor = result;
      });
    }
  }

  Future<void> _deleteDoctor(BuildContext context) async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Doctor'),
          content: Text(
            'Are you sure you want to delete Dr. ${currentDoctor.name}? This action cannot be undone.',
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

    if (shouldDelete == true && currentDoctor.id != null) {
      try {
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
                  Text('Deleting doctor...'),
                ],
              ),
            );
          },
        );

        // Delete the doctor
        await DoctorService().deleteDoctor(currentDoctor.id!);

        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Dr. ${currentDoctor.name} has been deleted successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to previous screen
          Navigator.of(context).pop(true); // Return true to indicate deletion
        }
      } catch (e) {
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show error message
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
  }

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
        actions: [
          // Edit button in app bar
          if (currentDoctor.id != null)
            IconButton(
              onPressed: _editDoctor,
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              tooltip: 'Edit Doctor',
            ),
          // Delete button in app bar
          if (currentDoctor.id != null)
            IconButton(
              onPressed: () => _deleteDoctor(context),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete Doctor',
            ),
        ],
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
            // Doctor Profile Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.withOpacity(0.1),
                      Colors.pink.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Avatar and Name
                    Row(
                      children: [
                        // Circular Avatar with Doctor Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepPurple,
                                Colors.purple.shade400,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Doctor Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentDoctor.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${currentDoctor.specialties.length} Specialt${currentDoctor.specialties.length == 1 ? 'y' : 'ies'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Specialties
                    const Text(
                      'Specializations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentDoctor.specialties
                          .map(
                            (specialty) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                specialty,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // HMO Accreditations Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "HMO Accreditations",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final validHmos = _getValidHmoAccreditations();

                        if (validHmos.isNotEmpty) {
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: validHmos
                                .map(
                                  (hmo) => _HmoChip(
                                    label: hmo,
                                    onTap: () => _copyToClipboard(hmo, 'HMO'),
                                  ),
                                )
                                .toList(),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.grey.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    currentDoctor.hmoAccreditations?.isEmpty ??
                                            true
                                        ? 'No HMO accreditations on file'
                                        : 'HMO accreditation data appears to be invalid',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Contact Information Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.contact_phone,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Contact Information",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) {
                        final safeEmail = _getSafeContactInfo(
                          currentDoctor.email,
                          'email',
                        );
                        final safeMobile = _getSafeContactInfo(
                          currentDoctor.mobileNumber,
                          'phone',
                        );
                        final safeSecretary = _getSafeContactInfo(
                          currentDoctor.secretaryNumber,
                          'phone',
                        );

                        final hasValidContact =
                            safeEmail.isNotEmpty ||
                            safeMobile.isNotEmpty ||
                            safeSecretary.isNotEmpty;

                        if (hasValidContact) {
                          return Column(
                            children: [
                              if (safeEmail.isNotEmpty)
                                _ContactInfoRow(
                                  icon: Icons.email_outlined,
                                  label: "Email",
                                  value: safeEmail,
                                  color: Colors.orange,
                                  onTap: () =>
                                      _copyToClipboard(safeEmail, 'Email'),
                                  isValid: true,
                                ),
                              if (safeMobile.isNotEmpty)
                                _ContactInfoRow(
                                  icon: Icons.phone_android_outlined,
                                  label: "Mobile Number",
                                  value: safeMobile,
                                  color: Colors.green,
                                  onTap: () => _copyToClipboard(
                                    safeMobile,
                                    'Mobile number',
                                  ),
                                  isValid: true,
                                ),
                              if (safeSecretary.isNotEmpty)
                                _ContactInfoRow(
                                  icon: Icons.support_agent_outlined,
                                  label: "Secretary's Number",
                                  value: safeSecretary,
                                  color: Colors.purple,
                                  onTap: () => _copyToClipboard(
                                    safeSecretary,
                                    'Secretary number',
                                  ),
                                  isValid: true,
                                ),
                              // Show invalid contact info if any exists
                              if (currentDoctor.email != null &&
                                  currentDoctor.email!.isNotEmpty &&
                                  safeEmail.isEmpty)
                                _ContactInfoRow(
                                  icon: Icons.email_outlined,
                                  label: "Email (Invalid)",
                                  value: currentDoctor.email!,
                                  color: Colors.red,
                                  isValid: false,
                                ),
                              if (currentDoctor.mobileNumber != null &&
                                  currentDoctor.mobileNumber!.isNotEmpty &&
                                  safeMobile.isEmpty)
                                _ContactInfoRow(
                                  icon: Icons.phone_android_outlined,
                                  label: "Mobile Number (Invalid)",
                                  value: currentDoctor.mobileNumber!,
                                  color: Colors.red,
                                  isValid: false,
                                ),
                              if (currentDoctor.secretaryNumber != null &&
                                  currentDoctor.secretaryNumber!.isNotEmpty &&
                                  safeSecretary.isEmpty)
                                _ContactInfoRow(
                                  icon: Icons.support_agent_outlined,
                                  label: "Secretary's Number (Invalid)",
                                  value: currentDoctor.secretaryNumber!,
                                  color: Colors.red,
                                  isValid: false,
                                ),
                            ],
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _hasAnyContactInfo()
                                        ? "Contact information is invalid or improperly formatted"
                                        : "No contact information available",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Edit and Delete Buttons
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: GlobalHomeBar(
        selectedIndex: 2, // Set to 2 for the doctor/stethoscope icon
        onTap: (index) {
          // Handle navigation here
        },
      ),
    );
  }
}

class _HmoChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _HmoChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink.shade400, Colors.pink.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.copy, color: Colors.white, size: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final bool isValid;

  const _ContactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isValid ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isValid
              ? color.withOpacity(0.05)
              : Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isValid
                ? color.withOpacity(0.2)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isValid
                    ? color.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
              ),
              child: Icon(
                isValid ? icon : Icons.error_outline,
                size: 16,
                color: isValid ? color : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isValid ? color : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: isValid ? Colors.black87 : Colors.red.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isValid) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Invalid format - please update',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isValid && onTap != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
                child: Icon(Icons.copy, size: 16, color: color),
              ),
          ],
        ),
      ),
    );
  }
}
