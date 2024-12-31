import 'package:plant_feed/config.dart';

class Person {
  final int id;
  final String username;
  final String email;

  Person({
    required this.id,
    required this.username,
    required this.email,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      username: json['Username'] ?? 'Unknown',  // Check key case sensitivity
      email: json['Email'] ?? 'Unknown',
    );
  }
}

class ProdProduct {
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
  final Person seller; // Correctly represents the seller as a Person object

  ProdProduct({
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
  });

    factory ProdProduct.fromJson(Map<String, dynamic> json) {
    print("Product JSON: $json");  // Debugging output for product

    var sellerInfo = json['seller_info']; 
    print("Seller Info: $sellerInfo");  // Debugging output for seller information

    return ProdProduct(
      productId: json['productid'],
      productName: json['productName'] ?? '',
      productDesc: json['productDesc'] ?? '',
      productCategory: json['productCategory'] ?? '',
      productPrice: double.tryParse(json['productPrice'].toString()) ?? 0.0,
      productStock: json['productStock'] ?? 0,
      productPhoto: json['productPhoto'] != null 
          ? '${Config.apiUrl}${json['productPhoto']}' 
          : null,
      productRating: json['productRating'] ?? 0,
      productSold: json['productSold'] ?? 0,
      timePosted: DateTime.parse(json['timePosted']),
      restricted: json['restricted'] ?? false,
      seller: sellerInfo != null 
          ? Person.fromJson(sellerInfo)  // Properly parse the seller
          : Person(id: 0, username: 'Unknown', email: 'Unknown'),  // Safe fallback for null
    );
  }
}

class BasketItem {
  final int id;
  final int productQty;
  final ProdProduct productId;  // Reference to the product
  final Person buyerInfo;       // Buyer information
  final Person sellerInfo;      // Directly store seller information
  final bool isCheckout;
  final String transactionCode;
  final String status;

  BasketItem({
    required this.id,
    required this.productQty,
    required this.productId,
    required this.buyerInfo,
    required this.sellerInfo,      // Store seller info
    required this.isCheckout,
    required this.transactionCode,
    required this.status,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    print("Basket Item JSON: $json");  // Debugging output for basket item

    // Extract seller info directly from JSON
    var sellerInfo = json['seller_info'];  // Access seller_info accurately

    return BasketItem(
      id: json['id'],
      productQty: json['productqty'] ?? 0,
      productId: ProdProduct.fromJson(json['productid']),  // Parse the product
      buyerInfo: json['buyer_info'] != null 
          ? Person.fromJson(json['buyer_info'])  
          : Person(id: 0, username: 'Unknown', email: 'Unknown'),  // Fallback for buyer
      sellerInfo: sellerInfo != null 
          ? Person.fromJson(sellerInfo)  // Parse the seller info
          : Person(id: 0, username: 'Unknown', email: 'Unknown'),  // Fallback for seller
      isCheckout: json['is_checkout'] ?? false,
      transactionCode: json['transaction_code'] ?? '',
      status: json['status'] ?? 'Unknown',
    );
  }
}