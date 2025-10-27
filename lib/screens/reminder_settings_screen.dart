import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/services.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _remindersEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('reminders_enabled') ?? false;
      final hour = prefs.getInt('reminder_hour') ?? 18;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', _remindersEnabled);
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _saveSettings();
      
      if (_remindersEnabled) {
        await _scheduleNotification();
      }
    }
  }

  Future<void> _toggleReminders(bool enabled) async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    if (enabled) {
      // Request permission first
      final permissionGranted = await notificationService.requestPermissions();
      if (!permissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Cannot schedule reminders.'),
          ),
        );
        return;
      }
      
      await _scheduleNotification();
    } else {
      await notificationService.cancelWorkoutReminder();
    }
    
    setState(() {
      _remindersEnabled = enabled;
    });
    await _saveSettings();
  }

  Future<void> _scheduleNotification() async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    await notificationService.scheduleWorkoutReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Workout Reminders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get reminded to log your workouts and stay consistent with your fitness goals.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Reminders'),
                      subtitle: const Text('Receive daily workout reminders'),
                      value: _remindersEnabled,
                      onChanged: _toggleReminders,
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    if (_remindersEnabled) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Reminder Time'),
                        subtitle: Text(_reminderTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: _selectTime,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_remindersEnabled) ...[
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reminders Active',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'You\'ll receive a reminder daily at ${_reminderTime.format(context)}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final notificationService = Provider.of<NotificationService>(context, listen: false);
                    await notificationService.showInstantNotification(
                      title: 'Test Reminder',
                      body: 'This is how your workout reminders will look!',
                    );
                  },
                  child: const Text('Test Notification'),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Tips for Success',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Set your reminder for a time when you\'re usually free\n'
                      '• Consistency is key - try to work out at the same time daily\n'
                      '• Even 10-15 minutes of exercise can make a difference',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}