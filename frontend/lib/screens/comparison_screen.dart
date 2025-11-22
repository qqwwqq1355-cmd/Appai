import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/haptics.dart';
import '../utils/animations.dart';
import '../widgets/loading_skeleton.dart';

class ComparisonScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? products;

  const ComparisonScreen({Key? key, this.products}) : super(key: key);

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  late List<Map<String, dynamic>> _comparisonProducts;
  Set<String> _hiddenSpecs = {};
  int? _bestDealIndex;

  @override
  void initState() {
    super.initState();
    // Use provided products or mock data
    _comparisonProducts = widget.products ?? _getMockProducts();
    _calculateBestDeal();
  }

  List<Map<String, dynamic>> _getMockProducts() {
    return [
      {
        'id': '1',
        'name': 'Sony WH-1000XM5',
        'image': 'https://via.placeholder.com/300',
        'price': 399.99,
        'rating': 4.8,
        'reviews': 1250,
        'store': 'Amazon',
        'specifications': {
          'Brand': 'Sony',
          'Type': 'Over-Ear',
          'Connectivity': 'Bluetooth 5.2',
          'Battery Life': '30 hours',
          'Noise Cancellation': 'Active',
          'Weight': '250g',
          'Color': 'Black',
        },
      },
      {
        'id': '2',
        'name': 'Bose QuietComfort 45',
        'image': 'https://via.placeholder.com/300',
        'price': 329.99,
        'rating': 4.6,
        'reviews': 980,
        'store': 'Best Buy',
        'specifications': {
          'Brand': 'Bose',
          'Type': 'Over-Ear',
          'Connectivity': 'Bluetooth 5.1',
          'Battery Life': '24 hours',
          'Noise Cancellation': 'Active',
          'Weight': '240g',
          'Color': 'Black',
        },
      },
    ];
  }

  void _calculateBestDeal() {
    if (_comparisonProducts.isEmpty) return;

    double bestScore = -1;
    int bestIndex = 0;

    for (int i = 0; i < _comparisonProducts.length; i++) {
      final product = _comparisonProducts[i];
      final price = (product['price'] ?? 999.0) as num;
      final rating = (product['rating'] ?? 0.0) as num;

      // Calculate score: higher rating and lower price is better
      // Normalize: rating (0-5) and price (invert and normalize)
      final priceScore = 1.0 - (price / 1000.0).clamp(0.0, 1.0);
      final ratingScore = rating / 5.0;
      final totalScore = (ratingScore * 0.6) + (priceScore * 0.4);

      if (totalScore > bestScore) {
        bestScore = totalScore;
        bestIndex = i;
      }
    }

    setState(() {
      _bestDealIndex = bestIndex;
    });
  }

  void _removeProduct(int index) async {
    await Haptics.light();
    setState(() {
      _comparisonProducts.removeAt(index);
      if (_comparisonProducts.length < 2) {
        // If less than 2 products, go back
        Navigator.pop(context);
      } else {
        _calculateBestDeal();
      }
    });
  }

  void _toggleSpec(String specName) async {
    await Haptics.light();
    setState(() {
      if (_hiddenSpecs.contains(specName)) {
        _hiddenSpecs.remove(specName);
      } else {
        _hiddenSpecs.add(specName);
      }
    });
  }

  void _saveFavorite() async {
    await Haptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comparison saved to favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allSpecs = _getAllSpecs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Haptics.light();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _saveFavorite,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _toggleSpec,
            itemBuilder: (context) {
              return allSpecs.map((spec) {
                return PopupMenuItem<String>(
                  value: spec,
                  child: Row(
                    children: [
                      Checkbox(
                        value: !_hiddenSpecs.contains(spec),
                        onChanged: (_) => _toggleSpec(spec),
                      ),
                      Text(spec),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: AppAnimations.fadeIn(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Products Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _comparisonProducts.length,
                    (index) => _buildProductCard(index),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Comparison Table
              Card(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Specifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...List.generate(
                            _comparisonProducts.length,
                            (index) => Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  'Product ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spec Rows
                    ...allSpecs.where((spec) => !_hiddenSpecs.contains(spec)).map(
                          (spec) => _buildSpecRow(spec, theme),
                        ),
                  ],
                ),
              ),

              // Banner Ad Placeholder
              const SizedBox(height: 24),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Banner Ad',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = _comparisonProducts[index];
    final theme = Theme.of(context);
    final isBestDeal = index == _bestDealIndex;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: AppAnimations.scaleIn(
        child: Card(
          elevation: isBestDeal ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isBestDeal
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Best Deal Badge
              if (isBestDeal)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Best Deal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Image
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: product['image'] ?? '',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const LoadingSkeleton(
                      width: double.infinity,
                      height: 150,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeProduct(index),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ],
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['store'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product['price'] ?? '0.00'}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: (product['rating'] ?? 0.0).toDouble(),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 14.0,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product['rating']}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String specName, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              specName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...List.generate(
            _comparisonProducts.length,
            (index) {
              final specs = _comparisonProducts[index]['specifications'] as Map<String, dynamic>? ?? {};
              final value = specs[specName] ?? '-';
              return Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    value.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Set<String> _getAllSpecs() {
    final allSpecs = <String>{};
    for (final product in _comparisonProducts) {
      final specs = product['specifications'] as Map<String, dynamic>? ?? {};
      allSpecs.addAll(specs.keys);
    }
    return allSpecs;
  }
}
