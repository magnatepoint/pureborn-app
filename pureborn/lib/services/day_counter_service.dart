import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/day_counter.dart';
import '../utils/constants.dart';

class DayCounterService {
  final String baseUrl = Constants.apiUrl;

  Future<List<DayCounter>> getDayCounters() async {
    final response = await http.get(Uri.parse('$baseUrl/day-counters'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => DayCounter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load day counters');
    }
  }

  Future<DayCounter> getDayCounter(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/day-counters/$id'));
    if (response.statusCode == 200) {
      return DayCounter.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load day counter');
    }
  }

  Future<DayCounter> createDayCounter(DayCounter dayCounter) async {
    final response = await http.post(
      Uri.parse('$baseUrl/day-counters'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dayCounter.toJson()),
    );
    if (response.statusCode == 201) {
      return DayCounter.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create day counter');
    }
  }

  Future<DayCounter> updateDayCounter(String id, DayCounter dayCounter) async {
    final response = await http.put(
      Uri.parse('$baseUrl/day-counters/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dayCounter.toJson()),
    );
    if (response.statusCode == 200) {
      return DayCounter.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update day counter');
    }
  }

  Future<void> deleteDayCounter(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/day-counters/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete day counter');
    }
  }
}
