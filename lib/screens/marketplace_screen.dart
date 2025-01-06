import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/product_model.dart';
import 'package:plant_feed/screens/basket_summary_screen.dart';
import 'package:plant_feed/screens/order_history_screen.dart'; // Import the Order History Screen
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_feed/screens/my_marketplace_screen.dart';
import 'package:plant_feed/screens/view_product_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  MarketplaceScreenState createState() => MarketplaceScreenState();
}

class MarketplaceScreenState extends State<MarketplaceScreen> {
  late Future<List<Product>> futureProducts;
  final ApiService apiService = ApiService();
  int basketCount = 0;

  @override
  void initState() {
    super.initState();
    futureProducts = apiService.fetchProducts();
    loadBasketItems();
  }

  Future<void> loadBasketItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      basketCount = prefs.getInt('basketCount') ?? 0; // Initialize basket count
    });
  }

  Future<void> saveBasketState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('basketCount', basketCount);
  }

  void addToBasket(Product product) async {
    String? email = await getEmail();

    if (email != null) {
      try {
        await apiService.addToBasket(email, product.productId, 1);
        setState(() {
          basketCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.productName} added to basket!')),
        );
        await saveBasketState();
      } catch (e) {
        if (mounted) { // Check if mounted before using BuildContext
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add product to basket: ${e.toString()}')),
          );
        }
      }
    } else {
      if (mounted) { // Check if mounted before using BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User email not found. Please log in.')),
        );
      }
    }
  }

  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  void buyNow(Product product) async {
    String? email = await getEmail();
    if (email != null) {
      await apiService.buyNow(email, product.productId, 1);
      if (mounted) { // Check if mounted before using BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase processed for ${product.productName}')),
        );
      }
    } else {
      if (mounted) { // Check if mounted before using BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User email not found')),
        );
      }
    }
  }

  void navigateToBasketSummary() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const BasketSummaryScreen()));
  }

  void navigateToOrderHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen())); // Navigate to Order History Screen
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Marketplace'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_basket),
                  if (basketCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                        child: Text(
                          '$basketCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: navigateToBasketSummary,
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: navigateToOrderHistory, // Navigate to Order History Screen
              tooltip: 'Order History',
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Marketplace'),
              Tab(text: 'My Marketplace'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MarketplaceTab(apiService: apiService, addToBasket: addToBasket, buyNow: buyNow),
            MyMarketplaceScreen(), // Add in your existing My Marketplace implementation here
          ],
        ),
      ),
    );
  }
}

class MarketplaceTab extends StatelessWidget {
  final ApiService apiService;
  final Function(Product) addToBasket;
  final Function(Product) buyNow;

  const MarketplaceTab({
    Key? key,
    required this.apiService,
    required this.addToBasket,
    required this.buyNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: apiService.fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                addToBasket: addToBasket,
                buyNow: buyNow,
              );
            },
          );
        }
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Function(Product) addToBasket;
  final Function(Product) buyNow;

  const ProductCard({
    Key? key,
    required this.product,
    required this.addToBasket,
    required this.buyNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying Seller's Profile Photo
            Row(
              children: [
                 CircleAvatar(
                  backgroundImage: NetworkImage(product.seller.photoUrl),  // Accessing photoUrl from seller
                  radius: 20,
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 8),
                // Displaying Seller's Username
                Text(
                  product.seller.username,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Product Name
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProductScreen(productId: product.productId), // Pass the correct argument
                  ),
                );
              },
              child: Text(
                product.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Product Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.productPhoto ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    height: 150,
                    child: const Icon(Icons.broken_image, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Product Info: Price, Stock, Sold
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RM ${product.productPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '${product.productStock} stock left',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${product.productSold} sold',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Buttons: Add to Basket and Buy Now
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => addToBasket(product),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add to basket'),
                ),
                ElevatedButton(
                  onPressed: () => buyNow(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Buy now'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Time Posted
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMMd().add_jm().format(product.timePosted),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
