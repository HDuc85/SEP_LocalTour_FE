// register_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/users/update_user_request.dart';
import 'package:localtourapp/services/auth_service.dart';
import 'package:localtourapp/services/tag_service.dart';
import 'package:localtourapp/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/secure_storage_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Step control
  int currentStep = 1;
  String _languageCode = '';
  List<String> pageIndex = ['Phone', 'Password', 'NickName', 'Preferences'];
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final TagService _tagService = TagService();
  final storage = SecureStorageHelper();
  // Controllers for input fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController smsCodeController = TextEditingController(); // New Controller
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // FocusNodes for input fields
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode smsCodeFocusNode = FocusNode(); // New FocusNode
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode usernameFocusNode = FocusNode();

  // Validation flags and messages
  bool phoneError = false;
  String phoneErrorText = '';
  bool smsError = false; // New Error Flags
  String smsErrorText = '';
  bool passwordError = false;
  String passwordErrorText = '';
  bool confirmPasswordError = false;
  String confirmPasswordErrorText = '';
  bool usernameError = false;
  String usernameErrorText = '';

  // Authentication state
  bool isSmsSent = false; // Indicates if SMS code has been sent
  String verificationId = ''; // Stores the verification ID from FirebaseAuth
  bool isAuthenticating = false; // Indicates if authentication is in progress

  final FirebaseAuth auth = FirebaseAuth.instance;

  int resendCountdown = 60;
  Timer? countdownTimer;
  bool isCountdownActive = false;
  List<TagModel> listTag = [];
  List<int> listTagIdSelected = [];
  @override
  void initState() {
    super.initState();
    // Request focus on the first input field when the page loads
    checkLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(phoneFocusNode);
    });
  }

  Future<void> checkLogin() async{
    var isFirstLogin = await storage.readBoolValue(AppConfig.isFirstLogin);
    var isLogin = await storage.readBoolValue(AppConfig.isLogin);
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    if(isLogin){
      if(isFirstLogin){
        setState(() {
          _languageCode = languageCode ?? 'en'; // Default to 'en' if null
          // Update pageIndex dynamically based on _languageCode
          pageIndex = _languageCode == 'vi'
              ? ['Google', 'Mật khẩu', 'Biệt danh', 'Sở thích']
              : ['Google', 'Password', 'NickName', 'Preferences'];
          currentStep = 2; // Start from step 2
        });
      }else{
        Navigator.pushNamed(context, '/');
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to free resources
    phoneController.dispose();
    smsCodeController.dispose(); // Dispose new controller
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();

    phoneFocusNode.dispose();
    smsCodeFocusNode.dispose(); // Dispose new FocusNode
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    usernameFocusNode.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  // Helper functions for validation
  bool validatePhoneNumber(String phone) {
    final phoneRegExp = RegExp(r'^\+?\d{10}$'); // Adjust regex as needed
    return phoneRegExp.hasMatch(phone);
  }

  bool validateSMSCode(String code) {
    final smsRegExp = RegExp(r'^\d{6}$'); // Assuming 6-digit code
    return smsRegExp.hasMatch(code);
  }

  bool validatePassword(String password) {
    final passwordRegExp =
    RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,16}$');
    return passwordRegExp.hasMatch(password);
  }

  bool validateConfirmPassword(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  bool validateUsername(String username) {
    return username.isNotEmpty;
  }
  // Function to handle phone number authentication
  void _authenticatePhoneNumber() async {
    FocusScope.of(context).unfocus(); // Close keyboard
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      setState(() {
        phoneError = true;
        phoneErrorText = _languageCode == 'vi' ? 'Vui lòng nhập số điện thoại của bạn.':'Please enter your phone number.';
      });
      return;
    } else if (!validatePhoneNumber(phoneNumber)) {
      setState(() {
        phoneError = true;
        phoneErrorText = _languageCode == 'vi' ? 'Vui lòng nhập số điện thoại hợp lệ.': 'Please enter a valid phone number.';
      });
      return;
    } else {
      setState(() {
        phoneError = false;
        phoneErrorText = '';
        isAuthenticating = true; // Show loading indicator
      });
    }

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: formatPhoneNumber(phoneNumber),
        verificationCompleted: (PhoneAuthCredential credential) async {

        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isAuthenticating = false;
            phoneError = true;
            phoneErrorText = _languageCode == 'vi'
                ? (e.message ?? 'Xác minh số điện thoại không thành công.')
                : (e.message ?? 'Phone verification failed.');
          });
        },
        codeSent: (String verificationIdParam, int? resendToken) {
          setState(() {
            isSmsSent = true;
            verificationId = verificationIdParam;
            isAuthenticating = false;
          });
          FocusScope.of(context).requestFocus(smsCodeFocusNode);
        },
        codeAutoRetrievalTimeout: (String verificationIdParam) {
          setState(() {
            verificationId = verificationIdParam;
            isAuthenticating = false;
          });
        },
      );

     setState(() {
       isSmsSent = true;
       isCountdownActive = true;
       resendCountdown = 60;
     });

     countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
       if (resendCountdown == 0) {
         timer.cancel();
         setState(() {
           isCountdownActive = false;
         });
       } else {
         setState(() {
           resendCountdown--;
         });
       }
     });
    } catch (e) {
      setState(() {
        isAuthenticating = false;
        phoneError = true;
        phoneErrorText = _languageCode == 'vi' ? 'Có lỗi khi gửi mã SMS. Vui lòng thử lại.': 'Error sending SMS code. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageCode == 'vi' ? 'Lỗi':'Error: ${e.toString()}'),
        ),
      );
    }
  }
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return '+84${phoneNumber.substring(1)}';
    }
    return phoneNumber;
  }
  // Function to verify SMS code
  void _verifySmsCode() async {
    FocusScope.of(context).unfocus(); // Close keyboard
    String smsCode = smsCodeController.text.trim();
    if (smsCode.isEmpty) {
      setState(() {
        smsError = true;
        smsErrorText = _languageCode == 'vi' ? 'Vui lòng nhập mã SMS.':'Please enter the SMS code.';
      });
      return;
    } else if (!validateSMSCode(smsCode)) {
      setState(() {
        smsError = true;
        smsErrorText = _languageCode == 'vi' ? 'Vui lòng nhập mã SMS 6 chữ số hợp lệ.':'Please enter a valid 6-digit SMS code.';
      });
      return;
    } else {
      setState(() {
        smsError = false;
        smsErrorText = '';
        isAuthenticating = true; // Show loading indicator
      });
    }

    try {
       await _authService.verifyCode(verificationId, smsCode);

      setState(() {
        isSmsSent = false; // Reset SMS sent flag
        isAuthenticating = false;
        _nextStep(); // Proceed to the next step
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageCode == 'vi' ? 'Số điện thoại đã được xác minh thành công.': 'Phone number verified successfully.'),
        ),
      );

      await _authService.sendUserIdToBackend();


    } catch (e) {
      setState(() {
        isAuthenticating = false;
        smsError = true;
        smsErrorText = _languageCode == 'vi' ? 'Mã SMS không hợp lệ. Vui lòng thử lại.': 'Invalid SMS code. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageCode == 'vi' ? 'Lỗi: Mã xác minh không hợp lệ.':'Error: Invalid verification code.'),
        ),
      );
    }
  }
  // Function to resend SMS Code
  void _resendOtp() async {
    setState(() {
      isCountdownActive = true;
      resendCountdown = 60;
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown == 0) {
        timer.cancel();
        setState(() {
          isCountdownActive = false;
        });
      } else {
        setState(() {
          resendCountdown--;
        });
      }
    });
    String phoneNumber = phoneController.text;
    await auth.verifyPhoneNumber(
      phoneNumber: formatPhoneNumber(phoneNumber),
      verificationCompleted: (PhoneAuthCredential credential) async {

      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isAuthenticating = false;
          phoneError = true;
          phoneErrorText = e.message ??
              (_languageCode == 'vi'
                  ? 'Xác minh số điện thoại không thành công.'
                  : 'Phone verification failed.');
        });
      },
      codeSent: (String verificationIdParam, int? resendToken) {
        setState(() {
          isSmsSent = true;
          verificationId = verificationIdParam;
          isAuthenticating = false;
        });
        FocusScope.of(context).requestFocus(smsCodeFocusNode);
      },
      codeAutoRetrievalTimeout: (String verificationIdParam) {
        setState(() {
          verificationId = verificationIdParam;
          isAuthenticating = false;
        });
      },
    );

  }

  Future<bool> _setPassword(String password, String confirmPassword) async{
    var result = await _authService.setPassword(password, confirmPassword);
    return result;
  }
  // Function to proceed to the next step
  void _nextStep() {
    setState(() {
      if (currentStep < 4) {
        currentStep += 1;
      }
    });

    // After updating the step, set focus to the first input of the new step
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (currentStep) {
        case 2:
          FocusScope.of(context).requestFocus(passwordFocusNode);
          break;
        case 3:
          FocusScope.of(context).requestFocus(usernameFocusNode);
          break;
        case 4:
          FocusScope.of(context).unfocus();
          break;
        default:
          FocusScope.of(context).unfocus();
      }
    });
  }

  // Function to handle registration completion
  Future<void> _completeRegistration() async {
    // Implement your registration logic here (e.g., save user to database)
    // For demonstration, we'll simply show a success message
     await _tagService.addTagsPreferencs(listTagIdSelected);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_languageCode == 'vi' ? 'Đăng ký thành công!':'Registration Successful!'),
      ),
    );

    // Optionally, navigate to the login page or main application screen
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside input fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_languageCode == 'vi' ? 'Đăng ký':'Register'),
          leading: currentStep > 1
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){},
          )
              : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Step Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  int stepNumber = index + 1;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: currentStep >= stepNumber
                            ? Colors.blue
                            : Colors.grey[300],
                        child: Text(
                          stepNumber.toString(),
                          style: TextStyle(
                            color: currentStep >= stepNumber
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pageIndex[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: currentStep >= stepNumber
                              ? Colors.blue
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Step Content
              if (currentStep == 1) _buildPhoneAuthenticationStep(),
              if (currentStep == 2) _buildPasswordInput(),
              if (currentStep == 3) _buildUsernameInput(),
              if (currentStep == 4) _buildUserPreferences(),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1: Phone Authentication (Phone Number Input & SMS Code Verification)
  Widget _buildPhoneAuthenticationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_languageCode == 'vi' ? 'Bước 1: Xác minh số điện thoại của bạn':'Step 1: Verify Your Phone Number',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (!isSmsSent) ...[
          // Phone Number Input
          TextField(
            controller: phoneController,
            focusNode: phoneFocusNode,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: _languageCode == 'vi' ? 'Số điện thoại':'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              border: const OutlineInputBorder(),
              errorText: phoneError ? phoneErrorText : null,
            ),
          ),
          const SizedBox(height: 24),
          // Authenticate Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: isAuthenticating ? null : _authenticatePhoneNumber,
                child: isAuthenticating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(_languageCode == 'vi' ? 'Xác thực':'Authenticate'),
              ),
            ],
          ),
        ] else ...[
          // SMS Code Input
          TextField(
            controller: smsCodeController,
            focusNode: smsCodeFocusNode,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _languageCode == 'vi' ? 'Mã SMS':'SMS Code',
              prefixIcon: const Icon(Icons.sms),
              border: const OutlineInputBorder(),
              errorText: smsError ? smsErrorText : null,
            ),
          ),
          const SizedBox(height: 24),
          // Verify Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCountdownActive)
                    Text(_languageCode == 'vi' ? 'Gửi lại mã OTP sau $resendCountdown giây': "Resend OTP in $resendCountdown seconds",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        _resendOtp();
                      },
                      child: Text(_languageCode == 'vi' ? 'Gửi lại mã OTP':'Resend OTP'),
                    ),
                ],
              ),

              ElevatedButton(
                onPressed: isAuthenticating ? null : _verifySmsCode,
                child: isAuthenticating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(_languageCode == 'vi' ? 'Xác minh': 'Verify'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Step 2: Password and Confirm Password Input
  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_languageCode == 'vi' ? 'Bước 2: Đặt mật khẩu của bạn':'Step 2: Set Your Password',
          style: const  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: true, // Always obscure text
          decoration: InputDecoration(
            labelText: _languageCode == 'vi' ? 'Mật khẩu':'Password',
            prefixIcon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
            errorText: passwordError ? passwordErrorText : null,
            // Remove suffixIcon
          ),
          maxLength: 16, // Restrict password to 16 characters
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPasswordController,
          focusNode: confirmPasswordFocusNode,
          obscureText: true, // Always obscure text
          decoration: InputDecoration(
            labelText: _languageCode == 'vi' ? 'Xác nhận mật khẩu': 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            errorText:
            confirmPasswordError ? confirmPasswordErrorText : null,
            // Remove suffixIcon
          ),
          maxLength: 16, // Restrict confirm password to 16 characters
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: ()  {
                String password = passwordController.text.trim();
                String confirmPassword =
                confirmPasswordController.text.trim();
                bool isValid = true;

                setState(() async {
                  // Validate Password
                  if (password.isEmpty) {
                    passwordError = true;
                    passwordErrorText = _languageCode == 'vi' ? 'Vui lòng nhập mật khẩu của bạn.':'Please enter your password.';
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

                  // Validate Confirm Password
                  if (confirmPassword.isEmpty) {
                    confirmPasswordError = true;
                    confirmPasswordErrorText = _languageCode == 'vi' ? 'Vui lòng xác nhận mật khẩu của bạn.':
                    'Please confirm your password.';
                    isValid = false;
                  } else if (!validateConfirmPassword(
                      password, confirmPassword)) {
                    confirmPasswordError = true;
                    confirmPasswordErrorText = _languageCode == 'vi' ? 'Mật khẩu không khớp.':
                    'Passwords do not match.';
                    isValid = false;
                  } else {
                    confirmPasswordError = false;
                    confirmPasswordErrorText = '';
                    try{
                      var result = await _setPassword(password, confirmPassword);
                      if(result){
                        _nextStep();
                      }

                    }
                    catch(e){
                      isValid = false;
                      confirmPasswordError = true;
                      confirmPasswordErrorText = e.toString();
                    }


                  }
                });
              },
              child: Text(_languageCode == 'vi' ? 'Đồng ý':'Agree'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Username Input
  Widget _buildUsernameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_languageCode == 'vi' ? 'Bước 3: Chọn một biệt danh':
          'Step 3: Choose a Nickname',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: usernameController,
          focusNode: usernameFocusNode,
          decoration: InputDecoration(
            labelText: _languageCode == 'vi' ? 'Biệt danh':'Nickname',
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(),
            errorText: usernameError ? usernameErrorText : null,
          ),
          keyboardType: TextInputType.text,
          onTap: () {
            setState(() {
              usernameError = false;
            });
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                String username = usernameController.text.trim();
                if (username.isEmpty) {
                  setState(() {
                    usernameError = true;
                    usernameErrorText = _languageCode == 'vi' ? 'Vui lòng nhập biệt danh':'Please enter a nickname.';
                  });
                } else {
                  setState(() {
                    usernameError = false;
                    usernameErrorText = '';
                  });
                  setState(()  async {
                    try{
                      await _userService.sendUserDataRequest(UpdateUserRequest(username: username));
                      listTag = await _tagService.getAllTag();
                      var listUserTag = await _tagService.getUserTag();
                      if(listUserTag.length > 0){
                        listTagIdSelected = listUserTag.map((e) => e.id).toList();
                      }
                      _nextStep();
                    }catch(e){
                      usernameError = true;
                      usernameErrorText = e.toString();
                      usernameFocusNode.unfocus();
                    }
                  });
                }
              },
              child: Text(_languageCode == 'vi' ? 'Đồng ý':'Agree'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 4: User Preferences Selection
  Widget _buildUserPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_languageCode == 'vi' ? 'Bước 4: Chọn tùy chọn của bạn':
          'Step 4: Select Your Preferences',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(_languageCode == 'vi' ? 'Chọn sở thích của bạn':
          'Choose your preferences',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildAllTagChips(),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                if (listTagIdSelected.length < 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_languageCode == 'vi' ? 'Vui lòng chọn ít nhất 5 tùy chọn':'Please select at least 5 preferences.'),
                    ),
                  );
                } else {
                  _completeRegistration();
                }
              },
              child: Text(_languageCode == 'vi' ? 'Hoàn thành':'Complete'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildAllTagChips()  {

    return listTag.map((tag) {
      final isSelected = listTagIdSelected.contains(tag.id);
      return GestureDetector(
        onTap: () {
          setState(() {
            // Toggle the tag selection with enforcement of minimum 5 selections
            if (isSelected) {
              // Allow deselection only if more than 5 tags are selected
              if (listTagIdSelected.length > 5) {
                listTagIdSelected.remove(tag.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_languageCode == 'vi' ? 'Bạn phải chọn ít nhất 5 tùy chọn':'You must select at least 5 preferences.'),
                  ),
                );
              }
            } else {
              listTagIdSelected.add(tag.id);
            }
          });
        },
        child: Chip(
          label: Text(
            tag.tagName,
            style: TextStyle(color: isSelected ? Colors.white : Colors.green),
          ),
          shape: const StadiumBorder(
            side: BorderSide(color: Colors.green),
          ),
          backgroundColor: isSelected ? Colors.green : Colors.transparent,
        ),
      );
    }).toList();
  }
}
