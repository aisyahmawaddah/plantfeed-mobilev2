// lib/models/order_model.dart

import 'package:plant_feed/model/product_model.dart';
import 'package:plant_feed/model/person_model.dart'; // Import the shared Person class

class OrderInfo {
  final int id;
  final String name;
  final String email;
  final String address;
  final String shipping;
  final double total;
  final String status;

  OrderInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.shipping,
    required this.total,
    required this.status,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      name: json['name'] ?? 'Unknown Name',
      email: json['email'] ?? 'No Email',
      address: json['address'] ?? 'No Address',
      shipping: json['shipping']?.toString() ?? '0.00',
      total: json['total'] != null
          ? double.tryParse(json['total'].toString()) ?? 0.0
          : 0.0,
      status: json['status'] ?? 'Unknown Status',
    );
  }

  // Convert OrderInfo instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'shipping': shipping,
      'total': total,
      'status': status,
    };
  }
}

class Order {
  final int basketId;
  final int productQty;
  final Product product;
  final Person buyer;
  final bool isCheckout;
  final String transactionCode;
  final String status;
  final OrderInfo orderInfo;

  Order({
    required this.basketId,
    required this.productQty,
    required this.product,
    required this.buyer,
    required this.isCheckout,
    required this.transactionCode,
    required this.status,
    required this.orderInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      basketId: json['basket_id'] != null
          ? int.tryParse(json['basket_id'].toString()) ?? 0
          : 0,
      productQty: json['productqty'] != null
          ? int.tryParse(json['productqty'].toString()) ?? 0
          : 0,
      product: json['productid'] != null
          ? Product.fromJson(json['productid'])
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
      buyer: json['buyer_info'] != null
          ? Person.fromJson(json['buyer_info'])
          : Person(
              id: 0,
              username: 'Unknown User',
              email: 'No Email Provided',
              photo: null,
              name: 'Unknown Name',
            ),
      isCheckout: json['is_checkout'] ?? false,
      transactionCode: json['transaction_code']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'Unknown Status',
      orderInfo: json['order_info'] != null
          ? OrderInfo.fromJson(json['order_info'])
          : OrderInfo(
              id: 0,
              name: 'Unknown',
              email: 'No Email',
              address: 'No Address',
              shipping: '0.00',
              total: 0.0,
              status: 'Unknown Status',
            ),
    );
  }

  // Convert Order instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'basket_id': basketId,
      'productqty': productQty,
      'productid': product.toJson(),
      'buyer_info': buyer.toJson(),
      'is_checkout': isCheckout,
      'transaction_code': transactionCode,
      'status': status,
      'order_info': orderInfo.toJson(),
    };
  }

  // Add a getter for id
  int get id => orderInfo.id;
}
