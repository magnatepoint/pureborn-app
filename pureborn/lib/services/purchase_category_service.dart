import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/purchase_category.dart';
import '../config/app_config.dart';

class PurchaseCategoryService {
  final String baseUrl = AppConfig.apiBaseUrl.replaceFirst(
    '/api',
    '/api/purchase-categories',
  );

  Future<List<PurchaseCategory>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => PurchaseCategory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load purchase categories');
    }
  }

  Future<PurchaseCategory> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return PurchaseCategory.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load purchase category');
    }
  }

  Future<PurchaseCategory> create(PurchaseCategory category) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category.toJson()),
    );
    if (response.statusCode == 201) {
      return PurchaseCategory.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create purchase category');
    }
  }

  Future<PurchaseCategory> update(String id, PurchaseCategory category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category.toJson()),
    );
    if (response.statusCode == 200) {
      return PurchaseCategory.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update purchase category');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete purchase category');
    }
  }
}
