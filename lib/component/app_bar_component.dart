import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';
import '../main.dart';

AppBar appBarComponent(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.lightGreen[900],
    title: const SizedBox(
      width: 50,
      child: LogoAsset(),
    ),
    centerTitle: true,
    leading: const Icon(Icons.account_circle_rounded),
    actions: <Widget>[
      TextButton(
          onPressed: () async {
            // _signOut();
            final pref = await SharedPreferences.getInstance();
            await pref.clear();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          },
          child: const Icon(Icons.logout, color: Colors.white)),
    ],
  );
}

AppBar appBarComponent2(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.lightGreen[900],
    title: const SizedBox(
      width: 50,
      child: LogoAsset(),
    ),
    centerTitle: true,
    actions: [
      PopupMenuButton(
          icon: const Icon(Icons.account_circle),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(value: 0, child: Text('Account')),
                PopupMenuItem(
                    value: 1,
                    child: const Text('Sign out'),
                    onTap: () async {
                      final pref = await SharedPreferences.getInstance();
                      await pref.clear();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      }
                    })
              ])
    ],
  );
}
