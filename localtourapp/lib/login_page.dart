// login_page.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/page/account/view_profile/for_got_password.dart';
import 'package:localtourapp/services/auth_service.dart';

import 'main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LoginPage({Key? key, required this.onLogin, required this.onRegister})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  // Controllers for input fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Validation flags and messages
  bool phoneError = false;
  String phoneErrorText = '';
  bool passwordError = false;
  String passwordErrorText = '';

  // Helper function to validate the phone number
  bool validatePhoneNumber(String phone) {
    final phoneRegExp = RegExp(r'^\+?\d{10}$'); // Adjust regex as needed
    return phoneRegExp.hasMatch(phone);
  }

  // Helper function to validate the password
  bool validatePassword(String password) {
    final passwordRegExp =
    RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,16}$');
    return passwordRegExp.hasMatch(password);
  }

  // Function to handle login
  void _handleLogin() {
    String phoneNumber = phoneController.text.trim();
    String password = passwordController.text.trim();
    bool isValid = true;

    setState(() {
      // Validate phone number
      if (phoneNumber.isEmpty) {
        phoneError = true;
        phoneErrorText = 'Please enter your phone number.';
        isValid = false;
      } else if (!validatePhoneNumber(phoneNumber)) {
        phoneError = true;
        phoneErrorText = 'Please enter a valid phone number.';
        isValid = false;
      } else {
        phoneError = false;
        phoneErrorText = '';
      }

      // Validate password
      if (password.isEmpty) {
        passwordError = true;
        passwordErrorText = 'Please enter your password.';
        isValid = false;
      } else if (!validatePassword(password)) {
        passwordError = true;
        passwordErrorText =
        'Password must have:\n• 1 uppercase letter • 1 special character\n• 1 number • 8-16 characters long.';
        isValid = false;
      } else {
        passwordError = false;
        passwordErrorText = '';
      }
    });

    if (isValid) {
      // Proceed with login logic
      // For example, authenticate with Firebase or your backend
      // On successful login:
      widget.onLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome logo
                  Image.asset(
                    'assets/images/Welcome.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number TextField
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number or Email',
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                      errorText: phoneError ? phoneErrorText : null,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      errorText: passwordError ? passwordErrorText : null,
                    ),
                    obscureText: true,
                    maxLength: 16, // Restrict password to 16 characters
                  ),
                  const SizedBox(height: 20),

                  // Login and Register buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue, // Button color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 12), // Button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32), // Rounded corners
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Use navigatorKey to navigate to '/register'
                          navigatorKey.currentState?.pushNamed('/register');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green, // Button color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 12), // Button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32), // Rounded corners
                          ),
                        ),
                        child: const Text('Register'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      var credential = await _authService.signInWithGoogle();

                    },
                    child: Container(
                      padding: const EdgeInsets.all(5), // Adjust spacing
                      width: 40, // Diameter of the circle
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Background color
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/google_logo.png', // Google logo image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Forgot Password button
                  TextButton(
                    onPressed: () {
                      ForgotPasswordDialog.show(
                        context,
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
