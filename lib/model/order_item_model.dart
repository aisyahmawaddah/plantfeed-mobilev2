// lib/models/order_item_model.dart

import 'package:plant_feed/model/product_model.dart';
import 'package:plant_feed/model/person_model.dart';

class OrderItem {
  final int productId;
  final Product product;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.product,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product']['productid'] != null
          ? int.tryParse(json['product']['productid'].toString()) ?? 0
          : 0,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : Product(
              productId: 0,
              productName: 'Unknown Product',
              productDesc: 'No Description Available',
              productCategory: 'Uncategorized',
              productPrice: 0.0,
              productStock: 0,
              productPhoto: null,
              productRating: 0,
              productSold: 0,
              timePosted: DateTime.now(),
              restricted: false,
              seller: Person(
                id: 0,
                username: 'Unknown User',
                email: 'No Email Provided',
                photo: null,
                name: 'Unknown Name',
              ),
              reviews: [],
            ),
      quantity: json['quantity'] != null
          ? int.tryParse(json['quantity'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
