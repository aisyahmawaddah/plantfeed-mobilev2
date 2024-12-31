import 'package:flutter/material.dart';

import '../Screens/edit_profile_form_popup.dart';

Widget? buildFloatingActionButton(int selectedIndex, BuildContext context, VoidCallback onPressed) {
  switch (selectedIndex) {
    case 0: // Home screen
      return FloatingActionButton.extended(
        label: const Text(
          'Create new post',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, '/createNewPostScreen');
          onPressed();
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      );
    case 1: // Group screen
      return FloatingActionButton.extended(
        label: const Text(
          'Create new group',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, '/createNewGroupScreen');
        },
        icon: const Icon(
          Icons.group_add,
          color: Colors.white,
        ),
      );
    case 2: // Workshop screen
      return null;
    case 3: // Marketplace screen
      return null; // No floating action button for Marketplace screen
    case 4: // Profile screen
      return FloatingActionButton.extended(
        label: const Text(
          'Edit profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(
            builder: (context) {
              return const EditProfileFormScreen();
            },
            context: context,
            barrierDismissible: false,
          );
        },
        icon: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      );
    default:
      return null;
  }
}
