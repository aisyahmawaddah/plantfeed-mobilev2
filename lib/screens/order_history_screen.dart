// lib/screens/order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_feed/screens/layout.dart';
import 'package:plant_feed/screens/invoice_screen.dart';
import 'package:plant_feed/screens/review_product_screen.dart';
import 'package:plant_feed/model/order_model.dart'; // Ensure this path is correct

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Order>> orderHistory;
  final ApiService _apiService = ApiService();
  bool sortByNewest = true;

  @override
  void initState() {
    super.initState();
    orderHistory = _loadOrderHistory();
  }

  Future<List<Order>> _loadOrderHistory() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('ID');

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final Map<String, dynamic> historyData =
          await _apiService.fetchOrderHistory(userId);

      // Debug: Print the entire historyData to inspect its structure
      debugPrint('Fetched historyData: $historyData');

      List<Order> orders = [];

      // Check if 'all_basket' exists and is a List
      if (historyData.containsKey('all_basket') &&
          historyData['all_basket'] is List) {
        List<dynamic> allBasket = historyData['all_basket'];

        // Debug: Print the length of allBasket
        debugPrint('Number of orders in all_basket: ${allBasket.length}');

        for (var orderJson in allBasket) {
          if (orderJson is Map<String, dynamic>) {
            Order parsedOrder = Order.fromJson(orderJson);
            orders.add(parsedOrder);
            // Debug: Print each parsed order's ID and Seller Name
            debugPrint('Parsed Order ID: ${parsedOrder.id}');
            debugPrint(
                'Parsed Seller Name: ${parsedOrder.product.seller.name}');
          } else {
            debugPrint('Invalid order format: $orderJson');
          }
        }
      } else {
        debugPrint('all_basket is either missing or not a List.');
      }

      // Debug: Print the final list of orders
      debugPrint('Total parsed orders: ${orders.length}');
      for (var order in orders) {
        debugPrint(
            'Order ID: ${order.id}, Seller Name: ${order.product.seller.name}');
      }

      return orders;
    } catch (e) {
      debugPrint('Error loading order history: $e');
      rethrow; // Propagate the error to be handled by FutureBuilder
    }
  }

  void _toggleSortOrder() {
    setState(() {
      sortByNewest = !sortByNewest;
    });
  }

  Future<void> _cancelOrder(int orderId, int sellerId) async {
    try {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _apiService.cancelOrder(orderId, sellerId);

      // Remove the loading indicator
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order canceled successfully.')),
      );

      setState(() {
        orderHistory =
            _loadOrderHistory(); // Refresh order history after cancellation
      });
    } catch (e) {
      // Remove the loading indicator if an error occurs
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel order: $e')),
      );
    }
  }

  Future<void> _confirmCancelOrder(int orderId, int sellerId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cancelOrder(orderId, sellerId);
    }
  }

  Future<void> _completeOrder(int orderId, int sellerId) async {
  try {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Call API to complete the order
    await _apiService.completeOrder(orderId, sellerId); // Pass orderId directly

    // Remove the loading indicator
    Navigator.of(context).pop();

    // Fetch and reload the order history after completing the order.
    setState(() {
      orderHistory = _loadOrderHistory();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as received.')),
    );
  } catch (e) {
    // Remove the loading indicator in case of error
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to complete order: $e')),
    );
  }
}

Future<void> _addToBasket(int orderId, int sellerId) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Directly retrieve the user ID from SharedPreferences
    int? userId = prefs.getInt('ID');

    if (userId == null) {
      throw Exception('User ID not found');
    }

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Call the API service with the order ID, seller ID, and user ID
    await _apiService.orderAgain(orderId, sellerId, userId);

    // Remove the loading indicator
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order added to your basket.')),
    );
  } catch (e) {
    // Remove the loading indicator if an error occurs
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add order to basket: $e')),
    );
  }
}

  Future<void> _reviewProduct(int orderId, int productId, int sellerId) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewProductScreen(
            orderId: orderId,
            productId: productId,
            sellerId: sellerId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start review: $e')),
      );
    }
  }

  Future<void> _viewInvoice(List<Order> matchingOrders) async {
    // Convert List<Order> to List<Map<String, dynamic>>
    List<Map<String, dynamic>> ordersMap =
        matchingOrders.map((order) => order.toJson()).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(orders: ordersMap),
      ),
    );
  }

  // Helper function to get seller name safely
  String _getSellerName(Order order) {
    return order.product.seller.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            tooltip: 'Marketplace',
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AppLayout(selectedIndex: 3),
              ));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: orderHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display error message
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // No order history available
            return const Center(child: Text('No order history available.'));
          }

          List<Order> orders = snapshot.data!;

          // Sort orders based on order ID
          orders.sort((a, b) {
            return sortByNewest ? b.id.compareTo(a.id) : a.id.compareTo(b.id);
          });

          return Column(
            children: [
              // Sorting Toggle
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                        sortByNewest ? 'Newest to Oldest' : 'Oldest to Newest'),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: _toggleSortOrder,
                    ),
                  ],
                ),
              ),
              // List of Orders
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 16.0),
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final sellerName = _getSellerName(order);
                      final status = order.status.toLowerCase();
                      final transactionCode = order.transactionCode;
                      final orderId = order.id; // Using the 'id' field
                      final sellerId = order.product.seller.id;
                      final productId = order.product.productId;

                      // Determine the buttons based on status
                      String statusButtonText;
                      Color statusButtonColor;
                      bool isStatusButtonEnabled = false;
                      VoidCallback? statusButtonAction;

                      String actionButtonText;
                      Color actionButtonColor;
                      VoidCallback? actionButtonAction;

                      switch (status) {
                        case 'payment made':
                          statusButtonText = 'Payment Made';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;

                          actionButtonText = 'Cancel Order';
                          actionButtonColor = Colors.red;
                          actionButtonAction =
                              () => _confirmCancelOrder(orderId, sellerId);
                          break;

                        case 'package order':
                          statusButtonText = 'Package Order';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;

                          actionButtonText = 'Cancel Order';
                          actionButtonColor = Colors.red;
                          actionButtonAction =
                              () => _confirmCancelOrder(orderId, sellerId);
                          break;

                        case 'ship order':
                          statusButtonText =
                              'Ship Order'; // This text can be changed to 'Ship Order' if needed
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled =
                              false; // Assuming you want it disabled until action is taken

                          actionButtonText = 'Complete Order';
                          actionButtonColor = Colors.green;
                          actionButtonAction =
                              () => _completeOrder(orderId, sellerId);
                          break;

                        case 'order received':
                          statusButtonText = 'Review Product';
                          statusButtonColor = Colors.green;
                          isStatusButtonEnabled = true;
                          statusButtonAction = () =>
                              _reviewProduct(orderId, productId, sellerId);

                          actionButtonText = 'Re-Order';
                          actionButtonColor = Colors.orange;
                          actionButtonAction =
                              () => _addToBasket(orderId, sellerId);
                          break;

                        case 'product reviewed':
                          statusButtonText = 'Product Reviewed';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;

                          actionButtonText = 'Re-Order';
                          actionButtonColor = Colors.orange;
                          actionButtonAction =
                              () => _addToBasket(orderId, sellerId);
                          break;

                        case 'cancel':
                          statusButtonText = 'Cancelled';
                          statusButtonColor = Colors.red;
                          isStatusButtonEnabled = false;

                          actionButtonText = 'Re-Order';
                          actionButtonColor = Colors.orange;
                          actionButtonAction =
                              () => _addToBasket(orderId, sellerId);
                          break;

                        default:
                          statusButtonText = 'Unknown Status';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;

                          actionButtonText = 'N/A';
                          actionButtonColor = Colors.grey;
                          actionButtonAction = null;
                          break;
                      }

                      // Status Button Widget
                      Widget statusButton = ElevatedButton(
                        onPressed:
                            isStatusButtonEnabled ? statusButtonAction : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          statusButtonText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );

                      // Action Button Widget
                      Widget actionButton = ElevatedButton(
                        onPressed: actionButtonAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          actionButtonText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order ID
                              Text(
                                'Order ID: ${order.id}', // Using the 'id' field
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Transaction Code
                              Row(
                                children: [
                                  const Icon(Icons.receipt_long,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Transaction Code: $transactionCode',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Seller Name
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Seller: $sellerName',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Status
                              Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Status: ${order.status}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Buttons
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  statusButton,
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Find all orders with the same transaction code
                                      List<Order> matchingOrders = orders
                                          .where((o) =>
                                              o.transactionCode ==
                                              transactionCode)
                                          .toList();
                                      _viewInvoice(matchingOrders);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'View Invoice',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Only display actionButton if it's not 'N/A'
                                  if (actionButtonAction != null) actionButton,
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
