import 'package:flutter/foundation.dart';
import 'package:plant_feed/model/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user; // The user object

  // Getter for the user object
  User? get getUser => _user;

  // Method to set the user
  set setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Function to update the user
  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners(); // Notify listeners that the user has been updated
  }
}
