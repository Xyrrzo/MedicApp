import 'package:supabase_flutter/supabase_flutter.dart';

/// Single access point for all Supabase operations. No auth — open access.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient client = Supabase.instance.client;

  // ---- Health Units ----
  Future<List<Map<String, dynamic>>> getHealthUnits() async {
    final data = await client
        .from('health_units')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  // ---- Appointments ----
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final data = await client
        .from('appointments')
        .select('*, health_units(name)')
        .order('appointment_date', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> bookAppointment({
    required String patientName,
    required int healthUnitId,
    required String type,
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    await client.from('appointments').insert({
      'patient_name': patientName,
      'health_unit_id': healthUnitId,
      'appointment_type': type.toLowerCase(),
      'appointment_date': date.toIso8601String().substring(0, 10),
      'appointment_time': time,
      'notes': notes,
    });
  }

  Future<void> cancelAppointment(int id) async {
    await client.from('appointments').update({'status': 'cancelled'}).eq('id', id);
  }

  // ---- Announcements ----
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final data = await client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // ---- Symptom Pre-Screening ----
  Future<void> submitSymptomReport(Map<String, bool> symptoms, String severity, String? notes) async {
    await client.from('symptom_reports').insert({
      'symptoms': symptoms,
      'severity': severity,
      'notes': notes,
    });
  }
}