import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marketlens/services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _productData;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args == null) {
        setState(() {
          _errorMessage = 'No product data provided';
          _isLoading = false;
        });
        return;
      }

      // Search for product using barcode or image
      final barcode = args['barcode'] as String?;
      final imagePath = args['imagePath'] as String?;
      
      // TODO: Replace with actual API call when backend has product data
      // Example: final result = await _apiService.searchProduct(barcode: barcode);
      // For now, showing mock data until product database is seeded
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      setState(() {
        _productData = {
          'name': 'Sample Product',
          'imageUrl': imagePath,
          'prices': [
            {'store': 'Amazon', 'price': 199.99, 'url': 'https://amazon.com'},
            {'store': 'eBay', 'price': 189.99, 'url': 'https://ebay.com'},
            {'store': 'AliExpress', 'price': 149.99, 'url': 'https://aliexpress.com'},
          ],
          'reviews': {'average': 4.5, 'count': 1200},
          'alternatives': [
            {'name': 'Alternative Product 1', 'price': 179.99},
            {'name': 'Alternative Product 2', 'price': 169.99},
          ],
          'coupons': [
            {'code': 'SAVE10', 'discount': '10%'},
            {'code': 'NEWUSER', 'discount': '\$15 off'},
          ],
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading product: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Save to favorites
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to favorites')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for product...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_productData == null) {
      return const Center(child: Text('No product data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          _buildProductImage(),
          
          // Product Name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _productData!['name'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Reviews
          _buildReviews(),
          
          const Divider(height: 32),
          
          // Price Comparison
          _buildPriceComparison(),
          
          const Divider(height: 32),
          
          // Coupons
          if (_productData!['coupons']?.isNotEmpty ?? false)
            _buildCoupons(),
          
          const Divider(height: 32),
          
          // Alternatives
          if (_productData!['alternatives']?.isNotEmpty ?? false)
            _buildAlternatives(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final imagePath = _productData!['imageUrl'] as String?;
    
    if (imagePath != null && File(imagePath).existsSync()) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[200],
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      );
    }
    
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
    );
  }

  Widget _buildReviews() {
    final reviews = _productData!['reviews'] as Map<String, dynamic>?;
    if (reviews == null) return const SizedBox.shrink();
    
    final average = (reviews['average'] as num?)?.toDouble() ?? 0.0;
    final count = reviews['count'] as int? ?? 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          RatingBarIndicator(
            rating: average,
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 24.0,
          ),
          const SizedBox(width: 8),
          Text(
            '$average (${count} reviews)',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparison() {
    final prices = _productData!['prices'] as List?;
    if (prices == null || prices.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Price Comparison',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prices.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final price = prices[index] as Map<String, dynamic>;
            final isLowest = index == 0;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isLowest ? Colors.green : Colors.grey[300],
                child: Text(
                  price['store'].toString().substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: isLowest ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                price['store'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: isLowest
                  ? const Text(
                      'Lowest Price',
                      style: TextStyle(color: Colors.green),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${price['price']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _launchURL(price['url']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLowest ? Colors.green : null,
                    ),
                    child: const Text('Buy'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCoupons() {
    final coupons = _productData!['coupons'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Available Coupons',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index] as Map<String, dynamic>;
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coupon['code'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      coupon['discount'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlternatives() {
    final alternatives = _productData!['alternatives'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Similar Products',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: alternatives.length,
            itemBuilder: (context, index) {
              final alt = alternatives[index] as Map<String, dynamic>;
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      alt['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${alt['price']}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
