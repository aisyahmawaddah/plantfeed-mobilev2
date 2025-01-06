import 'package:flutter/material.dart';
import 'package:plant_feed/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/services.dart';
import 'dart:developer' as dev;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    //FocusNode myFocusNode = FocusNode();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 100.0),
              child: Center(child: LogoAsset()),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Email is empty";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {},
                controller: emailController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Password is empty";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {},
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 30, right: 30),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    backgroundColor: const Color(0xff007730),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  child: const Text('Login'),
                  onPressed: () async {
  if (_formKey.currentState!.validate()) {
    try {
      // Attempt to log in
      var res = await apiService.login(emailController.text, passwordController.text);
      
      dev.log('response: ${res.toString()}'); // Log the full response

      // Ensure the response is a Map
      if (res is Map<String, dynamic>) {
        // Safely extracting values
        var token = res['token'] as String? ?? ''; // Default to empty string if null
        var id = res['ID'] as int? ?? 0; // Default to 0 if null

        // Validate extracted values
        if (token.isNotEmpty && id > 0) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token); // Store token
          await prefs.setInt('ID', id); // Store ID

          // Navigate to the home screen
          Navigator.pushReplacementNamed(context, '/');
        } else {
          // Handle case where token or ID is invalid
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed: Invalid token or ID')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed: Invalid response format')));
      }
    } catch (e) {
      // Catch any unexpected errors during login
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
