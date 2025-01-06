// lib/models/product_model.dart

import 'package:plant_feed/config.dart';
import 'package:plant_feed/model/review_model.dart';
import 'package:plant_feed/model/person_model.dart';

class Product {
  final int productId;
  final String productName;
  final String productDesc;
  final String productCategory;
  final double productPrice;
  final int productStock;
  final String? productPhoto;
  final int productRating;
  final int productSold;
  final DateTime timePosted;
  final bool restricted;
  final Person seller;
  final List<Review> reviews;

  static const String baseUrl = 'http://127.0.0.1:8000/';

  Product({
    required this.productId,
    required this.productName,
    required this.productDesc,
    required this.productCategory,
    required this.productPrice,
    required this.productStock,
    this.productPhoto,
    required this.productRating,
    required this.productSold,
    required this.timePosted,
    required this.restricted,
    required this.seller,
    this.reviews = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productid'] ?? 0,
      productName: json['productName'] ?? json['name'] ?? 'Unnamed Product',
      productDesc: json['productDesc'] ?? json['description'] ?? 'No Description Available',
      productCategory: json['productCategory'] ?? json['category'] ?? 'Uncategorized',
      productPrice: double.tryParse(json['productPrice']?.toString() ?? json['price']?.toString() ?? '0.0') ?? 0.0,
      productStock: json['productStock'] ?? json['stock'] ?? 0,
      productPhoto: json['productPhoto'] != null
          ? '${Config.apiUrl}${json['productPhoto'] ?? json['photo']}'
          : null,
      productRating: json['productRating'] ?? json['rating'] ?? 0,
      productSold: json['productSold'] ?? json['sold'] ?? 0,
      timePosted: DateTime.tryParse(json['timePosted'] ?? json['time_posted'] ?? '') ?? DateTime.now(),
      restricted: (json['restricted'] is bool) ? json['restricted'] : (json['restricted'] == 'true'),
      seller: Person.fromJson(json['seller_info'] ?? {}),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productid': productId,
      'productName': productName,
      'productDesc': productDesc,
      'productCategory': productCategory,
      'productPrice': productPrice,
      'productStock': productStock,
      'productPhoto': productPhoto,
      'productRating': productRating,
      'productSold': productSold,
      'timePosted': timePosted.toIso8601String(),
      'restricted': restricted,
      'seller_info': seller.toJson(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }

  String get formattedPrice => '\$${productPrice.toStringAsFixed(2)}';

  String get stockStatus => productStock > 0 ? 'In Stock' : 'Out of Stock';

  String get formattedTimePosted => '${timePosted.toLocal()}';
}
