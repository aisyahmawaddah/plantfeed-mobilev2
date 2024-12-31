import 'package:flutter/material.dart';
import 'package:plant_feed/Services/stripe_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_feed/screens/order_history_screen.dart';
// import 'package:http/http.dart' as http; // Ensure the HTTP package is imported
// import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  final double totalAmount; // Total amount for the payment
  final List<int> selectedProductIds; // Selected product IDs for checkout

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.selectedProductIds,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController(); // Added for address

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data, including full name and email
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? ''; // Load email
    nameController.text = prefs.getString('name') ?? '';   // Load name
  }

  void _showSuccessDialogAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
          );
        });

        return AlertDialog(
          title: const Text("Payment Successful"),
          content: const Text("Thank you! Your payment has been successfully processed."),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Information'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Shipping Information",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                readOnly: true, // Email is auto-filled; user cannot change
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController, // Address input
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () async {
            // Validate input fields
            if (nameController.text.isEmpty || addressController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please complete all fields.')),
              );
              return;
            }

            // Proceed to make payment using the Stripe service
            try {
              // Create the checkout session with the selected products
              final sessionId = await StripeService.instance.createCheckoutSession(
                widget.selectedProductIds,
                {
                  'address': addressController.text, // Pass the address to the API
                  'name': nameController.text, // Optionally, pass the name if needed
                },
              );

              // Open the Stripe payment UI
              if (sessionId != null) {
                await StripeService.instance
                    .openCheckout(sessionId, widget.selectedProductIds);

                // If payment succeeds, show success popup and redirect
                if (mounted) {
                  _showSuccessDialogAndRedirect();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to initialize payment.')),
                );
              }
            } catch (e) {
              // Handle payment failure
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment failed: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Pay Using Stripe'),
        ),
      ),
    );
  }
}