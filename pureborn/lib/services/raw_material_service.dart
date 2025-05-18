import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/raw_material.dart';
import '../config/app_config.dart';

class RawMaterialService {
  final String baseUrl = AppConfig.apiBaseUrl.replaceFirst(
    '/api',
    '/api/raw-materials',
  );

  Future<List<RawMaterial>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => RawMaterial.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load raw materials');
    }
  }

  Future<RawMaterial> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return RawMaterial.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load raw material');
    }
  }

  Future<RawMaterial> create(RawMaterial material) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(material.toJson()),
    );
    if (response.statusCode == 201) {
      return RawMaterial.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create raw material');
    }
  }

  Future<RawMaterial> update(String id, RawMaterial material) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(material.toJson()),
    );
    if (response.statusCode == 200) {
      return RawMaterial.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update raw material');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete raw material');
    }
  }
}
