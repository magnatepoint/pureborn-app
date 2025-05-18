import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/purchase.dart';
import '../utils/logger.dart';

class PurchaseService {
  final String baseUrl;

  PurchaseService({required this.baseUrl});

  Future<List<Purchase>> getPurchases() async {
    final response = await http.get(Uri.parse('$baseUrl/api/purchases'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Purchase.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load purchases');
    }
  }

  Future<Purchase> createPurchase(Purchase purchase) async {
    AppLogger.info('Sending purchase payload: ${purchase.toJson()}');
    final response = await http.post(
      Uri.parse('$baseUrl/api/purchases'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(purchase.toJson()),
    );

    if (response.statusCode == 201) {
      return Purchase.fromJson(json.decode(response.body));
    } else {
      AppLogger.error('Purchase creation failed. Response: ${response.body}');
      throw Exception('Failed to create purchase');
    }
  }

  Future<Purchase> updatePurchase(String id, Purchase purchase) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/purchases/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(purchase.toJson()),
    );

    if (response.statusCode == 200) {
      return Purchase.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update purchase');
    }
  }

  Future<void> deletePurchase(String id) async {
    AppLogger.info('Attempting to delete purchase with id: $id');
    final response = await http.delete(Uri.parse('$baseUrl/api/purchases/$id'));
    AppLogger.info(
      'Delete response status: \\${response.statusCode}, body: \\${response.body}',
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete purchase. Status: \\${response.statusCode}, Body: \\${response.body}',
      );
    }
  }
}
