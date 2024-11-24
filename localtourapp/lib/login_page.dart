// login_page.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/page/home_screen/home_screen.dart';
import 'package:localtourapp/page/account/view_profile/for_got_password.dart';
import 'package:localtourapp/services/auth_service.dart';

import 'base/base_page.dart';
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
  void _handleLogin() async {
    String phoneNumber = phoneController.text.trim();
    String password = passwordController.text.trim();
    bool isValid = true;

    setState(()  {
      // Validate phone number

      if (phoneNumber.isEmpty) {
        phoneError = true;
        phoneErrorText = 'Please enter your phone number.';
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


        }
    );
    if (isValid) {
      try {
        await _authService.signInWithPassword(phoneNumber, password);
        widget.onLogin();
        Navigator.pushNamed(context, '/');
      }catch(e){
        String error = e.toString();
        if(error.toLowerCase().contains('password')){
         setState(() {
           passwordError = true;
           passwordErrorText = error;
           isValid = false;
         });
        }else{
        setState(() {
          phoneError = true;
          phoneErrorText = error;
          isValid = false;
        });
        }
    }}

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
                  // Forgot Password button

                  const SizedBox(height: 10),
                  // Login and Register buttons
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue, // Button color
                          padding: EdgeInsets.symmetric(
                              horizontal: 165,vertical: 13), // Button padding
                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17), textAlign: TextAlign.center,),
                      ),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 3,
                        child:
                          TextButton(

                            onPressed: () {
                              ForgotPasswordDialog.show(
                                context,'',() {

                                },
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),

                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _authService.signInWithGoogle();
                      var result = await _authService.sendUserIdToBackend();
                      if(result.firstTime){
                        navigatorKey.currentState?.pushNamed('/register');
                      }
                     widget.onLogin();
                      Navigator.pushNamed(context, '/');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13,horizontal: 105), // Adjust spacing

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.redAccent.withOpacity(0.8),
                        // Background color
                      ),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon Google
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/google_logo.png'),
                                fit: BoxFit.contain,

                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Sign In with Google',
                            style: TextStyle(
                              color: Colors.white, // Màu chữ đỏ
                              fontWeight: FontWeight.w600, // Chữ đậm
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(fontSize: 17, color: Colors.blue.shade900,)),
                      TextButton(
                        onPressed: () {
                          // Use navigatorKey to navigate to '/register'
                          navigatorKey.currentState?.pushNamed('/register');
                        },
                        child: const Text("Create here", style: TextStyle(fontSize: 17, color: Colors.blueAccent,decoration: TextDecoration.underline,decorationColor: Colors.blueAccent)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // TextButton
                  TextButton(
                    onPressed: () {
                  widget.onLogin();
                  Navigator.pushNamed(context, '/');

                  },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      "Continue Without Sign In",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
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
