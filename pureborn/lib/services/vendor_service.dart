import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vendor.dart';
import '../config/app_config.dart';

class VendorService {
  final String baseUrl = AppConfig.apiBaseUrl.replaceFirst(
    '/api',
    '/api/vendors',
  );

  Future<List<Vendor>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Vendor.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load vendors');
    }
  }

  Future<Vendor> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Vendor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load vendor');
    }
  }

  Future<Vendor> create(Vendor vendor) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vendor.toJson()),
    );
    if (response.statusCode == 201) {
      return Vendor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create vendor');
    }
  }

  Future<Vendor> update(String id, Vendor vendor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vendor.toJson()),
    );
    if (response.statusCode == 200) {
      return Vendor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update vendor');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete vendor');
    }
  }
}
