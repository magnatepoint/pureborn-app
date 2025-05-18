import 'package:flutter/material.dart';
import '../models/day_counter.dart';
import '../services/day_counter_service.dart';

class DayCounterProvider extends ChangeNotifier {
  final DayCounterService _service = DayCounterService();
  List<DayCounter> _dayCounters = [];
  bool _isLoading = false;
  String? _error;

  List<DayCounter> get dayCounters => _dayCounters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDayCounters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dayCounters = await _service.getDayCounters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDayCounter(DayCounter dayCounter) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createDayCounter(dayCounter);
      await loadDayCounters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDayCounter(String id, DayCounter dayCounter) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateDayCounter(id, dayCounter);
      await loadDayCounters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDayCounter(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteDayCounter(id);
      await loadDayCounters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
