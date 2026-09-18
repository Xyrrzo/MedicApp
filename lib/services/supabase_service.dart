import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

/// Single access point for all Supabase operations.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient client = Supabase.instance.client;

  // ---- Auth ----
  Future<AuthResponse> signIn({required String email, required String password}) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signOut() => client.auth.signOut();

  User? get currentUser => client.auth.currentUser;

  // ---- Profile / Role ----
  Future<Profile> getMyProfile() async {
    final data = await client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    return Profile.fromJson(data);
  }

  // ---- Health Units ----
  Future<List<Map<String, dynamic>>> getHealthUnits() async {
    final data = await client
        .from('health_units')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Admin/Officer: add a new health unit.
  Future<void> addHealthUnit({
    required String name,
    required String address,
    required String phone,
    required String openTime,
    required String closeTime,
  }) async {
    await client.from('health_units').insert({
      'name': name,
      'address': address,
      'phone': phone,
      'open_time': openTime,
      'close_time': closeTime,
    });
  }

  /// Admin/Officer: edit a health unit.
  Future<void> updateHealthUnit(int id, Map<String, dynamic> fields) async {
    await client.from('health_units').update(fields).eq('id', id);
  }

  /// Admin: remove a health unit.
  Future<void> deleteHealthUnit(int id) async {
    await client.from('health_units').delete().eq('id', id);
  }

  // ---- Appointments ----
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final data = await client
        .from('appointments')
        .select('*, health_units(name)')
        .eq('user_id', currentUser!.id)
        .order('appointment_date', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Staff: every appointment across all users, with patient + unit names.
  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    final data = await client
        .from('appointments')
        .select('*, health_units(name), profiles(full_name, phone)')
        .order('appointment_date', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> bookAppointment({
    required int healthUnitId,
    required String type,
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    await client.from('appointments').insert({
      'user_id': currentUser!.id,
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

  /// Staff: confirm or complete an appointment.
  Future<void> setAppointmentStatus(int id, String status) async {
    await client.from('appointments').update({'status': status}).eq('id', id);
  }

  // ---- Announcements ----
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final data = await client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Staff: publish a new advisory.
  Future<void> postAnnouncement({
    required String title,
    required String body,
    required String category,
  }) async {
    await client.from('announcements').insert({
      'title': title,
      'body': body,
      'category': category,
      'created_by': currentUser!.id,
    });
  }

  /// Admin: remove an advisory.
  Future<void> deleteAnnouncement(int id) async {
    await client.from('announcements').delete().eq('id', id);
  }

  // ---- Symptom Pre-Screening ----
  Future<void> submitSymptomReport(Map<String, bool> symptoms, String severity, String? notes) async {
    await client.from('symptom_reports').insert({
      'user_id': currentUser!.id,
      'symptoms': symptoms,
      'severity': severity,
      'notes': notes,
    });
  }

  /// Staff: incoming emergency symptom reports.
  Future<List<Map<String, dynamic>>> getSymptomReports() async {
    final data = await client
        .from('symptom_reports')
        .select('*, profiles(full_name, phone)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> markSymptomHandled(int id) async {
    await client.from('symptom_reports').update({'handled': true}).eq('id', id);
  }
}