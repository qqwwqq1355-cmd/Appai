import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/haptics.dart';
import '../utils/animations.dart';
import '../widgets/loading_skeleton.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isPriceAlertSet = false;
  bool _isInComparison = false;

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openStore() async {
    await Haptics.medium();
    final url = widget.product['storeUrl'] ?? widget.product['link'] ?? '';
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _toggleFavorite() async {
    await Haptics.light();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleComparison() async {
    await Haptics.light();
    setState(() {
      _isInComparison = !_isInComparison;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isInComparison ? 'Added to comparison' : 'Removed from comparison'),
        duration: const Duration(seconds: 2),
        action: _isInComparison
            ? SnackBarAction(
                label: 'Compare',
                onPressed: () {
                  Navigator.pushNamed(context, '/comparison');
                },
              )
            : null,
      ),
    );
  }

  void _setPriceAlert() async {
    await Haptics.medium();
    setState(() {
      _isPriceAlertSet = !_isPriceAlertSet;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPriceAlertSet
            ? 'Price alert set! We\'ll notify you when price drops'
            : 'Price alert removed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProduct() async {
    await Haptics.light();
    // Share functionality would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.product['images'] as List? ?? [widget.product['image']];
    final specs = widget.product['specifications'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Back Button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await Haptics.light();
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareProduct,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Carousel
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index] ?? '',
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const LoadingSkeleton(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: const Icon(Icons.image_not_supported, size: 60),
                        ),
                      );
                    },
                  ),
                  // Page Indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? theme.colorScheme.primary
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Info
          SliverToBoxAdapter(
            child: AppAnimations.fadeIn(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      widget.product['name'] ?? 'Product Name',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Store Name
                    Row(
                      children: [
                        Icon(Icons.store, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          widget.product['store'] ?? 'Store Name',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price & Rating
                    Row(
                      children: [
                        // Price
                        Text(
                          '\$${widget.product['price'] ?? '0.00'}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Rating
                        RatingBarIndicator(
                          rating: (widget.product['rating'] ?? 0.0).toDouble(),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.product['rating'] ?? '0.0'} (${widget.product['reviews'] ?? 0})',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons Row 1
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _openStore,
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Buy Now'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleComparison,
                            icon: Icon(_isInComparison ? Icons.check : Icons.compare_arrows),
                            label: const Text('Compare'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons Row 2
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleFavorite,
                            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                            label: const Text('Favorite'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _setPriceAlert,
                            icon: Icon(_isPriceAlertSet ? Icons.notifications_active : Icons.notifications_none),
                            label: const Text('Price Alert'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (widget.product['description'] != null) ...[
                      Text(
                        'Description',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product['description'],
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Specifications
                    if (specs.isNotEmpty) ...[
                      Text(
                        'Specifications',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: specs.entries.map((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.dividerColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      entry.key,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      entry.value.toString(),
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

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
          ),
        ],
      ),
    );
  }
}
