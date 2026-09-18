import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../models/appointment.dart';
import '../models/health_unit.dart';
import '../services/supabase_service.dart';

/// Powers the Admin & Health Officer dashboards.
class AdminController extends ChangeNotifier {
  final _service = SupabaseService.instance;

  List<HealthUnit> units = [];
  List<Appointment> allAppointments = [];
  List<Announcement> announcements = [];
  List<Map<String, dynamic>> symptomReports = [];
  bool isLoading = false;
  String? error;

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final rawUnits = await _service.getHealthUnits();
      units = rawUnits.map(HealthUnit.fromJson).toList();
      final rawAppts = await _service.getAllAppointments();
      allAppointments = rawAppts.map(Appointment.fromJson).toList();
      final rawAnn = await _service.getAnnouncements();
      announcements = rawAnn.map(Announcement.fromJson).toList();
      symptomReports = await _service.getSymptomReports();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // ---- Health unit management ----
  Future<void> addUnit({
    required String name,
    required String address,
    required String phone,
    required String openTime,
    required String closeTime,
  }) async {
    await _service.addHealthUnit(
      name: name,
      address: address,
      phone: phone,
      openTime: openTime,
      closeTime: closeTime,
    );
    await loadDashboard();
  }

  Future<void> updateUnit(int id, Map<String, dynamic> fields) async {
    await _service.updateHealthUnit(id, fields);
    await loadDashboard();
  }

  Future<void> toggleUnitOpen(int id, bool isOpen) async {
    await _service.updateHealthUnit(id, {'is_open': isOpen});
    await loadDashboard();
  }

  Future<void> deleteUnit(int id) async {
    await _service.deleteHealthUnit(id);
    await loadDashboard();
  }

  // ---- Appointment queue ----
  Future<void> setStatus(int id, String status) async {
    await _service.setAppointmentStatus(id, status);
    await loadDashboard();
  }

  // ---- Announcements ----
  Future<bool> postAnnouncement({
    required String title,
    required String body,
    required String category,
  }) async {
    try {
      await _service.postAnnouncement(title: title, body: body, category: category);
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    await _service.deleteAnnouncement(id);
    await loadDashboard();
  }

  // ---- Emergency reports ----
  Future<void> markHandled(int id) async {
    await _service.markSymptomHandled(id);
    await loadDashboard();
  }
}