import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpall/services/medication_service.dart';

class MedicationAlarmPage extends StatefulWidget {
  final String medicationId;
  final Map<String, dynamic> medicationData;
  final VoidCallback? onTaken;
  final VoidCallback? onSkipped;
  final Function(int minutes)? onSnoozed;

  const MedicationAlarmPage({
    super.key,
    required this.medicationId,
    required this.medicationData,
    this.onTaken,
    this.onSkipped,
    this.onSnoozed,
  });

  @override
  State<MedicationAlarmPage> createState() => _MedicationAlarmPageState();
}

class _MedicationAlarmPageState extends State<MedicationAlarmPage>
    with TickerProviderStateMixin {
  late AnimationController _bellController;
  late AnimationController _pulseController;
  late Animation<double> _bellAnimation;
  late Animation<double> _pulseAnimation;
  
  final MedicationService _medicationService = MedicationService();
  bool _isLoading = false;
  int? _selectedSnoozeMinutes;

  @override
  void initState() {
    super.initState();
    
    // Bell shake animation
    _bellController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bellAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _bellController,
      curve: Curves.elasticInOut,
    ));

    // Pulse animation for the background
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _bellController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bellController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute$ampm';
  }

  String _getMedicationTime() {
    final time = widget.medicationData['time'] ?? '';
    if (time.isEmpty) return _getCurrentTime();
    
    try {
      // Convert 24-hour format to 12-hour format with AM/PM
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute$ampm';
      }
    } catch (e) {
      print('Error parsing time: $e');
    }
    
    return _getCurrentTime();
  }

  Future<void> _markAsTaken() async {
    setState(() => _isLoading = true);
    
    try {
      // You can add logic here to mark medication as taken
      // For example, update a "taken" status or log the intake
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
      
      if (widget.onTaken != null) {
        widget.onTaken!();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Medication marked as taken!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _skipMedication() async {
    setState(() => _isLoading = true);
    
    try {
      // You can add logic here to log skipped medication
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
      
      if (widget.onSkipped != null) {
        widget.onSkipped!();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Text('Medication skipped'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _snoozeAlarm(int minutes) {
    if (widget.onSnoozed != null) {
      widget.onSnoozed!(minutes);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.snooze, color: Colors.white),
            SizedBox(width: 8),
            Text('Snoozed for $minutes minute${minutes > 1 ? 's' : ''}'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final medicationName = widget.medicationData['name'] ?? 'Unknown Medication';
    final dosage = widget.medicationData['dosage'] ?? '';
    final currentTime = _getMedicationTime();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.grey[300],
              child: Column(
                children: [
                  Text(
                    'MEDICATION ALARM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PILL PAL • Your medication companion',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Color(0xFFFFB6C1), // Light pink
                      Color(0xFFFF69B4), // Hot pink
                      Color(0xFFFF1493), // Deep pink
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated bell icon
                    AnimatedBuilder(
                      animation: _bellAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _bellAnimation.value,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Time display
                    Text(
                      currentTime,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Medication name and dosage
                    Text(
                      '$medicationName${dosage.isNotEmpty ? ' • $dosage' : ''}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Tablet icon and text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tablet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 60),
                    
                    // Snooze reminder section
                    Text(
                      'Snooze reminder:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Snooze time options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [1, 5, 10, 15, 20].map((minutes) {
                        final isSelected = _selectedSnoozeMinutes == minutes;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSnoozeMinutes = minutes;
                            });
                            _snoozeAlarm(minutes);
                          },
                          child: Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$minutes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom buttons
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Row(
                children: [
                  // Skip button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _skipMedication,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Color(0xFFFF69B4), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF69B4),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Taken button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _markAsTaken,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF69B4),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Taken',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
