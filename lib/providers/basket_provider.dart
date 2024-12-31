import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart'; // Ensure you're pointing to the correct path
import 'package:plant_feed/model/basket_item_model.dart'; // Adjust the import to your model path

class BasketProvider with ChangeNotifier {
  List<BasketItem> _basketItems = [];
  double _totalPrice = 0.0; // Include total price here if needed
  bool _isLoading = false; // Loading state to manage state within UI

  List<BasketItem> get basketItems => _basketItems;
  double get totalPrice => _totalPrice;
  bool get isLoading => _isLoading;

  Future<void> refreshBasketSummary() async {
    _isLoading = true;
    notifyListeners(); // Notify listeners that loading has started

    final apiService = ApiService(); // Replace with your actual instantiation of the service
    try {
      // Fetch updated basket summary
      final items = await apiService.fetchBasketSummary(); 
      // Update the basket items and total price
      _basketItems = items;
      _totalPrice = _basketItems.fold(
          0, 
          (total, item) => total + (item.productId.productPrice * item.productQty));
      notifyListeners(); // Notify listeners that data has changed
    } catch (error) {
      debugPrint(error.toString());
      // Error handling if you need it; consider notifying listeners here too if desired
    } finally {
      _isLoading = false; // Set loading to false at the end
      notifyListeners(); // Notify listeners on completion
    }
  }
}