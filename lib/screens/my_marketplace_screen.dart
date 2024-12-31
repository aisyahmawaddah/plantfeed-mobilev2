import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';
import 'package:plant_feed/model/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plant_feed/screens/update_product_screen.dart';
import 'view_product_screen.dart';
import 'order_list_screen.dart';
import 'add_product_screen.dart';

class MyMarketplaceScreen extends StatefulWidget {
  const MyMarketplaceScreen({Key? key}) : super(key: key);

  @override
  _MyMarketplaceScreenState createState() => _MyMarketplaceScreenState();
}

class _MyMarketplaceScreenState extends State<MyMarketplaceScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> _futureProducts;
  Map<String, dynamic> _shopAnalytics = {}; // For analytics data

  @override
  void initState() {
    super.initState();
    _fetchProductsAndAnalytics();
  }

  void _fetchProductsAndAnalytics() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sellerId = userProvider.getUser?.id ?? 0;

    setState(() {
      _futureProducts = apiService.fetchMyProducts(sellerId);
      _fetchShopAnalytics(sellerId);
    });
  }

  Future<void> _fetchShopAnalytics(int sellerId) async {
    final analytics = await apiService.fetchShopAnalytics(sellerId);
    setState(() {
      _shopAnalytics = analytics;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
  body: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(userProvider),
        const SizedBox(height: 10), // Reduced space after header
        _buildShopAnalytics(),
        const SizedBox(height: 10), // Reduced space after analytics
        Expanded(child: _buildProductsSection()),
      ],
    ),
  ),
);

  }

  // User Header Widget with Buttons
  Widget _buildUserHeader(UserProvider userProvider) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // User Profile and Location
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: userProvider.getUser?.photo != null &&
                    userProvider.getUser!.photo.isNotEmpty
                ? NetworkImage("${apiService.url}${userProvider.getUser?.photo}")
                : const AssetImage('assets/images/placeholder_image.png')
                    as ImageProvider,
            radius: 30,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProvider.getUser?.name ?? 'User Name',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Location: ${userProvider.getUser?.state ?? 'Unknown'}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 15),

      // Buttons in Center
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersListPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white, // White font color
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            label: Text("Orders", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white, // White font color
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Sell Product", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ],
  );
}

  // Shop Analytics Widget
  Widget _buildShopAnalytics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              "Shop Analytics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3,
              ),
              children: [
                _analyticsCard("Gross Income",
                    "RM ${_shopAnalytics['gross_income'] ?? '0'}"),
                _analyticsCard("Products Sold",
                    "${_shopAnalytics['products_sold'] ?? '0'}"),
                _analyticsCard("Products in Shop",
                    "${_shopAnalytics['products_count'] ?? '0'}"),
                _analyticsCard(
                    "Total Orders", "${_shopAnalytics['total_orders'] ?? '0'}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Product Section
  Widget _buildProductsSection() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Products by ${userProvider.getUser?.name ?? ''}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Product List
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products found.'));
              } else {
                final products = snapshot.data!;
                return _buildProductGrid(products);
              }
            },
          ),
        ),
      ],
    );
  }

  // Product Grid Widget
  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          apiService: apiService,
          onDelete: _fetchProductsAndAnalytics,
        );
      },
    );
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final Product product;
  final ApiService apiService;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.apiService,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          SizedBox(
            height: 120, // Fixed height
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: CachedNetworkImage(
                imageUrl: '${apiService.url}${product.productPhoto}',
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Product Name
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProductScreen(productId: product.productId), // Pass the productId
        ),
                );
              },
              child: Text(
                product.productName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Product Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Price: RM ${product.productPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ),
          const SizedBox(height: 8),
          // Edit and Delete Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateProductScreen(product: product),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.edit, size: 14),
                ),

                // Delete Button
                OutlinedButton(
                  onPressed: () async {
                    final success =
                        await apiService.deleteProduct(product.productId);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Product deleted successfully')),
                      );
                      onDelete(); // Trigger a refresh of the product list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete product')),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.delete, size: 14, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
