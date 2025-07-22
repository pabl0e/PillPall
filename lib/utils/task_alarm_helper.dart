import 'package:flutter/material.dart';
import 'package:pillpall/services/alarm_service.dart';

class TaskAlarmHelper {
  // Helper method to trigger alarm from task widget
  static void triggerTaskAlarm(
    BuildContext context, {
    required String taskId,
    required Map<String, dynamic> taskData,
  }) {
    // Use the instance method instead of static method
    AlarmService().triggerTaskAlarm(
      context,
      taskId: taskId,
      taskData: taskData,
    );
  }

  // Helper method to format time for display
  static String formatTimeForDisplay(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $ampm';
      }
    } catch (e) {
      print('Error formatting time: $e');
    }
    return time24;
  }

  // Helper method to check if task is due now (within start time)
  static bool isTaskDueNow(Map<String, dynamic> taskData) {
    try {
      final now = DateTime.now();
      final taskStartDate = DateTime.tryParse(taskData['startDate'] ?? '');
      final taskStartTime = taskData['startTime'] ?? '';
      
      if (taskStartDate == null || taskStartTime.isEmpty) return false;
      
      // Check if it's the same date or within the task date range
      final taskEndDate = DateTime.tryParse(taskData['endDate'] ?? '');
      final isWithinDateRange = taskStartDate.year == now.year &&
                               taskStartDate.month == now.month &&
                               taskStartDate.day == now.day;
      
      if (!isWithinDateRange && taskEndDate != null) {
        // Check if today is within the task date range
        final isTodayInRange = (now.isAfter(taskStartDate) || 
                               (now.year == taskStartDate.year && 
                                now.month == taskStartDate.month && 
                                now.day == taskStartDate.day)) &&
                              (now.isBefore(taskEndDate) || 
                               (now.year == taskEndDate.year && 
                                now.month == taskEndDate.month && 
                                now.day == taskEndDate.day));
        if (!isTodayInRange) return false;
      } else if (!isWithinDateRange) {
        return false;
      }
      
      // Check if it's the start time (within 1 minute tolerance)
      final timeParts = taskStartTime.split(':');
      if (timeParts.length >= 2) {
        final taskHour = int.parse(timeParts[0]);
        final taskMinute = int.parse(timeParts[1]);
        
        return (now.hour == taskHour && 
                (now.minute == taskMinute || 
                 now.minute == taskMinute + 1));
      }
    } catch (e) {
      print('Error checking if task is due: $e');
    }
    
    return false;
  }

  // Helper method to check if task is due soon (within start time)
  static bool isTaskDueSoon(Map<String, dynamic> taskData, {int minutesAhead = 5}) {
    try {
      final now = DateTime.now();
      final taskStartDate = DateTime.tryParse(taskData['startDate'] ?? '');
      final taskStartTime = taskData['startTime'] ?? '';
      
      if (taskStartDate == null || taskStartTime.isEmpty) return false;
      
      // Check if it's the same date or within the task date range
      final taskEndDate = DateTime.tryParse(taskData['endDate'] ?? '');
      final isWithinDateRange = taskStartDate.year == now.year &&
                               taskStartDate.month == now.month &&
                               taskStartDate.day == now.day;
      
      if (!isWithinDateRange && taskEndDate != null) {
        // Check if today is within the task date range
        final isTodayInRange = (now.isAfter(taskStartDate) || 
                               (now.year == taskStartDate.year && 
                                now.month == taskStartDate.month && 
                                now.day == taskStartDate.day)) &&
                              (now.isBefore(taskEndDate) || 
                               (now.year == taskEndDate.year && 
                                now.month == taskEndDate.month && 
                                now.day == taskEndDate.day));
        if (!isTodayInRange) return false;
      } else if (!isWithinDateRange) {
        return false;
      }
      
      // Check if it's within the next few minutes of start time
      final timeParts = taskStartTime.split(':');
      if (timeParts.length >= 2) {
        final taskHour = int.parse(timeParts[0]);
        final taskMinute = int.parse(timeParts[1]);
        
        final taskStartDateTime = DateTime(
          now.year, 
          now.month, 
          now.day, 
          taskHour, 
          taskMinute
        );
        
        final difference = taskStartDateTime.difference(now).inMinutes;
        return difference >= 0 && difference <= minutesAhead;
      }
    } catch (e) {
      print('Error checking if task is due soon: $e');
    }
    
    return false;
  }

  // Helper method to check if task is currently active (between start and end time)
  static bool isTaskActive(Map<String, dynamic> taskData) {
    try {
      final now = DateTime.now();
      final taskStartDate = DateTime.tryParse(taskData['startDate'] ?? '');
      final taskStartTime = taskData['startTime'] ?? '';
      final taskEndTime = taskData['endTime'] ?? '';
      
      if (taskStartDate == null || taskStartTime.isEmpty || taskEndTime.isEmpty) return false;
      
      // Check if it's within the task date range
      final taskEndDate = DateTime.tryParse(taskData['endDate'] ?? '');
      final isWithinDateRange = taskStartDate.year == now.year &&
                               taskStartDate.month == now.month &&
                               taskStartDate.day == now.day;
      
      if (!isWithinDateRange && taskEndDate != null) {
        final isTodayInRange = (now.isAfter(taskStartDate) || 
                               (now.year == taskStartDate.year && 
                                now.month == taskStartDate.month && 
                                now.day == taskStartDate.day)) &&
                              (now.isBefore(taskEndDate) || 
                               (now.year == taskEndDate.year && 
                                now.month == taskEndDate.month && 
                                now.day == taskEndDate.day));
        if (!isTodayInRange) return false;
      } else if (!isWithinDateRange) {
        return false;
      }
      
      // Check if current time is between start and end time
      final startTimeParts = taskStartTime.split(':');
      final endTimeParts = taskEndTime.split(':');
      
      if (startTimeParts.length >= 2 && endTimeParts.length >= 2) {
        final startHour = int.parse(startTimeParts[0]);
        final startMinute = int.parse(startTimeParts[1]);
        final endHour = int.parse(endTimeParts[0]);
        final endMinute = int.parse(endTimeParts[1]);
        
        final startTimeInMinutes = startHour * 60 + startMinute;
        final endTimeInMinutes = endHour * 60 + endMinute;
        final currentTimeInMinutes = now.hour * 60 + now.minute;
        
        // Handle case where task spans midnight
        if (endTimeInMinutes < startTimeInMinutes) {
          return currentTimeInMinutes >= startTimeInMinutes || currentTimeInMinutes <= endTimeInMinutes;
        } else {
          return currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes <= endTimeInMinutes;
        }
      }
    } catch (e) {
      print('Error checking if task is active: $e');
    }
    
    return false;
  }

  // Helper method to get time until next task
  static String getTimeUntilTask(Map<String, dynamic> taskData) {
    try {
      final now = DateTime.now();
      final taskStartDate = DateTime.tryParse(taskData['startDate'] ?? '');
      final taskStartTime = taskData['startTime'] ?? '';
      
      if (taskStartDate == null || taskStartTime.isEmpty) return 'Unknown';
      
      final timeParts = taskStartTime.split(':');
      if (timeParts.length >= 2) {
        final taskHour = int.parse(timeParts[0]);
        final taskMinute = int.parse(timeParts[1]);
        
        final taskStartDateTime = DateTime(
          taskStartDate.year, 
          taskStartDate.month, 
          taskStartDate.day, 
          taskHour, 
          taskMinute
        );
        
        final difference = taskStartDateTime.difference(now);
        
        if (difference.isNegative) {
          // Check if task is still active (hasn't ended yet)
          if (isTaskActive(taskData)) {
            return 'Active now';
          } else {
            return 'Overdue';
          }
        } else if (difference.inDays > 0) {
          return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
        } else {
          return 'Starting now';
        }
      }
    } catch (e) {
      print('Error calculating time until task: $e');
    }
    
    return 'Unknown';
  }

  // Helper method to get task completion percentage
  static double getTaskCompletionPercentage(Map<String, dynamic> taskData) {
    final todos = taskData['todos'] as List?;
    final todosChecked = taskData['todosChecked'] as List?;
    
    if (todos == null || todos.isEmpty) return 0.0;
    if (todosChecked == null) return 0.0;
    
    int completedCount = 0;
    for (int i = 0; i < todos.length && i < todosChecked.length; i++) {
      if (todosChecked[i] == true) {
        completedCount++;
      }
    }
    
    return completedCount / todos.length;
  }

  // Helper method to check if task is completed
  static bool isTaskCompleted(Map<String, dynamic> taskData) {
    return getTaskCompletionPercentage(taskData) == 1.0;
  }
}
