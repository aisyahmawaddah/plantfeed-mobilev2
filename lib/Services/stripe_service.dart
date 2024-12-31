import 'dart:convert'; // Import for JSON encoding
import 'package:dio/dio.dart'; // Use Dio for HTTP requests
import 'package:flutter_stripe/flutter_stripe.dart'; // Stripe package
import 'package:plant_feed/Services/consts.dart'; // Your constants
import 'package:plant_feed/config.dart'; // Your API configuration
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:logger/logger.dart'; // For logging
import 'package:shared_preferences/shared_preferences.dart';

class StripeService {
  // Logger instance for logging messages
  static final Logger logger = Logger();

  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment(String sessionId) async {
    try {
      // You might need to fetch the client secret to confirm the payment
      String? paymentIntentClientSecret = await _retrievePaymentIntentClientSecret(sessionId);
      if (paymentIntentClientSecret != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentClientSecret,
            merchantDisplayName: "Your Merchant Name",
          ),
        );

        await Stripe.instance.presentPaymentSheet();
      } else {
        logger.e("Failed to retrieve payment intent client secret");
      }
    } catch (e) {
      logger.e("Error during payment: $e");
      throw 'Payment processing failed';
    }
  }

  Future<String?> _retrievePaymentIntentClientSecret(String sessionId) async {
    // Implement the logic to retrieve the payment intent client secret
    return "your_payment_intent_client_secret"; // Placeholder
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded'
          },
        ),
      );
      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      logger.e("Error creating payment intent: $e");
    }
    return null;
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      logger.e("Error processing payment: $e");
    }
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100; // Convert to cents
    return calculatedAmount.toString();
  }

  Future<String?> createCheckoutSession(List<int> selectedProductIds, Map<String, String> shippingDetails) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('ID');
    if (userId == null) {
      throw Exception('User not logged in.');
    }

    final requestBody = {
      'selected_products': selectedProductIds,
      'shipping_details': shippingDetails, // Add the shipping details
    };

    final response = await http.post(
      Uri.parse('${Config.apiUrl}/payment/api/create-checkout-session/?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id']; // Return the Stripe session ID
    } else {
      logger.e('Error response: ${response.body}');
      throw Exception('Failed to create checkout session.');
    }
  } catch (e) {
    logger.e("Error creating checkout session: $e");
    return null;
  }
}

  Future<void> openCheckout(String sessionId, List<int> selectedProductIds) async {
  final prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('ID'); // Retrieve user ID from SharedPreferences

  if (userId == null) {
    throw Exception('User not logged in.');
  }

  try {
    // Create a Payment Intent and retrieve the client secret from backend
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/payment/api/create-payment-intent/?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'selected_products': selectedProductIds}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String paymentIntentClientSecret = data['client_secret'];

      // Initialize Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Aisyah M",
        ),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If payment succeeds, call backend to process the payment
      await _notifyBackendPaymentSuccess(sessionId);

      // Provide success feedback to user
      logger.i('Payment successful');
    } else {
      logger.e('Error creating payment intent: ${response.body}');
      throw 'Failed to create payment intent';
    }
  } catch (e) {
    logger.e("Payment failed: $e");
    rethrow; // Let the error bubble up for user feedback
  }
}

Future<void> _notifyBackendPaymentSuccess(String sessionId) async {
  try {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/payment/api/process-payment/?session_id=$sessionId'),
    );

    if (response.statusCode == 200) {
      logger.i("Backend updated successfully after payment.");
    } else {
      logger.e("Backend update failed: ${response.body}");
      throw 'Failed to update backend after payment.';
    }
  } catch (e) {
    logger.e("Error notifying backend: $e");
  }
}
}