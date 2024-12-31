import 'package:flutter/material.dart';
import 'package:plant_feed/providers/user_model_provider.dart';
import 'package:plant_feed/routing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/services.dart';
import 'Services/consts.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Import the Stripe package


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up Stripe with your public key
  Stripe.publishableKey = stripePublicKey; // Your Stripe publishable key from consts.dart
  Stripe.instance.applySettings(); // Apply settings after setting the publishable key
  
  runApp(const MyApp());
}

class LogoAsset extends StatelessWidget {
  const LogoAsset({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = const AssetImage('assets/images/login.png');
    Image image = Image(image: assetImage);
    return Container(
      child: image,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  int? id;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      token = value.getString('token');
      id = value.getInt('ID');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Plant Feed',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Montserrat',
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}