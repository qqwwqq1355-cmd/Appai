import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:3000/api';

  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Authentication APIs
  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String? name,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token'], email);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token'], email);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: await _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user data');
    }
  }

  // Product APIs
  Future<List<dynamic>> getProducts({
    String? search,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;

    final uri = Uri.parse('$_baseUrl/products').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['products'] as List;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Map<String, dynamic>> getProduct(String productId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/$productId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Product not found');
    }
  }

  Future<Map<String, dynamic>> searchProduct({
    String? barcode,
    String? imageUrl,
    String? productName,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/products/search'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (barcode != null) 'barcode': barcode,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (productName != null) 'productName': productName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Product not found');
    }
  }

  Future<List<dynamic>> getProductPrices(String productId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/$productId/prices'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['prices'] as List;
    } else {
      throw Exception('Failed to load prices');
    }
  }

  // Favorites APIs
  Future<void> saveProduct(String productId, {String? notes}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/products/$productId/save'),
      headers: await _getHeaders(includeAuth: true),
      body: jsonEncode({
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to save product');
    }
  }

  Future<List<dynamic>> getSavedProducts() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/products/user/saved'),
      headers: await _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['savedProducts'] as List;
    } else {
      throw Exception('Failed to load saved products');
    }
  }

  // Price Alert APIs
  Future<void> createPriceAlert(
    String productId,
    double targetPrice, {
    String? store,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/products/$productId/alert'),
      headers: await _getHeaders(includeAuth: true),
      body: jsonEncode({
        'targetPrice': targetPrice,
        if (store != null) 'store': store,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create price alert');
    }
  }

  // Token management
  Future<void> _saveToken(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('email', email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}
