// lib/page/account/personal_information_page.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/page/account/user_provider.dart';
import 'package:intl/intl.dart'; // Ensure you have intl package in pubspec.yaml

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({Key? key}) : super(key: key);

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  // Form key to manage form state
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _nicknameController;

  // Variables for interactive fields
  bool _isPasswordVisible = false;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    final userProvider =
    Provider.of<UserProvider>(context, listen: false);
    final User currentUser = userProvider.currentUser;

    _fullNameController =
        TextEditingController(text: currentUser.fullName ?? '');
    _passwordController = TextEditingController();
    _emailController =
        TextEditingController(text: currentUser.email ?? '');
    _dobController = TextEditingController(
        text: currentUser.dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(currentUser.dateOfBirth!)
            : '');
    _phoneNumberController =
        TextEditingController(text: currentUser.phoneNumber ?? '');
    _addressController =
        TextEditingController(text: currentUser.address ?? '');
    _nicknameController =
        TextEditingController(text: currentUser.userName ?? '');
    _selectedGender = currentUser.gender;
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _fullNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  // Function to show date picker and set DOB
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now().subtract(
        const Duration(days: 365 * 18)); // 18 years ago
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Function to handle form submission
  void _savePersonalInformation() {
    if (_formKey.currentState!.validate()) {
      // Fetch the user provider
      final userProvider =
      Provider.of<UserProvider>(context, listen: false);
      final User currentUser = userProvider.currentUser;

      // Update user information
      User updatedUser = User(
        userId: currentUser.userId,
        userName: _nicknameController.text.trim(),
        normalizedUserName:
        _nicknameController.text.trim().toUpperCase(),
        email: _emailController.text.trim(),
        normalizedEmail:
        _emailController.text.trim().toUpperCase(),
        emailConfirmed: currentUser.emailConfirmed,
        passwordHash: _passwordController.text.isNotEmpty
            ? _hashPassword(_passwordController.text.trim())
            : currentUser.passwordHash,
        phoneNumber: _phoneNumberController.text.trim(),
        phoneNumberConfirmed: currentUser.phoneNumberConfirmed,
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dobController.text.isNotEmpty
            ? DateTime.parse(_dobController.text)
            : null,
        address: _addressController.text.trim(),
        gender: _selectedGender,
        profilePictureUrl: currentUser.profilePictureUrl,
        dateCreated: currentUser.dateCreated,
        dateUpdated: DateTime.now(),
        reportTimes: currentUser.reportTimes,
      );

      // Update the user in the provider
      userProvider.updateUser(updatedUser);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal information saved')),
      );
    }
  }

  // Placeholder for password hashing function
  String _hashPassword(String password) {
    // Implement your hashing logic here
    // For demonstration, we'll return the password itself
    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.orangeAccent, // Customize as needed
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Required Information Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Required Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                    Border.all(width: 1, color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Full Name
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Full Name',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your full name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible =
                                !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          // Password is required only if the user wants to change it
                          // If not changing, allow empty
                          if (value != null && value.isNotEmpty) {
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          // Simple email validation
                          if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Date of Birth',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: 'Select your date of birth',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Date of Birth is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Phone Number',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your phone number',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone Number is required';
                          }
                          // Simple phone number validation
                          if (!RegExp(
                              r'^\+?[0-9]{7,15}$')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Additional Information Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                    Border.all(width: 1, color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Gender
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Gender',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select your gender',
                        ),
                        items: ['Male', 'Female', 'Other', 'Prefer not to say']
                            .map((gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Gender is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Address',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your address',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nickname
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nickname',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your nickname',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nickname is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _savePersonalInformation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Button color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
