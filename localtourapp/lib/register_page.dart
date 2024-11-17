// register_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/places/tag.dart';
import 'package:localtourapp/provider/user_provider.dart';

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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // FocusNodes for input fields
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode usernameFocusNode = FocusNode();

  // Validation flags and messages
  bool phoneError = false;
  String phoneErrorText = '';
  bool passwordError = false;
  String passwordErrorText = '';
  bool confirmPasswordError = false;
  String confirmPasswordErrorText = '';
  bool usernameError = false;
  String usernameErrorText = '';

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
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();

    phoneFocusNode.dispose();
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

  // Function to proceed to the next step
  void _nextStep() {
    // Unfocus the current input field
    FocusScope.of(context).unfocus();

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
        // No TextField in preferences, so just unfocus all
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
              if (currentStep == 1) _buildPhoneInput(),
              if (currentStep == 2) _buildPasswordInput(),
              if (currentStep == 3) _buildUsernameInput(),
              if (currentStep == 4) _buildUserPreferences(userProvider),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1: Phone Number Input
  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Enter Your Phone Number',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                String phone = phoneController.text.trim();
                if (phone.isEmpty) {
                  setState(() {
                    phoneError = true;
                    phoneErrorText = 'Please enter your phone number.';
                  });
                } else if (!validatePhoneNumber(phone)) {
                  setState(() {
                    phoneError = true;
                    phoneErrorText = 'Please enter a valid phone number.';
                  });
                } else {
                  setState(() {
                    phoneError = false;
                    phoneErrorText = '';
                  });
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
