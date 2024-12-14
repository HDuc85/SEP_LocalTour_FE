// login_page.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/page/account/view_profile/for_got_password.dart';
import 'package:localtourapp/services/auth_service.dart';
import '../../config/appConfig.dart';
import '../../config/secure_storage_helper.dart';
import '../../main.dart';
import '../../services/notification_service.dart';

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
  final NotificationService _notificationService = NotificationService();
  final SecureStorageHelper _storage = SecureStorageHelper();
  // Controllers for input fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _languageCode = 'vi';
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
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);

    setState(() {
      // Validate phone number
      _languageCode = languageCode!;
      if (phoneNumber.isEmpty) {
        phoneError = true;
        phoneErrorText =  _languageCode == 'vi' ? 'Vui lòng nhập số điện thoại':'Please enter your phone number.';
        isValid = false;
      } else {
        phoneError = false;
        phoneErrorText = '';
      }
      // Validate password
      if (password.isEmpty) {
        passwordError = true;
        passwordErrorText = _languageCode == 'vi' ? 'Vui lòng nhập mật khẩu':'Please enter your password.';
        isValid = false;
      } else if (!validatePassword(password)) {
        passwordError = true;
        passwordErrorText = _languageCode == 'vi' ? 'Mật khẩu phải có:\n• 1 chữ cái viết hoa • 1 ký tự đặc biệt\n• 1 chữ số • Độ dài 8-16 ký tự.':
            'Password must have:\n• 1 uppercase letter • 1 special character\n• 1 number • 8-16 characters long.';
        isValid = false;
      } else {
        passwordError = false;
        passwordErrorText = '';
      }
    });
    if (isValid) {
      try {
        await _authService.signInWithPassword(phoneNumber, password);
        bool tokenAdded = await _notificationService.addDeviceToken();
        if (!tokenAdded) {
          // Handle token addition failure, e.g., show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_languageCode == 'vi'
                  ? 'Không thể đăng ký thiết bị của bạn để nhận thông báo.'
                  : 'Failed to register your device for notifications.'),
            ),
          );
        }
        widget.onLogin();
        Navigator.pushNamed(context, '/');
      } catch (e) {
        String error = e.toString();
        if (error.toLowerCase().contains('password')) {
          setState(() {
            passwordError = true;
            passwordErrorText = error;
            isValid = false;
          });
        } else {
          setState(() {
            phoneError = true;
            phoneErrorText = error;
            isValid = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _notificationService.requestPermission();
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
                      labelText: _languageCode == 'vi' ? 'Số điện thoại hoặc email':'Phone Number or Email',
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                      errorText: phoneError ? phoneErrorText : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: _languageCode == 'vi' ? 'Mật khẩu':'Password',
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
                  SizedBox(
                    width: 380,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // Button color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 13), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      child: Text(_languageCode == 'vi' ? 'Đăng nhập':'Sign In',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          ForgotPasswordDialog.show(
                            context,
                            '',
                            () {},
                          );
                        },
                        child: Text(_languageCode == 'vi' ? 'Quên mật khẩu?':'Forgot Password?',
                          style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _authService.signInWithGoogle();
                      var result = await _authService.sendUserIdToBackend();
                      if (result.firstTime) {
                        navigatorKey.currentState?.pushNamed('/register');
                      }else{
                        widget.onLogin();
                        Navigator.pushNamed(context, '/');
                      }

                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 70), // Adjust spacing

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.redAccent.withOpacity(0.8),
                        // Background color
                      ),
                      child: Row(
                        children: [
                          // Icon Google
                          Container(
                            height: 24,
                            width: 24,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/google_logo.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(_languageCode == 'vi' ? 'Đăng nhập với Google':'Sign In with Google',
                            style: const TextStyle(
                              color: Colors.white, // Màu chữ đỏ
                              fontWeight: FontWeight.w600, // Chữ đậm
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_languageCode == 'vi' ? 'Bạn chưa có tài khoản?':"Don't have an account? ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          )),
                      TextButton(
                        onPressed: () {
                          // Use navigatorKey to navigate to '/register'
                          navigatorKey.currentState?.pushNamed('/register');
                        },
                        child: Text(_languageCode == 'vi' ? 'Tạo tài khoản tại đây':"Create here",
                            style: const TextStyle(
                                fontSize: 17,
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blueAccent)),
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
                        child: Text(_languageCode == 'vi' ? 'Hoặc':"OR",
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
                  const SizedBox(height: 20),
                  // TextButton
                  TextButton(
                    onPressed: () {
                      widget.onLogin();
                      Navigator.pushNamed(context, '/');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: Text(_languageCode == 'vi' ? 'Tiếp tục mà không cần đăng nhập':"Continue Without Sign In",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline),
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
