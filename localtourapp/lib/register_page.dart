// register_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/places/tag.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Step control
  int currentStep = 1;

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

  // FirebaseAuth instance (use MockFirebaseAuth for testing if needed)
  final FirebaseAuth auth = FirebaseAuth.instance;
  // final FirebaseAuth auth = MockFirebaseAuth(); // Uncomment for testing

  @override
  void initState() {
    super.initState();
    // Request focus on the first input field when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(phoneFocusNode);
    });
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
        phoneErrorText = 'Please enter your phone number.';
      });
      return;
    } else if (!validatePhoneNumber(phoneNumber)) {
      setState(() {
        phoneError = true;
        phoneErrorText = 'Please enter a valid phone number.';
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
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (optional)
          // For registration, you might want to skip auto-verification
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isAuthenticating = false;
            phoneError = true;
            phoneErrorText = e.message ?? 'Phone verification failed.';
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
    } catch (e) {
      setState(() {
        isAuthenticating = false;
        phoneError = true;
        phoneErrorText = 'Error sending SMS code. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  // Function to verify SMS code
  void _verifySmsCode() async {
    FocusScope.of(context).unfocus(); // Close keyboard
    String smsCode = smsCodeController.text.trim();
    if (smsCode.isEmpty) {
      setState(() {
        smsError = true;
        smsErrorText = 'Please enter the SMS code.';
      });
      return;
    } else if (!validateSMSCode(smsCode)) {
      setState(() {
        smsError = true;
        smsErrorText = 'Please enter a valid 6-digit SMS code.';
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
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in the user with the credential
      await auth.signInWithCredential(credential);

      setState(() {
        isSmsSent = false; // Reset SMS sent flag
        isAuthenticating = false;
        _nextStep(); // Proceed to the next step
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully.'),
        ),
      );
    } catch (e) {
      setState(() {
        isAuthenticating = false;
        smsError = true;
        smsErrorText = 'Invalid SMS code. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid verification code.'),
        ),
      );
    }
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

  // Function to go back to the previous step
  void _previousStep() {
    setState(() {
      if (currentStep > 1) {
        currentStep -= 1;
      }
    });

    // After updating the step, set focus to the first input of the new step
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (currentStep) {
        case 1:
          FocusScope.of(context).requestFocus(phoneFocusNode);
          break;
        case 2:
          FocusScope.of(context).requestFocus(passwordFocusNode);
          break;
        case 3:
          FocusScope.of(context).requestFocus(usernameFocusNode);
          break;
        default:
          FocusScope.of(context).unfocus();
      }
    });
  }

  // Function to handle registration completion
  void _completeRegistration() {
    // Implement your registration logic here (e.g., save user to database)
    // For demonstration, we'll simply show a success message

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration Successful!'),
      ),
    );

    // Optionally, navigate to the login page or main application screen
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside input fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          leading: currentStep > 1
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousStep,
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
                        ['Phone', 'Password', 'Username', 'Preferences']
                        [index],
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
              if (currentStep == 4) _buildUserPreferences(userProvider),
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
        const Text(
          'Step 1: Verify Your Phone Number',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (!isSmsSent) ...[
          // Phone Number Input
          TextField(
            controller: phoneController,
            focusNode: phoneFocusNode,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
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
                    : const Text('Authenticate'),
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
              labelText: 'SMS Code',
              prefixIcon: const Icon(Icons.sms),
              border: const OutlineInputBorder(),
              errorText: smsError ? smsErrorText : null,
            ),
          ),
          const SizedBox(height: 24),
          // Verify Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                    : const Text('Verify'),
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
        const Text(
          'Step 2: Set Your Password',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: true, // Always obscure text
          decoration: InputDecoration(
            labelText: 'Password',
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
            labelText: 'Confirm Password',
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
            OutlinedButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                String password = passwordController.text.trim();
                String confirmPassword =
                confirmPasswordController.text.trim();
                bool isValid = true;

                setState(() {
                  // Validate Password
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

                  // Validate Confirm Password
                  if (confirmPassword.isEmpty) {
                    confirmPasswordError = true;
                    confirmPasswordErrorText =
                    'Please confirm your password.';
                    isValid = false;
                  } else if (!validateConfirmPassword(
                      password, confirmPassword)) {
                    confirmPasswordError = true;
                    confirmPasswordErrorText =
                    'Passwords do not match.';
                    isValid = false;
                  } else {
                    confirmPasswordError = false;
                    confirmPasswordErrorText = '';
                  }
                });

                if (isValid) {
                  _nextStep();
                }
              },
              child: const Text('Agree'),
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
        const Text(
          'Step 3: Choose a Username',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: usernameController,
          focusNode: usernameFocusNode,
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(),
            errorText: usernameError ? usernameErrorText : null,
          ),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                String username = usernameController.text.trim();
                if (username.isEmpty) {
                  setState(() {
                    usernameError = true;
                    usernameErrorText = 'Please enter a username.';
                  });
                } else {
                  setState(() {
                    usernameError = false;
                    usernameErrorText = '';
                  });
                  // Optionally, you can save the username to the user provider here
                  _nextStep();
                }
              },
              child: const Text('Agree'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 4: User Preferences Selection
  Widget _buildUserPreferences(UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4: Select Your Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Choose your preferences',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildAllTagChips(userProvider),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                if (userProvider.preferredTagIds.length < 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least 5 preferences.'),
                    ),
                  );
                } else {
                  _completeRegistration();
                }
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildAllTagChips(UserProvider userProvider) {
    return listTag.map((tag) {
      final isSelected = userProvider.isTagSelected(tag.tagId);

      return GestureDetector(
        onTap: () {
          setState(() {
            // Toggle the tag selection with enforcement of minimum 5 selections
            if (isSelected) {
              // Allow deselection only if more than 5 tags are selected
              if (userProvider.preferredTagIds.length > 5) {
                userProvider.removeTag(tag.tagId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must select at least 5 preferences.'),
                  ),
                );
              }
            } else {
              userProvider.addTag(tag.tagId);
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
