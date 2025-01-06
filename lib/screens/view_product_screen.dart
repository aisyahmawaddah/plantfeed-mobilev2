import 'package:flutter/material.dart';
import 'package:plant_feed/model/product_model.dart';
import 'package:plant_feed/Services/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plant_feed/config.dart';

class ViewProductScreen extends StatefulWidget {
  final int productId; // Pass only the product ID

  const ViewProductScreen({Key? key, required this.productId}) : super(key: key);

  @override
  ViewProductScreenState createState() => ViewProductScreenState();
}

class ViewProductScreenState extends State<ViewProductScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = true;
  Product? product; // Nullable Product instance

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetching product details (including reviews)
      product = await apiService.fetchProductDetails(widget.productId);
    } catch (error) {
      print('Error fetching product details: $error');
      setState(() {
        product = null; // Explicitly set product to null on error
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product != null ? product!.productName : 'Loading...'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Failed to load product'))
              : buildProductDetails(), // Call method to build detailed view
    );
  }

  String _getFullImageUrl(String? relativeUrl) {
    if (relativeUrl != null && !relativeUrl.startsWith('http')) {
      return '${Config.apiUrl}$relativeUrl'; // Prepend the base URL if the image URL is relative
    }
    return relativeUrl ?? ''; // Return the URL if it's already absolute or null
  }

  Widget buildProductDetails() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: _getFullImageUrl(product!.productPhoto),
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Product Name
            Text(
              product!.productName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Product Description
            Text(
              product!.productDesc,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Product Price and Stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RM ${product!.productPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                // Safely displaying stock
                Text(
                  '${product!.productStock} left in stock',
                  style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Product Category
            Text(
              'Category: ${product!.productCategory}', // Assume that this field exists
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            // Seller Information
            const Text(
              'Seller Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                // Safely check for seller photo
                backgroundImage: NetworkImage(_getFullImageUrl(product!.seller.photo)),
                radius: 30,
                backgroundColor: Colors.transparent,
              ),
              title: Text(
                'Seller: ${product!.seller.username}', // Displaying the seller's username
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Email: ${product!.seller.email}', // Displaying the seller's email
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            // Customer Reviews Section
            const Text(
              'Customer Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            product!.reviews.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true, // Allows the ListView to take up the required height
                    physics: const NeverScrollableScrollPhysics(), // Disable own scrolling
                    itemCount: product!.reviews.length,
                    itemBuilder: (context, index) {
                      final review = product!.reviews[index]; // Fetching the review object
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reviewer Info: photo, name
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(_getFullImageUrl(review.reviewer.photo)),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review.reviewer.username,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    review.date,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Review Content
                              Text(
                                review.content,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Text('No reviews yet.', style: TextStyle(fontSize: 16, color: Colors.grey)), // Message when no reviews
          ],
        ),
      ),
    );
  }
}
