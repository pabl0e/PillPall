import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpall/services/auth_service.dart';
import 'package:pillpall/services/medication_service.dart';
import 'package:pillpall/views/medication_alarm_page.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;

  final MedicationService _medicationService = MedicationService();
  Timer? _medicationCheckTimer;
  bool _isInitialized = false;
  BuildContext? _context;
  String? _initializedForUserId;
  Set<String> _triggeredAlarms =
      {}; // Track triggered alarms to prevent duplicates

  // Private constructor
  AlarmService._internal();

  // Initialize the alarm service - ONLY call this after user authentication
  void initialize(BuildContext context) {
    final currentUser = authService.value.currentUser;

    // Strict validation - don't initialize without authenticated user
    if (currentUser == null) {
      print('❌ Cannot initialize AlarmService: No authenticated user');
      return;
    }

    final userId = currentUser.uid;

    // Don't reinitialize for the same user
    if (_isInitialized && _initializedForUserId == userId) {
      print('ℹ️ AlarmService already initialized for user: $userId');
      return;
    }

    // Dispose any existing service first
    if (_isInitialized) {
      print('🔄 Reinitializing AlarmService for new user');
      _disposeInternal();
    }

    _context = context;
    _isInitialized = true;
    _initializedForUserId = userId;
    _triggeredAlarms.clear(); // Clear previous alarms

    print('🚀 Initializing AlarmService for user: $userId');
    print('📅 Current time: ${DateTime.now()}');

    // ✅ ENHANCED: Check every 10 seconds for better precision
    _medicationCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_isInitialized && _context != null && _context!.mounted) {
        _checkForDueMedications(_context!);
        _checkForDueTasks(_context!); // Add task checking
      } else {
        print('⚠️ Timer callback: Context invalid, stopping timer');
        timer.cancel();
      }
    });

    // Run initial check after a short delay to ensure everything is ready
    Future.delayed(Duration(seconds: 2), () {
      if (_isInitialized && _context != null && _context!.mounted) {
        print('🔍 Running initial medication check for user: $userId');
        _checkForDueMedications(_context!);
        print('🔍 Running initial task check for user: $userId');
        _checkForDueTasks(_context!);
      }
    });

    // ✅ NEW: Clear triggered alarms every hour to allow re-triggering
    Timer.periodic(Duration(hours: 1), (timer) {
      if (_isInitialized) {
        final oldCount = _triggeredAlarms.length;
        _triggeredAlarms.clear();
        print('🧹 Cleared $oldCount triggered alarms for fresh hour');
      } else {
        timer.cancel();
      }
    });

    print('✅ AlarmService initialized successfully for user: $userId');
  }

  // Dispose the alarm service
  void dispose() {
    if (!_isInitialized) {
      print('ℹ️ AlarmService not initialized, nothing to dispose');
      return;
    }

    print('🛑 Disposing AlarmService for user: $_initializedForUserId');
    _disposeInternal();
    print('✅ AlarmService disposed successfully');
  }

  void _disposeInternal() {
    _medicationCheckTimer?.cancel();
    _medicationCheckTimer = null;
    _context = null;
    _isInitialized = false;
    _initializedForUserId = null;
    _triggeredAlarms.clear();
  }

  // Check for medications that are due now
  Future<void> _checkForDueMedications(BuildContext context) async {
    try {
      final currentUser = authService.value.currentUser;
      if (currentUser == null) {
        print('⚠️ User signed out during medication check, stopping');
        return;
      }

      final userId = currentUser.uid;
      if (userId != _initializedForUserId) {
        print('⚠️ User changed during medication check, stopping');
        return;
      }

      final now = DateTime.now();
      final currentDate = now.toIso8601String().split('T')[0];
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // ✅ ENHANCED: More detailed logging with seconds
      final currentTimeWithSeconds =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      print(
        '🔍 Checking medications for user $userId at $currentTimeWithSeconds on $currentDate',
      );

      // Query medications that are due now (with enhanced tolerance)
      final dueMedications = await _getMedicationsDueNowWithTolerance(
        currentDate,
        currentTime,
        userId,
      );

      if (dueMedications.isNotEmpty) {
        print('⏰ Found ${dueMedications.length} medications due now:');
        for (var medication in dueMedications) {
          final medicationKey =
              '${medication['id']}_${currentDate}_${medication['time']}';

          // ✅ ENHANCED: Prevent duplicate alarms for the same medication/time
          if (!_triggeredAlarms.contains(medicationKey)) {
            print(
              '  🔔 NEW ALARM: ${medication['name']} at ${medication['time']}',
            );
            _triggeredAlarms.add(medicationKey);

            if (_isInitialized && context.mounted) {
              _showMedicationAlarm(context, medication['id'], medication);
            }
          } else {
            print(
              '  ⏭️ SKIPPED: ${medication['name']} at ${medication['time']} (already triggered)',
            );
          }
        }
      } else {
        // Only log every 6th check (every minute) to reduce spam
        if (now.second < 10) {
          print('📋 No medications due at $currentTime');
        }
      }
    } catch (e) {
      print('❌ Error checking for due medications: $e');
    }
  }

  // Enhanced method to get medications due now with better tolerance
  Future<List<Map<String, dynamic>>> _getMedicationsDueNowWithTolerance(
    String currentDate,
    String currentTime,
    String userId,
  ) async {
    try {
      // Get current time parts
      final timeParts = currentTime.split(':');
      final currentHour = int.parse(timeParts[0]);
      final currentMinute = int.parse(timeParts[1]);
      final currentTotalMinutes = currentHour * 60 + currentMinute;

      print(
        '🔎 Querying medications for user: $userId, date: $currentDate, time: $currentTime',
      );

      // Query all medications for today for this specific user
      final snapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: currentDate)
          .get();

      print('📊 Found ${snapshot.docs.length} total medications for today');

      List<Map<String, dynamic>> dueMedications = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final medicationTime = data['time'] ?? '';

        if (medicationTime.isNotEmpty) {
          final medTimeParts = medicationTime.split(':');
          if (medTimeParts.length >= 2) {
            final medHour = int.parse(medTimeParts[0]);
            final medMinute = int.parse(medTimeParts[1]);
            final medTotalMinutes = medHour * 60 + medMinute;

            // ✅ ENHANCED: Check if medication is due now (with 3-minute tolerance window)
            final timeDifference = currentTotalMinutes - medTotalMinutes;

            print(
              '⏱️ ${data['name']}: scheduled ${medicationTime} (${medTotalMinutes}min), current ${currentTime} (${currentTotalMinutes}min), diff: ${timeDifference}min',
            );

            // Medication is due if:
            // - It's exactly the right time (diff = 0)
            // - It's up to 2 minutes late (diff = 1 or 2)
            if (timeDifference >= 0 && timeDifference <= 2) {
              print(
                '✅ Medication ${data['name']} is due! (${timeDifference}min ${timeDifference == 0 ? 'on time' : 'late'})',
              );
              dueMedications.add({'id': doc.id, ...data});
            }
            // ❌ REMOVED: Early trigger logic that was causing 12:29 trigger for 12:30 medication
            // } else if (timeDifference < 0 && timeDifference >= -1) {
            //   print('⏰ Medication ${data['name']} is due very soon! (${-timeDifference}min early)');
            //   dueMedications.add({
            //     'id': doc.id,
            //     ...data,
            //   });
            // }
          }
        }
      }

      return dueMedications;
    } catch (e) {
      print('❌ Error in _getMedicationsDueNowWithTolerance: $e');
      return [];
    }
  }

  // Check for tasks that are due now (starting soon)
  Future<void> _checkForDueTasks(BuildContext context) async {
    try {
      final currentUser = authService.value.currentUser;
      if (currentUser == null) {
        print('⚠️ User signed out during task check, stopping');
        return;
      }

      final userId = currentUser.uid;
      if (userId != _initializedForUserId) {
        print('⚠️ User changed during task check, stopping');
        return;
      }

      final now = DateTime.now();
      final currentDate = now.toIso8601String().split('T')[0];
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // ✅ ENHANCED: More detailed logging with seconds
      final currentTimeWithSeconds =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      print(
        '🔍 Checking tasks for user $userId at $currentTimeWithSeconds on $currentDate',
      );

      // Query tasks that are due now (with enhanced tolerance)
      final dueTasks = await _getTasksDueNowWithTolerance(
        currentDate,
        currentTime,
        userId,
      );

      if (dueTasks.isNotEmpty) {
        print('⏰ Found ${dueTasks.length} tasks due now:');
        for (var task in dueTasks) {
          final taskKey =
              '${task['id']}_${currentDate}_${task['startTime']}';

          // ✅ ENHANCED: Prevent duplicate alarms for the same task/time
          if (!_triggeredAlarms.contains(taskKey)) {
            print(
              '  🔔 NEW TASK ALARM: ${task['title']} at ${task['startTime']}',
            );
            _triggeredAlarms.add(taskKey);

            if (_isInitialized && context.mounted) {
              _showTaskAlarm(context, task['id'], task);
            }
          } else {
            print(
              '  ⏭️ SKIPPED: ${task['title']} at ${task['startTime']} (already triggered)',
            );
          }
        }
      } else {
        // Only log every 6th check (every minute) to reduce spam
        if (now.second < 10) {
          print('📋 No tasks due at $currentTime');
        }
      }
    } catch (e) {
      print('❌ Error checking for due tasks: $e');
    }
  }

  // Enhanced method to get tasks due now with better tolerance
  Future<List<Map<String, dynamic>>> _getTasksDueNowWithTolerance(
    String currentDate,
    String currentTime,
    String userId,
  ) async {
    try {
      // Get current time parts
      final timeParts = currentTime.split(':');
      final currentHour = int.parse(timeParts[0]);
      final currentMinute = int.parse(timeParts[1]);
      final currentTotalMinutes = currentHour * 60 + currentMinute;

      print(
        '🔎 Querying tasks for user: $userId, date: $currentDate, time: $currentTime',
      );

      // Query all tasks for this specific user
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      print('📊 Found ${snapshot.docs.length} total tasks for user');

      List<Map<String, dynamic>> dueTasks = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final taskStartDate = data['startDate'] ?? '';
        final taskEndDate = data['endDate'] ?? '';
        final taskStartTime = data['startTime'] ?? '';

        // Check if task is scheduled for today
        bool isScheduledToday = false;
        
        if (taskStartDate.contains(currentDate)) {
          isScheduledToday = true;
        } else if (taskStartDate.compareTo(currentDate) <= 0 && 
                   taskEndDate.compareTo(currentDate) >= 0) {
          isScheduledToday = true;
        }

        if (isScheduledToday && taskStartTime.isNotEmpty) {
          final taskTimeParts = taskStartTime.split(':');
          if (taskTimeParts.length >= 2) {
            final taskHour = int.parse(taskTimeParts[0]);
            final taskMinute = int.parse(taskTimeParts[1]);
            final taskTotalMinutes = taskHour * 60 + taskMinute;

            // ✅ ENHANCED: Check if task is due now (with 3-minute tolerance window)
            final timeDifference = currentTotalMinutes - taskTotalMinutes;

            print(
              '⏱️ ${data['title']}: scheduled ${taskStartTime} (${taskTotalMinutes}min), current ${currentTime} (${currentTotalMinutes}min), diff: ${timeDifference}min',
            );

            // Task is due if:
            // - It's exactly the right time (diff = 0)
            // - It's up to 2 minutes late (diff = 1 or 2)
            if (timeDifference >= 0 && timeDifference <= 2) {
              print(
                '✅ Task ${data['title']} is due! (${timeDifference}min ${timeDifference == 0 ? 'on time' : 'late'})',
              );
              dueTasks.add({'id': doc.id, ...data});
            }
          }
        }
      }

      return dueTasks;
    } catch (e) {
      print('❌ Error in _getTasksDueNowWithTolerance: $e');
      return [];
    }
  }

  // Show medication alarm
  void _showMedicationAlarm(
    BuildContext context,
    String medicationId,
    Map<String, dynamic> medicationData,
  ) {
    try {
      if (context.mounted) {
        final navigator = Navigator.maybeOf(context);
        if (navigator != null) {
          print('🚨 Showing medication alarm for: ${medicationData['name']}');

          navigator.push(
            MaterialPageRoute(
              builder: (context) => MedicationAlarmPage(
                medicationId: medicationId,
                medicationData: medicationData,
                onTaken: () {
                  _logMedicationTaken(medicationId, medicationData);
                },
                onSkipped: () {
                  _logMedicationSkipped(medicationId, medicationData);
                },
                onSnoozed: (minutes) {
                  _scheduleSnoozedAlarm(
                    context,
                    medicationId,
                    medicationData,
                    minutes,
                  );
                },
              ),
              fullscreenDialog: true,
            ),
          );
          print('✅ Medication alarm shown successfully');
        } else {
          print('❌ Navigator not available in context');
        }
      } else {
        print('❌ Context is not mounted');
      }
    } catch (e) {
      print('❌ Error showing medication alarm: $e');
    }
  }

  // Log medication as taken
  Future<void> _logMedicationTaken(
    String medicationId,
    Map<String, dynamic> medicationData,
  ) async {
    try {
      // Get the current user ID as fallback
      final currentUserId = authService.value.currentUser?.uid;
      final userId = medicationData['userId'] ?? currentUserId;
      
      if (userId == null) {
        print('❌ Cannot log medication taken: No user ID available');
        return;
      }

      await FirebaseFirestore.instance.collection('medication_logs').add({
        'medicationId': medicationId,
        'medicationName': medicationData['name'],
        'dosage': medicationData['dosage'],
        'scheduledTime': medicationData['time'],
        'takenAt': FieldValue.serverTimestamp(),
        'status': 'taken',
        'userId': userId,
      });

      print('✅ Medication marked as taken and logged');
    } catch (e) {
      print('❌ Error logging medication taken: $e');
    }
  }

  // Log medication as skipped
  Future<void> _logMedicationSkipped(
    String medicationId,
    Map<String, dynamic> medicationData,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('medication_logs').add({
        'medicationId': medicationId,
        'medicationName': medicationData['name'],
        'dosage': medicationData['dosage'],
        'scheduledTime': medicationData['time'],
        'skippedAt': FieldValue.serverTimestamp(),
        'status': 'skipped',
        'userId': medicationData['userId'],
      });

      print('⏭️ Medication marked as skipped and logged');
    } catch (e) {
      print('❌ Error logging medication skipped: $e');
    }
  }

  // Schedule snoozed alarm
  void _scheduleSnoozedAlarm(
    BuildContext context,
    String medicationId,
    Map<String, dynamic> medicationData,
    int minutes,
  ) async {
    try {
      // Get the current user ID as fallback
      final currentUserId = authService.value.currentUser?.uid;
      final userId = medicationData['userId'] ?? currentUserId;
      
      if (userId == null) {
        print('❌ Cannot log medication snooze: No user ID available');
        return;
      }

      await FirebaseFirestore.instance.collection('medication_logs').add({
        'medicationId': medicationId,
        'medicationName': medicationData['name'],
        'dosage': medicationData['dosage'],
        'scheduledTime': medicationData['time'],
        'snoozedAt': FieldValue.serverTimestamp(),
        'snoozeMinutes': minutes,
        'status': 'snoozed',
        'userId': userId,
      });

      print('⏰ Scheduling snoozed alarm for $minutes minutes');

      Future.delayed(Duration(minutes: minutes), () {
        if (_isInitialized && context.mounted) {
          print('🔔 Showing snoozed alarm for: ${medicationData['name']}');
          // Remove from triggered alarms so it can trigger again
          _triggeredAlarms.removeWhere((key) => key.startsWith(medicationId));
          _showMedicationAlarm(context, medicationId, medicationData);
        }
      });

      print('⏰ Medication snoozed for $minutes minutes');
    } catch (e) {
      print('❌ Error logging medication snooze: $e');
    }
  }

  // Manual trigger for testing
  void triggerMedicationAlarm(
    BuildContext context, {
    required String medicationId,
    required Map<String, dynamic> medicationData,
  }) {
    if (!_isInitialized) {
      print('❌ Cannot trigger alarm: AlarmService not initialized');
      return;
    }

    print('🧪 Manual trigger for medication alarm: ${medicationData['name']}');
    _showMedicationAlarm(context, medicationId, medicationData);
  }

  // Manual trigger for task alarms
  void triggerTaskAlarm(
    BuildContext context, {
    required String taskId,
    required Map<String, dynamic> taskData,
  }) {
    if (!_isInitialized) {
      print('❌ Cannot trigger task alarm: AlarmService not initialized');
      return;
    }

    print('🧪 Manual trigger for task alarm: ${taskData['title']}');
    _showTaskAlarm(context, taskId, taskData);
  }

  // Show task alarm dialog
  void _showTaskAlarm(
    BuildContext context,
    String taskId,
    Map<String, dynamic> taskData,
  ) {
    if (!context.mounted) return;
    
    final taskTitle = taskData['title'] ?? 'Untitled Task';
    final startTime = taskData['startTime'] ?? '';
    final endTime = taskData['endTime'] ?? '';
    final todos = taskData['todos'] as List? ?? [];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.task_alt, color: Colors.deepPurple, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Task Reminder',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taskTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              if (startTime.isNotEmpty || endTime.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.teal, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Time: ${_formatTaskTime(startTime)} - ${_formatTaskTime(endTime)}',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
              if (todos.isNotEmpty) ...[
                Text(
                  'Todo Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                ...todos.take(3).map((todo) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text(
                    '• ${todo.toString()}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )).toList(),
                if (todos.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Text(
                      '... and ${todos.length - 3} more items',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Snooze',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally navigate to task page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: Text('View Task'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to format task time
  String _formatTaskTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $ampm';
      }
    } catch (e) {
      print('Error formatting task time: $e');
    }
    return time;
  }

  // Debug method to check service status
  void debugServiceStatus() {
    print('🐛 AlarmService Debug Status:');
    print('  - Initialized: $_isInitialized');
    print('  - Initialized for user: $_initializedForUserId');
    print('  - Timer active: ${_medicationCheckTimer?.isActive ?? false}');
    print('  - Context available: ${_context != null}');
    print('  - Context mounted: ${_context?.mounted ?? false}');
    print('  - Current user: ${authService.value.currentUser?.uid ?? 'None'}');
    print('  - Current time: ${DateTime.now()}');
    print('  - Triggered alarms count: ${_triggeredAlarms.length}');
    if (_triggeredAlarms.isNotEmpty) {
      print(
        '  - Triggered alarms: ${_triggeredAlarms.take(5).join(', ')}${_triggeredAlarms.length > 5 ? '...' : ''}',
      );
    }
  }

  // Debug method to check today's medications
  Future<void> debugTodaysMedications() async {
    try {
      final currentUser = authService.value.currentUser;
      if (currentUser == null) {
        print('❌ Cannot debug medications: No authenticated user');
        return;
      }

      final userId = currentUser.uid;
      final now = DateTime.now();
      final currentDate = now.toIso8601String().split('T')[0];
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      print('🩺 DEBUG: Medications for today ($currentDate) at $currentTime:');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: currentDate)
          .get();

      if (snapshot.docs.isEmpty) {
        print('  📭 No medications found for today');
      } else {
        print('  📋 Found ${snapshot.docs.length} medications:');
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final medTime = data['time'] ?? '';
          final timeDiff = _calculateTimeDifference(currentTime, medTime);
          print('    • ${data['name']} - ${medTime} - ${data['dosage']} (ID: ${doc.id}) - Diff: ${timeDiff}min');
        }
      }
    } catch (e) {
      print('❌ Error debugging medications: $e');
    }
  }

  // Debug method to check today's tasks
  Future<void> debugTodaysTasks() async {
    try {
      final currentUser = authService.value.currentUser;
      if (currentUser == null) {
        print('❌ Cannot debug tasks: No authenticated user');
        return;
      }

      final userId = currentUser.uid;
      final now = DateTime.now();
      final currentDate = now.toIso8601String().split('T')[0];
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      print('📋 DEBUG: Tasks for today ($currentDate) at $currentTime:');
      
      // Query tasks for today - checking both single date and date range tasks
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> todaysTasks = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final startDate = data['startDate'] ?? '';
        final endDate = data['endDate'] ?? '';
        
        // Check if task is scheduled for today
        if (startDate.contains(currentDate) || 
            (startDate.compareTo(currentDate) <= 0 && endDate.compareTo(currentDate) >= 0)) {
          todaysTasks.add({'id': doc.id, ...data});
        }
      }

      if (todaysTasks.isEmpty) {
        print('  📭 No tasks found for today');
      } else {
        print('  📋 Found ${todaysTasks.length} tasks:');
        for (var task in todaysTasks) {
          final startTime = task['startTime'] ?? '';
          final endTime = task['endTime'] ?? '';
          final startTimeDiff = _calculateTimeDifference(currentTime, startTime);
          final endTimeDiff = _calculateTimeDifference(currentTime, endTime);
          final isActive = startTimeDiff <= 0 && endTimeDiff >= 0;
          final isDue = startTimeDiff >= -2 && startTimeDiff <= 0;
          
          print('    • ${task['title']} - ${startTime}-${endTime} (ID: ${task['id']})');
          print('      Start diff: ${startTimeDiff}min, End diff: ${endTimeDiff}min');
          print('      Status: ${isDue ? 'DUE NOW' : isActive ? 'ACTIVE' : 'PENDING'}');
          
          final todos = task['todos'] as List? ?? [];
          final todosChecked = task['todosChecked'] as List? ?? [];
          final completedCount = todosChecked.where((checked) => checked == true).length;
          print('      Progress: $completedCount/${todos.length} todos completed');
        }
      }
    } catch (e) {
      print('❌ Error debugging tasks: $e');
    }
  }

  // Helper method to calculate time difference in minutes
  int _calculateTimeDifference(String currentTime, String targetTime) {
    try {
      final currentParts = currentTime.split(':');
      final targetParts = targetTime.split(':');
      
      if (currentParts.length >= 2 && targetParts.length >= 2) {
        final currentMinutes = int.parse(currentParts[0]) * 60 + int.parse(currentParts[1]);
        final targetMinutes = int.parse(targetParts[0]) * 60 + int.parse(targetParts[1]);
        
        return targetMinutes - currentMinutes;
      }
    } catch (e) {
      print('Error calculating time difference: $e');
    }
    return 0;
  }

  // Comprehensive debug method for both medications and tasks
  Future<void> debugAllScheduledItems() async {
    print('🔍 ========== COMPREHENSIVE DEBUG REPORT ==========');
    debugServiceStatus();
    print('');
    await debugTodaysMedications();
    print('');
    await debugTodaysTasks();
    print('🔍 ================ END DEBUG REPORT ================');
  }
}
