// lib/page/account/personal_information_page.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/users/password_change_request.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/auth_service.dart';
import 'package:localtourapp/services/user_service.dart';
import 'package:intl/intl.dart';
import '../../models/users/update_user_request.dart';
import 'view_profile/for_got_password.dart'; // Ensure you have intl package in pubspec.yaml

class PersonalInformationPage extends StatefulWidget {
  final Userprofile userprofile;
  final String userId;
  final VoidCallback? fetchData;

  const PersonalInformationPage({Key? key, required this.userprofile, required this.userId, this.fetchData,}) : super(key: key);
  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  // Form key to manage form state
  final _formKey = GlobalKey<FormState>();

  AuthService _authService = AuthService();
  UserService _userService = UserService();
  // Controllers for form fields
  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _nicknameController;
  late Userprofile _userprofile;
  // Variables for interactive fields
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _userprofile = widget.userprofile;
    // Initialize controllers with current user data
    _fullNameController =
        TextEditingController(text: _userprofile.fullName );
    _passwordController = TextEditingController();
    _emailController =
        TextEditingController(text: _userprofile.email );
    _dobController = TextEditingController(
        text: _userprofile.dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(_userprofile.dateOfBirth!)
            : '');
    _phoneNumberController =
        TextEditingController(text: _userprofile.phoneNumber);
    _addressController =
        TextEditingController(text: _userprofile.address);
    _nicknameController =
        TextEditingController(text: _userprofile.userName);
    _selectedGender = _userprofile.gender;

  }

  Future<void> fetchData() async{
    var userfetched = await  _userService.getUserProfile(widget.userId);

    _fullNameController =
        TextEditingController(text: userfetched.fullName);
    _passwordController = TextEditingController();
    _emailController =
        TextEditingController(text: userfetched.email);
    _dobController = TextEditingController(
        text: userfetched.dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(userfetched.dateOfBirth!)
            : '');
    _phoneNumberController =
        TextEditingController(text: userfetched.phoneNumber);
    _addressController =
        TextEditingController(text: userfetched.address);
    _nicknameController =
        TextEditingController(text: userfetched.userName);
    _selectedGender = userfetched.gender;

    setState(() {
      _userprofile = userfetched;
    });
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
  void _savePersonalInformation() async {
    UpdateUserRequest userdata = new UpdateUserRequest(
      username: _nicknameController.text == widget.userprofile.userName ? null : _nicknameController.text,
      address: _addressController.text,
      dateOfBirth: DateFormat('yyyy-MM-dd').parse(_dobController.text),
      fullName: _fullNameController.text,
      gender: _selectedGender,
    );

    var result = await _userService.sendUserDataRequest(userdata);
    if(result != null){
      setState(() {
        _userprofile = result;
      });
    }

    if (_formKey.currentState!.validate()) {
      // Fetch the user provider
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal information saved')),
      );
    }
  }


  Future<void> addPhoneNumber() async{
    String result = await _authService.AddPhoneNumber();
    if(result != null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text('$result.')),
      );
      fetchData();
      widget.fetchData!();
    }
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
                      // Password Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true, // Allow clicking outside to close the dialog
                                builder: (BuildContext context) {
                                  final TextEditingController currentPasswordController = TextEditingController();
                                  final TextEditingController newPasswordController = TextEditingController();
                                  final TextEditingController confirmPasswordController = TextEditingController();
                                  final FocusNode currentPasswordFocus = FocusNode();
                                  final FocusNode newPasswordFocus = FocusNode();
                                  final FocusNode confirmPasswordFocus = FocusNode();
                                  bool currentPasswordError = false;
                                  bool newPasswordError = false;
                                  bool confirmPasswordError = false;
                                  String newPasswordErrorText = 'Password must have 1 uppercase letter, 1 special character, 1 number, and be at least 8 characters long';
                                  String oldPasswordErrorText = '';
                                  // Helper function to validate the new password
                                  bool validateNewPassword(String password) {
                                    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
                                    return passwordRegExp.hasMatch(password);
                                  }
                                  bool validateConfirmPassword(String password) {
                                    return newPasswordController.text == password;
                                  }

                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return GestureDetector(
                                        onTap: () => FocusScope.of(context).unfocus(), // Unfocus to close keyboard
                                        child: AlertDialog(
                                          title: const Text('Change Password'),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Current Password Field
                                                const Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Your Current Password:'),
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller: currentPasswordController,
                                                  focusNode: currentPasswordFocus,
                                                  obscureText: true,
                                                  decoration: InputDecoration(
                                                    border: const OutlineInputBorder(),
                                                    hintText: 'Enter your current password',
                                                    errorText: currentPasswordError ? oldPasswordErrorText : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),

                                                // New Password Field
                                                const Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Add New Password:'),
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller: newPasswordController,
                                                  focusNode: newPasswordFocus,
                                                  obscureText: true,
                                                  decoration: InputDecoration(
                                                    errorMaxLines: 3,
                                                    border: const OutlineInputBorder(),
                                                    hintText: 'Enter your new password',
                                                    errorText: newPasswordError
                                                        ? newPasswordErrorText
                                                        : null,
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      newPasswordError = !validateNewPassword(value);
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                const Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Confirm New Password:'),
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller: confirmPasswordController,
                                                  focusNode: confirmPasswordFocus,
                                                  obscureText: true,
                                                  decoration: InputDecoration(
                                                    errorMaxLines: 3,
                                                    border: const OutlineInputBorder(),
                                                    hintText: 'Enter your confirm new password',
                                                    errorText: confirmPasswordError
                                                        ? 'New password and confirm password is not match'
                                                        : null,
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      confirmPasswordError = !validateConfirmPassword(value);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {

                                                  var result = await _userService.changePassword(
                                                      new PasswordChangeRequest(oldPassword: currentPasswordController.text,
                                                          newPassword: newPasswordController.text,
                                                          confirmPassword: confirmPasswordController.text));
                                                  currentPasswordError = false;
                                                  newPasswordError = false;
                                                  confirmPasswordError = false;
                                                  if(result.success){
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Password changed successfully')),
                                                    );
                                                  }else{

                                                    if(result.newPasswordError != null){
                                                      newPasswordFocus.requestFocus();
                                                      setState((){
                                                        newPasswordError = true;
                                                        newPasswordErrorText = result.newPasswordError!;
                                                      });
                                                    }
                                                    if(result.oldPasswordError != null){
                                                      setState(() {
                                                        oldPasswordErrorText = result.oldPasswordError!;
                                                        currentPasswordError = true;
                                                      });
                                                      currentPasswordFocus.requestFocus();
                                                    }

                                                  }


                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Change Password',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'Change Password',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ForgotPasswordDialog.show(context,'',() {
                              },);
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
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
                      _userprofile.email != "" ?
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
                      ) :
                      GestureDetector(
                        onTap: () async {
                         String result = await _authService.AddEmailGoogle();
                         if(result != null){
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                                 content:
                                 Text('$result.')),
                           );
                           fetchData();
                           widget.fetchData!();
                         }

                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13,horizontal: 90), // Adjust spacing

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueAccent.withOpacity(0.8),
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
                                'Add Google Email',
                                style: TextStyle(
                                  color: Colors.white, // Màu chữ đỏ
                                  fontWeight: FontWeight.w600, // Chữ đậm
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      ,
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
                      _userprofile.phoneNumber != "" ?
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
                      ):
                      GestureDetector(
                        onTap: () async {
                          ForgotPasswordDialog.show(context,'add', ()  {
                            addPhoneNumber();
                          },);

                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13,horizontal: 90), // Adjust spacing

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green.withOpacity(0.8),
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
                                    image: AssetImage('assets/images/phone_logo.png'),
                                    fit: BoxFit.contain,

                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Add Phone Number',
                                style: TextStyle(
                                  color: Colors.white, // Màu chữ đỏ
                                  fontWeight: FontWeight.w600, // Chữ đậm
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      ,
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
                        items: ['Male', 'Female', 'Other', 'Prefer not to say','']
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
