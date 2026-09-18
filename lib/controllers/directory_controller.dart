import 'package:flutter/material.dart';
import '../models/health_unit.dart';
import '../services/supabase_service.dart';

class DirectoryController extends ChangeNotifier {
  final _service = SupabaseService.instance;

  List<HealthUnit> units = [];
  bool isLoading = false;
  String? error;

  Future<void> loadUnits() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final raw = await _service.getHealthUnits();
      units = raw.map(HealthUnit.fromJson).toList();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}