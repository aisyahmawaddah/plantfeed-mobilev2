import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/basket_item_model.dart';
import 'package:plant_feed/screens/checkout_screen.dart';

class BasketSummaryScreen extends StatefulWidget {
  const BasketSummaryScreen({Key? key}) : super(key: key);

  @override
  BasketSummaryScreenState createState() => BasketSummaryScreenState();
}

class BasketSummaryScreenState extends State<BasketSummaryScreen> {
  List<BasketItem> _basketItems = [];
  double _totalPrice = 0.0;
  bool _isLoading = true;
  Map<int, bool> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    refreshBasketSummary();
  }

  Future<void> refreshBasketSummary() async {
    setState(() => _isLoading = true);

    // Fetch updated items
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      // Fetch updated basket summary, which should reflect the payment
      final items = await apiService.fetchBasketSummary();
      if (!mounted) return;
      setState(() {
        _basketItems = items;
        _totalPrice = _basketItems.fold(
            0,
            (total, item) =>
                total + (item.productId.productPrice * item.productQty));
        _selectedProducts = {
          for (var item in items) item.id: false // Using basket item ID
        };
      });
    } catch (error) {
      debugPrint(error.toString());
      if (!mounted) return;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> removeBasketItem(int id) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.removeFromBasket(id);
      refreshBasketSummary(); // Update UI with the latest basket data
    } catch (error) {
      debugPrint('Error removing item: $error');
    }
  }

  Future<void> updateBasketItemQuantity(int id, int newQuantity) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final currentItem = _basketItems.firstWhere((item) => item.id == id);

      if (newQuantity > currentItem.productQty) {
        await apiService.addBasketQuantity(id);
      } else if (newQuantity < currentItem.productQty) {
        if (newQuantity < 1) {
          await removeBasketItem(
              id); // Direct removal if quantity is reduced to less than 1
        } else {
          await apiService.removeFromBasket(id);
        }
      }
      refreshBasketSummary();
    } catch (error) {
      debugPrint('Failed to update item quantity: $error');
    }
  }

  Future<void> checkoutSelected() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final userId = await _getUserId();

      // Debug log to see selection state
      debugPrint("Current Selected Products: $_selectedProducts");

      List<int> selectedBasketIds = _selectedProducts.keys
          .where((id) => _selectedProducts[id] == true)
          .toList();

      if (selectedBasketIds.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items selected for checkout!')),
          );
        }
        return;
      }

      // Proceed with the checkout API call
      final result = await apiService.checkout(userId, selectedBasketIds);
      debugPrint("Checkout response: $result");

      // Use a utility method to handle navigation
      _navigateToCheckoutScreen(result);
    } catch (error) {
      debugPrint("Checkout failed: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: ${error.toString()}')),
        );
      }
    }
  }

  Future<void> checkoutAll() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.checkoutAll(); // Call API for all items.

      // Navigate using the same utility function
      _navigateToCheckoutScreen(result);
    } catch (error) {
      debugPrint("Checkout All failed: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout All failed: ${error.toString()}')),
        );
      }
    }
  }

  void _navigateToCheckoutScreen(Map<String, dynamic> result) {
  double totalCheckout = result['totalCheckout'];

  // Constructing items and subtotals maps based on the API response
  Map<String, Map<String, dynamic>> items = {};
  Map<String, double> sellerSubtotals = {};

  for (var key in result['product_details'].keys) {
    items[key] = {
      'subtotal': result['subtotals'][key].toDouble(),
      'name': result['product_details'][key]['name'],
      'seller': result['product_details'][key]['seller_name'],
      'quantity': result['product_details'][key]['quantity'],
      'photo': result['product_details'][key]['photo'],
    };

    // Assuming result contains seller subtotal information
    String seller = result['product_details'][key]['seller_name'];
    double subtotal = result['subtotals'][key].toDouble();
    sellerSubtotals[seller] = sellerSubtotals[seller] != null
        ? sellerSubtotals[seller]! + subtotal
        : subtotal;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckoutScreen(
        totalCheckout: totalCheckout,
        items: items,
        sellerSubtotals: sellerSubtotals, // Pass sellerSubtotals here
      ),
    ),
  );
}

  // Retrieve user ID from SharedPreferences
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId =
        prefs.getInt('ID'); // Assuming user ID is stored with this key.

    if (userId == null) {
      throw Exception(
          'User ID not found.'); // Handle the case where user ID is not found.
    }

    return userId; // Return the user ID directly as an int.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Basket', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _basketItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your basket is empty!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _basketItems.length,
                  itemBuilder: (context, index) {
                    final item = _basketItems[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _selectedProducts[item.id] ??
                                      false, // Check if selected
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _selectedProducts[item.id] =
                                          value ?? false; // Update selection
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          item.productId.productPhoto ??
                                              'default_image_url'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productId.productName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      // Displaying the seller name correctly
                                      Text(
                                        'Seller: ${item.sellerInfo.username}', // Ensure we're referencing the seller's username
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10), // Spacing
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Price: RM ${item.productId.productPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Quantity: ${item.productQty}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => updateBasketItemQuantity(
                                      item.id, item.productQty + 1),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (item.productQty > 1) {
                                      updateBasketItemQuantity(
                                          item.id, item.productQty - 1);
                                    } else {
                                      removeBasketItem(item.id);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.remove),
                                ),
                                ElevatedButton(
                                  onPressed: () => removeBasketItem(item.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Total: RM ${_totalPrice.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        checkoutSelected, // Calls the checkout for selected items
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Checkout Selected'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: checkoutAll, // Calls checkout for all items
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Checkout All'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
