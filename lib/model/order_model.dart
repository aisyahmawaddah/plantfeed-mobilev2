// lib/models/order_model.dart

import 'package:plant_feed/model/order_item_model.dart';
import 'package:plant_feed/model/person_model.dart';

class OrderInfo {
  final int id;
  final String name;
  final String email;
  final String address;
  final double shipping;
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
      shipping: json['shipping'] != null
          ? double.tryParse(json['shipping'].toString()) ?? 0.0
          : 0.0,
      total: json['total'] != null
          ? double.tryParse(json['total'].toString()) ?? 0.0
          : 0.0,
      status: json['status'] ?? 'Unknown Status',
    );
  }

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
  final OrderItem item; // Single OrderItem per basket
  final Person buyer;
  final bool isCheckout;
  final String transactionCode;
  final String status;
  final OrderInfo orderInfo;

  Order({
    required this.basketId,
    required this.item,
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
      item: OrderItem.fromJson({
        'quantity': json['productqty'],
        'product': json['productid'],
      }),
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
              shipping: 0.0,
              total: 0.0,
              status: 'Unknown Status',
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basket_id': basketId,
      'item': item.toJson(),
      'buyer_info': buyer.toJson(),
      'is_checkout': isCheckout,
      'transaction_code': transactionCode,
      'status': status,
      'order_info': orderInfo.toJson(),
    };
  }

  // Getter for id
  int get id => orderInfo.id;
}
