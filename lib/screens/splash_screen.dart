import 'package:flutter/material.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/services.dart';
import '../model/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? token;
  int? id;
  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      String? token = value.getString('token');
      value.getInt('ID');

      if (token != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          final api = Provider.of<ApiService>(context, listen: false);
          final userProvider = Provider.of<UserProvider>(context, listen: false);

          api.userToken(token).then((value) {
            userProvider.setUser = User.fromJson(value);
            if (!mounted) return;

            Navigator.pushReplacementNamed(context, '/AppLayout');
          });
        });
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/loginScreen');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = const AssetImage('assets/images/login.png');
    Image image = Image(image: assetImage);
    return Scaffold(
      body: Center(
        child: Container(
          child: image,
        ),
      ),
    );
  }
}
