import 'package:flutter/material.dart';
import 'package:plant_feed/config.dart';
import 'package:plant_feed/screens/payment_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final double totalCheckout; // Total amount for the checkout
  final Map<String, Map<String, dynamic>> items; // Product details
  final Map<String, double> sellerSubtotals; // Subtotal for each seller including shipping

  const CheckoutScreen({
    Key? key,
    required this.totalCheckout,
    required this.items,
    required this.sellerSubtotals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gather selected product IDs
    List<int> selectedProductIds = items.keys
        .map((key) => int.parse(key))
        .toList(); // Assuming keys are convertible to int

    // Group items by seller
    Map<String, List<Map<String, dynamic>>> sellerItems = {};
    items.forEach((productId, itemDetails) {
      String sellerName = itemDetails['seller'];
      (sellerItems[sellerName] ??= []).add(itemDetails);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Summary'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display order items grouped by seller
            Expanded(
              child: ListView(
                children: sellerItems.entries.map((entry) {
                  String sellerName = entry.key;
                  double sellerTotal = sellerSubtotals[sellerName]! + 5; // Adding RM 5 shipping

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seller: $sellerName',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          ...entry.value.map((itemDetails) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      '${Config.apiUrl}${itemDetails['photo']}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const CircleAvatar(child: Icon(Icons.error));
                                      },
                                    ),
                                  ),
                                ),
                                title: Text(
                                  itemDetails['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Price: RM ${itemDetails['subtotal'].toStringAsFixed(2)}'),
                                    Text('Quantity: ${itemDetails['quantity']}'),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const Divider(thickness: 1, color: Colors.black54),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Shop Total Price (Including Shipping RM5): RM ${sellerTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Total Amount Display
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'RM ${totalCheckout.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Bottom navigation for payment or cancellation
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to PaymentScreen to collect user information
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      totalAmount: totalCheckout,
                      selectedProductIds: selectedProductIds,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Proceed to Payment'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}