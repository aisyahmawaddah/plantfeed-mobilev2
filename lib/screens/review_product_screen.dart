// lib/screens/review_product_screen.dart

import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';

class ReviewProductScreen extends StatelessWidget {
  final int orderId;    // Changed from basketId
  final int productId;
  final int sellerId;

  ReviewProductScreen({Key? key, 
    required this.orderId,
    required this.productId,
    required this.sellerId,
  }) : super(key: key);

  final TextEditingController _reviewController = TextEditingController();

  void _submitReview(BuildContext context) async {
    try {
      // Call API to submit review
      await ApiService().reviewProduct(orderId, sellerId, _reviewController.text);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review submitted successfully!")),
      );
      Navigator.of(context).pop(); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Write your review:"),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your review text here",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitReview(context),
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
