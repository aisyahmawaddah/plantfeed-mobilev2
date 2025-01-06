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

      debugPrint('Fetched historyData: $historyData');

      List<Order> orders = [];

      if (historyData.containsKey('all_basket') &&
          historyData['all_basket'] is List) {
        List<dynamic> allBasket = historyData['all_basket'];
        debugPrint('Number of orders in all_basket: ${allBasket.length}');

        for (var orderJson in allBasket) {
          if (orderJson is Map<String, dynamic>) {
            Order parsedOrder = Order.fromJson(orderJson);
            orders.add(parsedOrder);

            // Since item is non-nullable, no need to check for null
            debugPrint('Parsed Order ID: ${parsedOrder.id}');
            debugPrint('Parsed Seller Name: ${parsedOrder.item.product.seller.name}');
          } else {
            debugPrint('Invalid order format: $orderJson');
          }
        }
      } else {
        debugPrint('all_basket is either missing or not a List.');
      }

      debugPrint('Total parsed orders: ${orders.length}');
      for (var order in orders) {
        debugPrint('Order ID: ${order.id}, Seller Name: ${order.item.product.seller.name}');
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _apiService.cancelOrder(orderId, sellerId);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order canceled successfully.')),
      );

      setState(() {
        orderHistory = _loadOrderHistory();
      });
    } catch (e) {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _apiService.completeOrder(orderId, sellerId);

      Navigator.of(context).pop();

      setState(() {
        orderHistory = _loadOrderHistory();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as received.')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete order: $e')),
      );
    }
  }

  Future<void> _addToBasket(int orderId, int sellerId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('ID');

      if (userId == null) {
        throw Exception('User ID not found');
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _apiService.orderAgain(orderId, sellerId, userId);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order added to your basket.')),
      );
    } catch (e) {
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
    if (matchingOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders found for this transaction.')),
      );
      return;
    }

    final transactionCode = matchingOrders[0].transactionCode;
    final shippingCost = matchingOrders[0].orderInfo.shipping;
    final total = matchingOrders[0].orderInfo.total;

    List<Map<String, dynamic>> itemsMap = [];
    for (var order in matchingOrders) {
      final item = order.item; // Single item because of your model
      itemsMap.add({
        'productName': item.product.productName,
        'productPrice': item.product.productPrice.toString(),
        'productqty': item.quantity,
      });
    }

    debugPrint('Items passed to InvoiceScreen: $itemsMap');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(
          order: {
            'transaction_code': transactionCode,
            'order_info': {
              'shipping': shippingCost,
              'total': total,
            },
            'items': itemsMap,
          },
        ),
      ),
    );
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No order history available.'));
          }

          List<Order> orders = snapshot.data!;

          // Group orders by transaction code
          Map<String, List<Order>> groupedOrders = {};
          for (var order in orders) {
            String txnCode = order.transactionCode;
            if (!groupedOrders.containsKey(txnCode)) {
              groupedOrders[txnCode] = [];
            }
            groupedOrders[txnCode]?.add(order);
          }

          // Convert the map to a list for sorting
          List<MapEntry<String, List<Order>>> groupedOrdersList = groupedOrders.entries.toList();

          // Sort the grouped orders
          groupedOrdersList.sort((a, b) {
            try {
              // Extract DateTime from transaction_code
              // Assuming transaction_code is in the format 'TRANS#YYYY-MM-DD HH:MM:SS'
              String dateStringA = a.key.replaceFirst('TRANS#', '');
              String dateStringB = b.key.replaceFirst('TRANS#', '');
              DateTime aTime = DateTime.parse(dateStringA);
              DateTime bTime = DateTime.parse(dateStringB);
              return sortByNewest ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
            } catch (e) {
              debugPrint('Error parsing transaction_code dates: $e');
              return 0;
            }
          });

          return Column(
            children: [
              // Sorting Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(sortByNewest ? 'Newest to Oldest' : 'Oldest to Newest'),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: _toggleSortOrder,
                    ),
                  ],
                ),
              ),
              // List of Grouped Orders
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  child: ListView.builder(
                    itemCount: groupedOrdersList.length,
                    itemBuilder: (context, index) {
                      final transactionCode = groupedOrdersList[index].key;
                      final matchingOrders = groupedOrdersList[index].value;
                      final shippingCost = matchingOrders[0].orderInfo.shipping;
                      final total = matchingOrders[0].orderInfo.total;
                      final sellerName = matchingOrders[0].buyer.name;
                      final sellerId = matchingOrders[0].buyer.id;

                      // Determine the buttons based on status
                      String statusButtonText;
                      Color statusButtonColor;
                      bool isStatusButtonEnabled = false;
                      VoidCallback? statusButtonAction;

                      String actionButtonText;
                      Color actionButtonColor;
                      VoidCallback? actionButtonAction;

                      String status = matchingOrders[0].status.toLowerCase();

                      switch (status) {
                        case 'payment made':
                          statusButtonText = 'Payment Made';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;
                          actionButtonText = 'Cancel Order';
                          actionButtonColor = Colors.red;
                          actionButtonAction = () => _confirmCancelOrder(matchingOrders[0].id, sellerId);
                          break;

                        case 'package order':
                          statusButtonText = 'Package Order';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;
                          actionButtonText = 'Cancel Order';
                          actionButtonColor = Colors.red;
                          actionButtonAction = () => _confirmCancelOrder(matchingOrders[0].id, sellerId);
                          break;

                        case 'ship order':
                          statusButtonText = 'Ship Order';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;
                          actionButtonText = 'Complete Order';
                          actionButtonColor = Colors.green;
                          actionButtonAction = () => _completeOrder(matchingOrders[0].id, sellerId);
                          break;

                        case 'order received':
                          statusButtonText = 'Review Product';
                          statusButtonColor = Colors.green;
                          isStatusButtonEnabled = true;
                          statusButtonAction = () => _reviewProduct(
                              matchingOrders[0].id,
                              matchingOrders[0].item.product.productId,
                              sellerId);
                          actionButtonText = 'Re-Order';
                          actionButtonColor = Colors.orange;
                          actionButtonAction = () => _addToBasket(matchingOrders[0].id, sellerId);
                          break;

                        case 'product reviewed':
                          statusButtonText = 'Product Reviewed';
                          statusButtonColor = Colors.blueGrey;
                          isStatusButtonEnabled = false;
                          actionButtonText = 'Re-Order';
                          actionButtonColor = Colors.orange;
                          actionButtonAction = () => _addToBasket(matchingOrders[0].id, sellerId);
                          break;

                        case 'cancel':
                          statusButtonText = 'Cancelled';
                          statusButtonColor = Colors.red;
                          isStatusButtonEnabled = false;
                          actionButtonText = 'Re-Order';
                          actionButtonColor = Colors.orange;
                          actionButtonAction = () => _addToBasket(matchingOrders[0].id, sellerId);
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
                        onPressed: isStatusButtonEnabled ? statusButtonAction : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transaction Code
                              Text(
                                'Transaction Code: $transactionCode',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              // Seller Name
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.grey),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      'Seller: $sellerName',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              // Status
                              Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.grey),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      'Status: ${matchingOrders[0].status}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              // Buttons
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  statusButton, // Status button
                                  const SizedBox(height: 8.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Find all orders with the same transaction code
                                      List<Order> matchingOrders = orders
                                          .where((o) => o.transactionCode == transactionCode)
                                          .toList();
                                      _viewInvoice(matchingOrders);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'View Invoice',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
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
