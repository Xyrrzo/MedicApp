import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

/// Reminders are stored LOCALLY on the device (shared_preferences) and
/// mirrored as daily local notifications. No account needed.
class ReminderController extends ChangeNotifier {
  static const _storageKey = 'medalert_reminders';

  List<Reminder> reminders = [];
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    reminders = jsonList
        .map((s) => Reminder.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    isLoading = false;
    // Re-arm notifications for any reminders that aren't marked done
    for (final r in reminders.where((r) => !r.isDone)) {
      await NotificationService.instance.scheduleDaily(
        r.id,
        title: '💊 MedAlert — ${r.title}',
        body: 'Time for your ${r.title}. Tap to open MedAlert.',
        hour: r.hour,
        minute: r.minute,
      );
    }
    notifyListeners();
  }

  Future<bool> add({
    required String title,
    required String type,
    required TimeOfDay time,
  }) async {
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      type: type,
      hour: time.hour,
      minute: time.minute,
      isDone: false,
    );
    reminders.add(reminder);
    await _save();
    await NotificationService.instance.scheduleDaily(
      reminder.id,
      title: '💊 MedAlert — ${reminder.title}',
      body: 'Time for your ${reminder.title}. Tap to open MedAlert.',
      hour: reminder.hour,
      minute: reminder.minute,
    );
    return true;
  }

  Future<void> toggleDone(Reminder reminder) async {
    final updated = Reminder(
      id: reminder.id,
      title: reminder.title,
      type: reminder.type,
      hour: reminder.hour,
      minute: reminder.minute,
      isDone: !reminder.isDone,
    );
    reminders[reminders.indexWhere((r) => r.id == reminder.id)] = updated;
    await _save();
    if (updated.isDone) {
      await NotificationService.instance.cancel(updated.id);
    } else {
      await NotificationService.instance.scheduleDaily(
        updated.id,
        title: '💊 MedAlert — ${updated.title}',
        body: 'Time for your ${updated.title}. Tap to open MedAlert.',
        hour: updated.hour,
        minute: updated.minute,
      );
    }
  }

  Future<void> remove(Reminder reminder) async {
    await NotificationService.instance.cancel(reminder.id);
    reminders.removeWhere((r) => r.id == reminder.id);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      reminders.map((r) => jsonEncode(r.toJson())).toList(),
    );
    notifyListeners();
  }
}