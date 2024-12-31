import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart'; // Replace with your actual service file
//import 'order_track_screen.dart'; // Import the TrackOrderPage widget

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({Key? key}) : super(key: key);

  @override
  _OrdersListPageState createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {
  final ApiService apiService = ApiService();
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // Load orders from the API
  void loadOrders() async {
    try {
      final fetchedOrders = await apiService.fetchOrders();
      if (mounted) {
        setState(() {
          orders = fetchedOrders;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load orders")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Order History"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Packaged"),
              Tab(text: "Shipped"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: TabBarView(
          children: List.generate(5, (index) {
            return OrderListTab(
              key: ValueKey(index),
              status: indexToStatus(index),
              orders: orders,
              onUpdate: loadOrders, // Callback to refresh orders after update
            );
          }),
        ),
      ),
    );
  }

  String indexToStatus(int index) {
    switch (index) {
      case 0:
        return "Payment Made";
      case 1:
        return "Package Order";
      case 2:
        return "Ship Order";
      case 3:
        return "Order Received";
      case 4:
        return "Cancel";
      default:
        return "";
    }
  }
}

class OrderListTab extends StatelessWidget {
  final String status;
  final List<dynamic> orders;
  final VoidCallback onUpdate;

  const OrderListTab({
    Key? key,
    required this.status,
    required this.orders,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredOrders = orders.where((o) => o['status'] == status).toList();

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          child: ListTile(
            title: Text("Transaction: ${order['transaction_code']}"),
            subtitle: Text("Status: ${order['status']}"),
            onTap: () {
              // Navigate to the TrackOrderPage
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => TrackOrderPage(order: order),
              //   ),
              // );
            },
            trailing: ElevatedButton(
              onPressed: () async {
                // Show dialog to update the order status
                String? newStatus = await showStatusDialog(context, order['status']);
                if (newStatus != null && newStatus != order['status']) {
                  try {
                    await ApiService().updateOrderStatus(order['transaction_code'], newStatus);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Order status updated successfully!")),
                      );
                    }
                    onUpdate(); // Refresh the orders
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to update order status")),
                      );
                    }
                  }
                }
              },
              child: const Text("Update"),
            ),
          ),
        );
      },
    );
  }
}

// Function to show a dialog for selecting order status
Future<String?> showStatusDialog(BuildContext context, String currentStatus) async {
  List<String> statuses = [
    "Payment Made",
    "Package Order",
    "Ship Order",
    "Order Received",
    "Cancel"
  ];
  String? selectedStatus = currentStatus;

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Update Order Status"),
        content: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          onChanged: (String? newValue) {
            selectedStatus = newValue;
            Navigator.of(context).pop(selectedStatus);
          },
          items: statuses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      );
    },
  );
}
