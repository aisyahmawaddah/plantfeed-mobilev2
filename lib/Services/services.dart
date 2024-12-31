import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:http/http.dart' as http;
import 'package:plant_feed/model/all_group_model.dart';
import 'package:plant_feed/model/all_post_model.dart';
import 'package:plant_feed/model/all_workshop_list_model.dart';
import 'package:plant_feed/model/booked_workshop_model.dart';
import 'package:plant_feed/model/comment_model.dart';
import 'package:plant_feed/model/group_comment_model.dart';
import 'package:plant_feed/model/group_sharing_model.dart';
import 'package:plant_feed/model/joined_group_model.dart';
import 'package:plant_feed/model/membership_model.dart';
import 'package:plant_feed/model/my_post_model.dart';
import 'package:plant_feed/model/post_details_model.dart';
import 'package:plant_feed/model/reply_comments_model.dart';
import 'package:plant_feed/model/user.dart';
import 'package:plant_feed/model/workshop_sharing_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_feed/model/product_model.dart';
import 'package:plant_feed/model/basket_item_model.dart';
import 'package:plant_feed/model/review_model.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:plant_feed/config.dart'; // Import the configuration file

class ApiService {
  final String url = Config.apiUrl;
  //var url = 'https://9552-2405-3800-8a4-b828-d027-1f73-d881-ed1b.ngrok-free.app';
  //var url = 'https://10.0.2.2:8000';
  User? _user;
  String? token;
  int? id;

  User? get getUser => _user;
  set setUser(User user) => _user = user;

//marketplace screen
  // Fetch products from marketplace
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$url/marketplace/api/products/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Add a product to the basket
  Future<void> addToBasket(String email, int productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$url/marketplace/api/add-to-basket/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await _getToken()}',
      },
      body: json.encode({
        'productid': productId, // Match the parameter name to backend expectation
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add product to basket');
    }
  }

  // Buy now functionality
  Future<void> buyNow(String email, int productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$url/marketplace/api/buy-now/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await _getToken()}',
      },
      body: json.encode({
        'email': email,
        'productid': productId, // Ensure consistency with backend parameters
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to process purchase');
    }
  }

  // Fetch the token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

//farah's
// Fetch reviews for a product
  Future<List<Review>> fetchReviews(int productId) async {
    final response =
        await http.get(Uri.parse('$url/marketplace/api/reviews/$productId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  // Fetch reviewer details by Person_fk_id
  Future<Map<String, String>> fetchReviewerDetails(int personId) async {
    final response =
        await http.get(Uri.parse('$url/marketplace/api/person/$personId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'name': data['name'],
        'photo': data['photo'],
      };
    } else {
      throw Exception('Failed to load reviewer details');
    }
  }
Future<Product> fetchProductDetails(int productId) async {
  final response =
      await http.get(Uri.parse('$url/marketplace/api/products/view/$productId/'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Product data: $data');
    return Product.fromJson(data); // Ensure your Product model handles nested data
  } else {
    throw Exception('Failed to load product details');
  }
}

  Future<List<Product>> fetchMyProducts(int sellerId) async {
    try {
      // Add sellerId as a query parameter to filter products
      final response = await http
          .get(Uri.parse('$url/marketplace/api/products?seller=$sellerId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        // Log the error response
        log('Failed to load products: ${response.body}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      log('Exception occurred while fetching products: $e');
      throw Exception('Failed to load products');
    }
  }

// Delete product
  Future<bool> deleteProduct(int productId) async {
    // Construct the endpoint URL using the `url` variable
    final endpoint =
        Uri.parse('$url/marketplace/api/products/$productId/delete/');

    try {
      log("Requesting URL: $endpoint"); // Debugging: Print the URL being requested

      // Send the DELETE request
      final response = await http.delete(endpoint);

      // Handle the response
      if (response.statusCode == 200) {
        log("Product deleted successfully.");
        return true;
      } else {
        log("Failed to delete product: ${response.body}");
        return false;
      }
    } catch (e) {
      log("Error deleting product: $e");
      return false;
    }
  }

// Update product
  Future<bool> updateProduct(
      int productId, Map<String, String> data, File? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            '$url/marketplace/api/products/$productId/update/'), // Adjust endpoint to your API
      );

      // Add form fields
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      // Attach the image file if it exists
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('product_photo', imageFile.path),
        );
      }

      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        return true; // Success
      } else {
        log("Failed to update product: ${response.statusCode}");
        return false; // Failure
      }
    } catch (e) {
      log("Error updating product: $e");
      return false; // Error occurred
    }
  }

  // Fetch Shop Analytics
  Future<Map<String, dynamic>> fetchShopAnalytics(int sellerId) async {
    try {
      final response = await http.get(
        Uri.parse('$url/marketplace/api/shop-analytics/$sellerId/'),
      );

      if (response.statusCode == 200) {
        log("Shop analytics fetched successfully");
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        log("Failed to fetch shop analytics: ${response.body}");
        return {};
      }
    } catch (e) {
      log("Error fetching shop analytics: $e");
      return {};
    }
  }

  //fetch orders for orders list
  Future<List<dynamic>> fetchOrders() async {
    final response = await http.get(Uri.parse('$url/list'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load orders");
    }
  }

  //update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    final response = await http.post(
      Uri.parse('$url/update_order_status/'),
      body: json.encode({'order_id': orderId, 'order_status': status}),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update order status");
    }
  }

  //check for product duplication
  Future<bool> isProductNameDuplicate(String productName, int productId) async {
  try {
    final response = await http.get(
      Uri.parse('$url/marketplace/check-duplicate-product-name?name=$productName&id=$productId'),
    );

    log('API URL: $url/marketplace/check-duplicate-product-name?name=$productName&id=$productId');
    log('Response Code: ${response.statusCode}');
    log('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['isDuplicate'];
    } else {
      log('Failed to check duplication: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    log("Exception during duplicate check: $e");
    return false;
  }
}

 // Function to sell a product
  Future<void> sellProduct(
      int personId, String productName, String productDesc, String productCategory,
      String customCategory, String productPrice, String productStock, var productPhoto) async {
    try {
      // Get user ID from shared preferences (if needed)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('ID'); // Assume 'ID' is the key where user ID is stored

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Construct the URL using the provided personId
      final Uri uri = Uri.parse('$url/marketplace/api/sell_product/$personId/');

      // Prepare the request
      var request = http.MultipartRequest('POST', uri)
        ..fields['productName'] = productName
        ..fields['productDesc'] = productDesc
        ..fields['productCategory'] = productCategory
        ..fields['customCategory'] = customCategory
        ..fields['productPrice'] = productPrice
        ..fields['productStock'] = productStock;

      // Attach photo if provided
      if (productPhoto != null) {
        request.files.add(await http.MultipartFile.fromPath('productPhoto', productPhoto.path));
      }

      // Send the request
      final http.Response response = await http.Response.fromStream(await request.send());

      // Check for success response
      if (response.statusCode == 201) {
        // Product created successfully
        print('Product created successfully.');
      } else {
        // Handle error response
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception('Failed to create product: ${responseData['error']}');
      }
    } catch (e) {
      throw Exception('Error selling product: $e');
    }
  }



// Fetch basket summary
  Future<List<BasketItem>> fetchBasketSummary() async {
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('ID');

  if (userId == null) {
    throw Exception('User not logged in.');
  }

  final response = await http.get(Uri.parse('$url/basket/api/basket-summary/?user_id=$userId'));

  if (response.statusCode == 200) {
    debugPrint('Response: ${response.body}'); // Add this line to log the response.

    Map<String, dynamic> decodedResponse = json.decode(response.body);
    if (decodedResponse['all_basket'] != null) {
      List<dynamic> basketItems = decodedResponse['all_basket'];
      return basketItems.map((item) {
        debugPrint('Item Parsed: $item'); // Log each item for debugging.
        return BasketItem.fromJson(item);
      }).toList();
    } else {
      return []; // If all_basket is null, return an empty list.
    }
  } else {
    throw Exception('Failed to load basket summary');
  }
}
  
// Remove item from basket
Future<void> removeFromBasket(int id) async {
  final response = await http.delete(Uri.parse('$url/basket/api/basket-delete/?item_id=$id'));

  if (response.statusCode == 204) { 
    debugPrint('Item removed from basket successfully.');
  } else {
    log('Failed to remove item from basket with status code: ${response.statusCode}');
    throw Exception('Failed to remove item from basket');
  }
}

 // Add quantity to an item in the basket (increment by 1)
  Future<void> addBasketQuantity(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('ID');  // Assume user ID is stored with key 'ID'

    if (userId == null) {
      throw Exception('User not logged in.');
    }

    final response = await http.post(
      Uri.parse('$url/basket/api/add-basket-qty/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'item_id': itemId,  // Send the item ID to increment the quantity
      }),
    );

    if (response.statusCode == 200) {
      // Successfully increased the quantity
      debugPrint('Quantity increased successfully.');
    } else {
      // Handle the error response
      debugPrint('Failed to update item quantity. Status code: ${response.statusCode}');
      throw Exception('Failed to update item quantity.');
    }
  }

  // Remove quantity from an item in the basket (decrement by 1)
Future<void> removeBasketQuantity(int itemId) async {
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('ID');

  if (userId == null) {
    throw Exception('User not logged in.');
  }

  final response = await http.post(
    Uri.parse('$url/basket/api/remove-basket-qty/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'item_id': itemId,  // Send the item ID to decrement the quantity
    }),
  );

  if (response.statusCode == 200) {
    // Successfully decreased the quantity
    debugPrint('Quantity decreased successfully.');
  } else {
    // Handle the error response
    debugPrint('Failed to update item quantity. Status code: ${response.statusCode}');
    throw Exception('Failed to update item quantity.');
  }
}

  // Update basket item quantity
  Future<void> updateBasketQuantity(int id, int quantity) async {
    final response = await http.patch(
      Uri.parse('$url/basket/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'productqty': quantity,
      }),
    );

    if (response.statusCode != 200) {
      log('Failed to update item quantity with status code: ${response.statusCode}');
      throw Exception('Failed to update item quantity');
    }
  }

  // Checkout selected items
Future<Map<String, dynamic>> checkout(int userId, List<int> selectedProducts) async {
  final String apiUrl = '$url/basket/api/checkout/?user_id=$userId';

  try {
    // Prepare selected products data
    Map<String, dynamic> requestData = {
      'selected_products': selectedProducts,
    };

    // Make POST request to checkout API
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      // Handle successful response
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      // Handle other status codes
      print('Error: ${response.statusCode}');
      print('Message: ${response.body}');
      throw Exception('Failed to checkout');
    }
  } catch (e) {
    print('Exception during checkout: $e');
    throw Exception('Failed to checkout');
  }
}

  // Checkout all items
Future<Map<String, dynamic>> checkoutAll() async {
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('ID'); // Assuming user ID is stored with key 'ID'

  if (userId == null) {
    throw Exception('User not logged in.');
  }

  final response = await http.get(
    Uri.parse('$url/basket/api/checkout-all/?user_id=$userId'),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // Parse and return the response body
    debugPrint('Checkout All response: ${response.body}');
    return jsonDecode(response.body);
  } else {
    debugPrint('Checkout All failed: ${response.body}');
    throw Exception('Failed to fetch all checkout data: ${response.body}');
  }
}

Future<Map<String, dynamic>> fetchOrderHistory(int userId) async {
  final response = await http.get(
    Uri.parse('$url/orders/api/history/?user_id=$userId'),
    headers: {'Content-Type': 'application/json'},
  );

  // Log the raw response for debugging
  debugPrint("Response status: ${response.statusCode}");
  debugPrint("Response body: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body); // Deserialize JSON response
  } else {
    throw Exception('Failed to load order history');
  }
}

// Cancel Order
  Future<void> cancelOrder(int orderId, int sellerId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('ID'); // Ensure 'ID' is correctly stored during login

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final Uri uri = Uri.parse('$url/orders/api/cancel_order/$orderId/$sellerId/');
      final Map<String, dynamic> body = {'user_id': userId};

      final http.Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Successfully canceled
        return;
      } else {
        // Attempt to parse error message from response
        String errorMessage = 'Failed to cancel order';
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error canceling order: $e');
    }
  }

  // Complete Order
Future<void> completeOrder(int orderId, int sellerId) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('ID'); // Ensure 'ID' is correctly stored during login

    if (userId == null) {
      throw Exception('User not logged in');
    }

    final Uri uri = Uri.parse('$url/orders/api/complete_order/$orderId/$sellerId/'); // Use orderId
    final Map<String, dynamic> body = {
      'user_id': userId,
    };

    final http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // Successfully completed order
      return;
    } else {
      // Attempt to parse error message from response
      String errorMessage = 'Failed to complete order';
      try {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  } catch (e) {
    throw Exception('Error completing order: $e');
  }
}

  
  // Review product
  Future<void> reviewProduct(int fk1, int sellerId, String reviewContent) async {
    final response = await http.post(
      Uri.parse('$url/orders/api/review_product/$fk1/$sellerId/'),
      body: jsonEncode({'content': reviewContent}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit review');
    }
  }

  // Get invoice details
  Future<Map<String, dynamic>> fetchInvoice(int fk1, int sellerId) async {
    final response = await http.get(
      Uri.parse('$url/orders/api/invoice/$fk1/$sellerId/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Deserialize JSON response
    } else {
      throw Exception('Failed to load invoice');
    }
  }

// Order again
Future<void> orderAgain(int orderId, int sellerId, int userId) async {
  final response = await http.post(
    Uri.parse('$url/orders/api/order_again/$orderId/$sellerId/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'user_id': userId}),  // Include user_id in the body
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to reorder items: ${response.body}');
  }
}

  // Fetch sell history
  Future<Map<String, dynamic>> fetchSellHistory(int sellerId) async {
    final response = await http.get(
      Uri.parse('$url/orders/api/sell_history/$sellerId/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Deserialize JSON response
    } else {
      throw Exception('Failed to load sell history');
    }
  }

// Update order history status
Future<void> updateOrderHistoryStatus(int orderId, String orderStatus, int sellerId) async {
  final response = await http.post(
    Uri.parse('$url/orders/api/update_order_history_status/'),
    body: jsonEncode({
      'order_id': orderId.toString(),
      'order_status': orderStatus,
      'seller_id': sellerId.toString(),
    }),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update order history status');
  }
}
  
  
  
  //adli's
 Future<dynamic> login(String email, String password) async {
  final res = await http.post(Uri.parse('$url/users/login/'),
      headers: {"Accept": "application/json", "content-type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
      }));

  dev.log(res.body);
  var json = jsonDecode(res.body);
  dev.log(json.toString());

  if (res.statusCode == 200) {
    String token = json['token']; // Assuming this is a non-nullable string
    int userId = json['ID']; // Changed variable name to avoid confusion with local variable
    String userName = json['name']; // Retrieve the user's name from the response

    // Store the token and email in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); // Store token
    await prefs.setString('email', email.toLowerCase()); // Store email
    await prefs.setInt('ID', userId); // Store user ID
    await prefs.setString('name', userName); // Store user's name

    dev.log(token);
    return json; // Return if needed
  } else {
    throw Exception('Something went wrong');
  }
}

  //Get user data from the valid token (get)
  Future<dynamic> userToken(String token) async {
    final res = await http.get(Uri.parse('$url/users/token/$token'));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return jsonDecode(res.body);
    }
  }

  Future<List<MyPostModel>> getMyPost() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('ID');
    final res = await http.get(Uri.parse('$url/users/feed/$id'));

    log(url);

    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => MyPostModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future<List<AllPostModel>> getAllPost() async {
    final res = await http.get(Uri.parse('$url/users/feed/'));

    log(url);

    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => AllPostModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future<dynamic> addNewPost(String title, String message, int creatorId, File? image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/users/post-feed/'),
    );

    request.headers["Accept"] = "application/json";

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('Photo', image.path));
    }

    request.fields['Title'] = title;
    request.fields['Message'] = message;
    request.fields['Creator_id'] = creatorId.toString();

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return jsonDecode(res.body)['message'];
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<dynamic> deletePost(int postId) async {
    final res = await http.post(
      Uri.parse('$url/users/feed/delete/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'id': postId,
      }),
    );

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 200) {
      log(res.body);
      final responseData = jsonDecode(res.body);
      return responseData['message'];
    } else {
      throw Exception('Failed to delete post');
    }
  }

  Future<dynamic> updateUser({
    required String name,
    required String age,
    required String state,
    required String district,
    required String username,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('ID');
    log(id.toString());
    final updateURL = Uri.parse('$url/users/update-profile/$id/');

    final request = http.MultipartRequest('PUT', updateURL);
    request.headers['Content-Type'] = 'multipart/form-data';

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile(
          'Photo',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: imageFile.path.split('/').last,
        ),
      );
    }

    request.fields['Name'] = name;
    request.fields['Age'] = age;
    request.fields['State'] = state;
    request.fields['District'] = district;
    request.fields['Username'] = username;

    final response = await request.send();

    if (response.statusCode == 200) {
      log('User updated successfully');
    } else {
      log('Error updating user. Status code: ${response.statusCode}');
    }
  }

  Future<List<AllGroupModel>> getAllGroupList() async {
    final res = await http.get(Uri.parse('$url/group/group-list/'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => AllGroupModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future<dynamic> createNewGroup(
    String groupName,
    String about,
    int creatorId,
    File? groupImage,
    String age,
    String state,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/group/create-group/'),
    );

    request.headers["Accept"] = "application/json";
    request.headers['Content-Type'] = 'multipart/form-data';

    if (groupImage != null) {
      request.files.add(await http.MultipartFile.fromPath('Media', groupImage.path));
    }

    request.fields['Name'] = groupName;
    request.fields['About'] = about;
    request.fields['Username_id'] = creatorId.toString();
    request.fields['State'] = state;
    request.fields['Age'] = age;

    final response = await request.send();

    final res = await http.Response.fromStream(response);
    log(request.fields.toString());

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<PostDetailsModels> getFeedDetails(int id) async {
    final res = await http.get(Uri.parse('$url/sharing/users/feed-details/$id'));

    if (res.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(res.body);
      return PostDetailsModels.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  Future<List<CommentModel>> getComments(int id) async {
    final res = await http.get(Uri.parse('$url/sharing/users/feeds/$id/comments'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  Future<dynamic> addNewComment(String message, int commenterId, int feedId, File? image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/sharing/users/add-comments/'),
    );

    request.headers["Accept"] = "application/json";

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('pictures', image.path));
    }
    request.fields['message'] = message;
    request.fields['feed_id'] = feedId.toString();
    request.fields['commenter_id'] = commenterId.toString();

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return jsonDecode(res.body)['message'];
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<AllGroupModel> getGroupDetails(int id) async {
    final res = await http.get(Uri.parse('$url/group/group-details/$id'));

    if (res.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(res.body);
      return AllGroupModel.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  Future<List<JoineGroupModel>> getJoinedGroupList() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('ID');
    final res = await http.get(Uri.parse('$url/group/joined-group/$id'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => JoineGroupModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future<bool?> joinNewGroup(
    int userId,
    int groupId,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/group/create-group-membership/'),
    );

    request.headers["Accept"] = "application/json";

    request.fields['GroupMember_id'] = userId.toString();
    request.fields['GroupName_id'] = groupId.toString();

    final response = await request.send();

    final res = await http.Response.fromStream(response);
    log(request.fields.toString());

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<GroupSharingModel>> getGroupTimelines(int groupId) async {
    final res = await http.get(Uri.parse('$url/group/group-timelines/$groupId'));

    log(url);

    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => GroupSharingModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future<dynamic> addNewGroupSharing(String title, String message, int creatorId, int groupId, File? image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/group/group-timelines/'),
    );

    request.headers["Accept"] = "application/json";

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('GroupPhoto', image.path));
    }

    request.fields['GroupTitle'] = title;
    request.fields['GroupMessage'] = message;
    request.fields['GroupState'] = 'State';
    request.fields['CreatorFK_id'] = creatorId.toString();
    request.fields['GroupFK_id'] = groupId.toString();
    request.fields['GroupSkill'] = 'Skill';

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return jsonDecode(res.body)['message'];
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<List<GroupCommentModel>> getGroupComments(int id) async {
    final res = await http.get(Uri.parse('$url/group/group-timelines-comments/$id/'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => GroupCommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  Future<dynamic> addNewCommentGroup(String message, int commenterId, int groupFeedId, File? image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/group/group-timelines-comments/create/'),
    );

    request.headers["Accept"] = "application/json";

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('GrpPictures', image.path));
    }
    request.fields['GrpMessage'] = message;
    request.fields['GrpCommenterFK_id'] = commenterId.toString();
    request.fields['GrpFeedFK_id'] = groupFeedId.toString();

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return jsonDecode(res.body)['message'];
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<List<AllWorkshopModel>> getAllWorkshopList() async {
    final res = await http.get(Uri.parse('$url/workshop/workshop-list'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => AllWorkshopModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future<List<BookedWorkshopModel>> getBookedWorkshop() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('ID');
    final res = await http.get(Uri.parse('$url/workshop/bookings/$id/'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => BookedWorkshopModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  Future<bool?> bookWorkshop(
    int userId,
    int workshopId,
    String programmeName,
    String date,
    String messages,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/workshop/bookings/workshop/'),
    );

    request.headers["Accept"] = "application/json";

    request.fields['Participant_id'] = userId.toString();
    request.fields['BookWorkshop_id'] = workshopId.toString();
    request.fields['ProgrammeName'] = programmeName;
    request.fields['Date'] = date;
    request.fields['Messages'] = messages;

    final response = await request.send();

    final res = await http.Response.fromStream(response);
    log(request.fields.toString());

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> cancelBooking(int workshopId) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/workshop/bookings/cancel/'),
    );

    request.headers["Accept"] = "application/json";

    request.fields['id'] = workshopId.toString();

    final response = await request.send();

    final res = await http.Response.fromStream(response);
    log(request.fields.toString());

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateGroup({
    required String groupName,
    required String aboutGroup,
    required String state,
    required int groupId,
    File? imageFile,
  }) async {
    final updateURL = Uri.parse('$url/group/group-update/$groupId/update/');

    final request = http.MultipartRequest('PUT', updateURL);
    request.headers['Content-Type'] = 'multipart/form-data';

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile(
          'Media',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: imageFile.path.split('/').last,
        ),
      );
    }

    request.fields['Name'] = groupName;
    request.fields['About'] = aboutGroup;
    request.fields['State'] = state;

    final response = await request.send();

    if (response.statusCode == 200) {
      log('User updated successfully');
    } else {
      log('Error updating user. Status code: ${response.statusCode}');
    }
  }

  Future<dynamic> replyComments(String message, int commenterId, int feedId, File? image, int commentId) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/sharing/users/reply-comments/'),
    );

    request.headers["Accept"] = "application/json";

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('pictures', image.path));
    }
    request.fields['message'] = message;
    request.fields['feed_id'] = feedId.toString();
    request.fields['comment_id'] = commentId.toString();
    request.fields['commenter_id'] = commenterId.toString();

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return jsonDecode(res.body)['message'];
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<List<ReplyCommentsModel>> getReplyComments(int id) async {
    final res = await http.get(Uri.parse('$url/sharing/users/reply-comments/comment/$id/'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => ReplyCommentsModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  Future<List<ReplyCommentsModel>> getGroupReplyComments(int id) async {
    final res = await http.get(Uri.parse('$url/group/group/reply-comments/comment/$id/'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => ReplyCommentsModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  Future<dynamic> replyGroupComments(String message, int commenterId, int feedId, File? image, int commentId) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/group/group/reply-comments/'),
    );

    request.headers["Accept"] = "application/json";

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('pictures', image.path));
    }
    request.fields['message'] = message;
    request.fields['feed_id'] = feedId.toString();
    request.fields['comment_id'] = commentId.toString();
    request.fields['commenter_id'] = commenterId.toString();

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');
    log(res.body);
    if (res.statusCode == 201) {
      return jsonDecode(res.body)['message'];
    } else {
      throw Exception('Failed to add post');
    }
  }

  Future<List<MembershipModel>> getMembershipList(int id) async {
    final res = await http.get(Uri.parse('$url/group/group-memberships/$id/'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => MembershipModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future<bool?> removeGroupMembers(int id) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/group/membership/delete/'),
    );

    request.headers["Accept"] = "application/json";

    request.fields['membership_id'] = id.toString();

    final response = await request.send();

    final res = await http.Response.fromStream(response);
    log(request.fields.toString());

    log('HTTP status code: ${res.statusCode}');
    log('HTTP response body: ${res.body}');

    if (res.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<WorkshopSharingModel>> getWorkshopSharing(int id) async {
    final res = await http.get(Uri.parse('$url/workshop/workshop-timeline/$id/'));
    if (res.statusCode == 200) {
      List jsonResponse = json.decode(res.body);
      return jsonResponse.map((e) => WorkshopSharingModel.fromJson(e)).toList();
    } else {
      log('API call failed with status code ${res.statusCode}');
      throw Exception('Unexpected Error');
    }
  }

  Future sendEmailBooking(String name, String userEmail, String message, String subject) async {
    try {
      await emailjs.send(
        'service_1lww2d4',
        'template_33ul7ok',
        {
          'user_name': name,
          'user_subject': subject,
          'user_email': userEmail,
          'user_message': message,
        },
        const emailjs.Options(
          publicKey: 'JhM5lzRHsB1faep36',
          privateKey: 'A94PiI5S5EdyBlM48Sg_t',
        ),
      );
      log('SUCCESS!');
    } catch (error) {
      if (error is emailjs.EmailJSResponseStatus) {
        log('ERROR... ${error.status}: ${error.text}');
      }
      log(error.toString());
    }
  }
}
