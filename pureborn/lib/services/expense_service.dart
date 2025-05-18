import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../utils/constants.dart';

class ExpenseService {
  final String baseUrl = Constants.apiUrl;

  Future<List<Expense>> getExpenses() async {
    try {
      final token = await Constants.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    try {
      final token = await Constants.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(expense.toJson()),
      );

      if (response.statusCode == 201) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create expense');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Expense> updateExpense(String id, Expense expense) async {
    try {
      final token = await Constants.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(expense.toJson()),
      );

      if (response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update expense');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final token = await Constants.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
