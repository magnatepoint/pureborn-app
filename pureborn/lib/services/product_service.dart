import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/constants.dart';

class ProductService {
  final String baseUrl = '${Constants.apiUrl}/products';

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Product> getProduct(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 201) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
