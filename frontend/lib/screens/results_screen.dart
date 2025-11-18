import 'package:flutter/material.dart';
import 'package:flutter_project/services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    try {
      final product = await _apiService.getProduct(1); // Hardcoded product ID
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Results'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Failed to load product'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Placeholder
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image, size: 100, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product Name
                      Text(
                        _product!['name'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Reviews
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star_half, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text('${_product!['reviews']['average']} (${_product!['reviews']['count']} reviews)'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Prices
                      const Text(
                        'Prices',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(_product!['prices'] as List).map((price) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(price['store']),
                            trailing: Text(
                              '\$${price['price']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),

                      // Coupon Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.local_offer),
                          label: const Text('Get Coupon'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
