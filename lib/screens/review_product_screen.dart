// lib/screens/review_product_screen.dart

import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:plant_feed/model/product_model.dart';

class ReviewProductScreen extends StatefulWidget {
  final int orderId;
  final int productId;
  final int sellerId;

  const ReviewProductScreen({
    Key? key,
    required this.orderId,
    required this.productId,
    required this.sellerId,
  }) : super(key: key);

  @override
  _ReviewProductScreenState createState() => _ReviewProductScreenState();
}

class _ReviewProductScreenState extends State<ReviewProductScreen> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  final ApiService _apiService = ApiService(); // Define the ApiService instance
  Product? _product; // To store the product details

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      // Fetch product details using productId
      Product product = await _apiService.fetchProductDetails(widget.productId);
      setState(() {
        _product = product;
      });
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product details: $e')),
      );
      Navigator.of(context).pop(); // Return to previous screen
    }
  }

  void _submitReview(BuildContext context) async {
  String reviewContent = _reviewController.text.trim();

  if (reviewContent.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please write a review before submitting.")),
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    // Ensure correct types are passed as ints
    final int orderId = widget.orderId; // Already an int
    final int sellerId = widget.sellerId; // Already an int
    final int productId = widget.productId; // Already an int

    // Call the API with the correct argument order
    await _apiService.reviewProduct(
      orderId,       // First parameter is orderId
      productId,     // Second parameter is productId
      sellerId,      // Third parameter is sellerId
      reviewContent, // Fourth parameter is reviewContent (String)
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully!")),
    );

    Navigator.of(context).pop(); // Return to previous screen after submission
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit review: $e')),
    );
  } finally {
    setState(() {
      _isSubmitting = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      // Show loading indicator while fetching product details
      return Scaffold(
        appBar: AppBar(title: const Text('Review Product')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Details
            Text(
              _product!.productName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Price: RM ${_product!.productPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text('Category: ${_product!.productCategory}'),
            const SizedBox(height: 8),
            Text('Description:'),
            Text(
              _product!.productDesc,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Review Form
            const Text(
              "Leave a Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write your review here...",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitReview(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Make button full width
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
