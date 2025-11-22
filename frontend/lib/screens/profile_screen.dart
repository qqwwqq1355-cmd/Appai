import 'package:flutter/material.dart';
import 'package:shoplensx/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  String _userEmail = '';
  bool _isLoading = true;
  List<dynamic> _savedProducts = [];
  int _scanCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final email = await _apiService.getUserEmail();
      setState(() {
        _userEmail = email ?? 'User';
        _isLoading = false;
      });
      
      // Load saved products
      _loadSavedProducts();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSavedProducts() async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // final products = await _apiService.getSavedProducts();
      setState(() {
        _savedProducts = [
          // Mock data
          {'name': 'Wireless Headphones', 'price': 199.99, 'savedAt': '2025-11-20'},
          {'name': 'Smart Watch', 'price': 299.99, 'savedAt': '2025-11-19'},
        ];
      });
    } catch (e) {
      print('Error loading saved products: $e');
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _apiService.logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            Tab(icon: Icon(Icons.notifications), text: 'Alerts'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildFavoritesTab(),
                _buildAlertsTab(),
              ],
            ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _userEmail.isNotEmpty ? _userEmail[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member since ${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Statistics
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Products Scanned',
                  _scanCount.toString(),
                  Icons.qr_code_scanner,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Saved Items',
                  _savedProducts.length.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Price Alerts',
                  '0',
                  Icons.notifications_active,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Money Saved',
                  '\$0',
                  Icons.savings,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Settings
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            'Notifications',
            'Manage price alerts and updates',
            Icons.notifications,
            () {},
          ),
          _buildSettingsTile(
            'Language',
            'English',
            Icons.language,
            () {},
          ),
          _buildSettingsTile(
            'Currency',
            'USD (\$)',
            Icons.attach_money,
            () {},
          ),
          _buildSettingsTile(
            'About',
            'Version 1.0.0',
            Icons.info,
            () {
              showAboutDialog(
                context: context,
                applicationName: 'ShopLensX',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: [
                  const Text('Smart shopping with AI & AR'),
                  const SizedBox(height: 8),
                  const Text('© 2025 ShopLensX'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildFavoritesTab() {
    if (_savedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No saved products yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan products and save them here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Product'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _savedProducts.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final product = _savedProducts[index];
        return ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag, size: 32),
          ),
          title: Text(
            product['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${product['price']}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Saved on ${product['savedAt']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // TODO: Implement delete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Remove from favorites')),
              );
            },
          ),
          onTap: () {
            // TODO: Navigate to product details
          },
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No price alerts set',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Get notified when prices drop',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scan a product first to set price alerts'),
                ),
              );
            },
            icon: const Icon(Icons.add_alert),
            label: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }
}
