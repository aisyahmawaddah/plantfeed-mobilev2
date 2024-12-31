import 'package:flutter/material.dart';
import 'package:plant_feed/model/product_model.dart';
import 'package:plant_feed/model/review_model.dart';
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
  List<Review> reviews = []; // Store reviews here

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
  try {
    product = await apiService.fetchProductDetails(widget.productId);
  } catch (error) {
    print('Error fetching product details: $error');
    setState(() {
      product = null; // Explicitly set product to null
    });
  }

  try {
    reviews = await apiService.fetchReviews(widget.productId);
  } catch (error) {
    print('Error fetching reviews: $error');
    reviews = []; // Set reviews to an empty list on error
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
              ? const Center(child: Text('Failed to load product')) // Handle null product state
              : buildProductDetails(), // Call method to build detailed view
    );
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
                imageUrl: product!.productPhoto != null 
                    ? '${Config.apiUrl}${product!.productPhoto}' // Ensuring URL is safe if not null
                    : '',
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
                backgroundImage: (product!.seller.photo != null && product!.seller.photo!.isNotEmpty)
                    ? NetworkImage(product!.seller.photo!) // Ensure the photo is not null or empty
                    : const AssetImage('assets/images/placeholder_image.png') as ImageProvider,
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
reviews.isNotEmpty
    ? ListView.builder(
        shrinkWrap: true, // Allows the ListView to take up the required height
        physics: const NeverScrollableScrollPhysics(), // Disable own scrolling
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index]; // Fetching the review object
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (review.reviewer.photo != null && review.reviewer.photo!.isNotEmpty)
                  ? NetworkImage(review.reviewer.photo!) // Use photo URL safely with null check
                  : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            ),
            title: Text(review.reviewer.username), // Displaying reviewer's username
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.content), // Displaying review content
                const SizedBox(height: 4),
                Text(
                  review.date, // Displaying review date
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      )
    : const Text('No reviews yet.'), // Message when no reviews
          ],
        ),
      ),
    );
  }
}
