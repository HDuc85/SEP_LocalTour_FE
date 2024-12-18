// forgot_password_dialog.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localtourapp/services/auth_service.dart';
import '../../../main.dart';

class ForgotPasswordDialog {
  static void show(BuildContext context,String type,VoidCallback? onCompleted, {FirebaseAuth? firebaseAuth}) {
    final AuthService authService = AuthService();
    final FirebaseAuth auth = FirebaseAuth.instance;

    final TextEditingController phoneController = TextEditingController();
    final TextEditingController smsCodeController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmNewPasswordController = TextEditingController();

    final FocusNode newPasswordFocus = FocusNode();
    final FocusNode confirmNewPasswordFocus = FocusNode();

    // Validation flags and messages
    bool newPasswordError = false;
    bool confirmNewPasswordError = false;
    String confirmNewPasswordErrorText = '';
    bool phoneError = false;
    String phoneErrorText = '';
    bool smsError = false;
    String smsErrorText = '';
    int step = 1; // Steps: 1 - Phone, 2 - SMS, 3 - New Password
    String verificationId = '';

    // Helper function to validate the new password
    bool validateNewPassword(String password) {
      final passwordRegExp =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
      return passwordRegExp.hasMatch(password);
    }

    // Helper function to validate the phone number
    bool validatePhoneNumber(String phone) {
      final phoneRegExp = RegExp(r'^\+?\d{10}$'); // Simple regex for phone numbers
      return phoneRegExp.hasMatch(phone);
    }

    // Helper function to validate the SMS code
    bool validateSMSCode(String code) {
      final smsRegExp = RegExp(r'^\d{6}$'); // Assuming 6-digit code
      return smsRegExp.hasMatch(code);
    }

    showDialog(
      context: context,
      barrierDismissible: true, // Allow dialog dismissal by tapping outside
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Unfocus to close keyboard
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Forgot Password'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (step == 1) ...[
                        Text( type == 'add' ? 'Input your phone number to add' :
                          'Input your phone number to reset password:',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Phone number',
                            errorText: phoneError ? phoneErrorText : null,
                          ),
                        ),
                      ] else if (step == 2) ...[
                        const Text(
                          'Enter the SMS Code sent to your phone:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: smsCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'SMS Code',
                            errorText: smsError ? smsErrorText : null,
                          ),
                        ),
                      ] else if (step == 3) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Add New Password:',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: newPasswordController,
                          focusNode: newPasswordFocus,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your new password',
                          ),
                          onChanged: (value) {
                            setState(() {
                              newPasswordError = !validateNewPassword(value);
                            });
                          },
                        ),
                        const SizedBox(height: 4),
                        if (newPasswordError)
                          const Text(
                            'Password must have 1 uppercase letter, 1 special character, 1 number, and be at least 8 characters long',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            maxLines: 3,
                          ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Add New Password:',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: confirmNewPasswordController,
                          focusNode: confirmNewPasswordFocus,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your confirm new password',
                          ),
                          onChanged: (value) {
                            setState(() {
                              confirmNewPasswordError = !validateNewPassword(value);
                              if(confirmNewPasswordError){
                                confirmNewPasswordErrorText = 'Password must have 1 uppercase letter, 1 special character, 1 number, and be at least 8 characters long';
                              }else{
                                if(value != newPasswordController.text){
                                  confirmNewPasswordError = true;
                                  confirmNewPasswordErrorText = 'Password is not match';
                                }
                              }

                            });
                          },
                        ),
                        const SizedBox(height: 4),
                        if (confirmNewPasswordError)
                           Text(
                            confirmNewPasswordErrorText,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            maxLines: 3,
                          ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  if (step == 1) ...[
                    ElevatedButton(
                      onPressed: () async {
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
                          });
                        }

                        try {

                           String phoneNumberSent = '+84${phoneNumber.substring(1)}';

                          await auth.verifyPhoneNumber(
                            phoneNumber: phoneNumberSent,
                            verificationCompleted:
                                (PhoneAuthCredential credential) async {
                              // For testing, we'll skip auto-verification to require SMS code input
                              // However, you can simulate auto-verification if desired
                            },
                            verificationFailed:
                                (FirebaseAuthException e) {
                              setState(() {
                                phoneError = true;
                                phoneErrorText = e.message ?? 'Phone verification failed.';
                              });
                            },
                            codeSent:
                                (String verificationIdParam, int? resendToken) async {
                              verificationId = verificationIdParam;
                              setState(() {
                                step = 2; // Move to SMS code input
                              });
                            },
                            codeAutoRetrievalTimeout:
                                (String verificationIdParam) {
                              verificationId = verificationIdParam;
                              // Optionally, handle auto-retrieval timeout
                            },
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                      child: const Text('Authenticate'),
                    ),
                  ] else if (step == 2) ...[
                    ElevatedButton(
                      onPressed: () async {
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
                          });
                        }

                        try {
                          // Create PhoneAuthCredential with the code
                          PhoneAuthCredential credential = PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: smsCode,
                          );

                          // Attempt to sign in
                          await auth.signInWithCredential(credential);

                          if(type == 'add'){
                            onCompleted!();
                            Navigator.of(context).pop();
                          }

                          var result = await authService.sendUserIdToBackend();
                          if(result.firstTime){
                            navigatorKey.currentState?.pushNamed('/register');
                          }

                          // If successful, move to setting new password
                          setState(() {
                            step = 3;
                          });
                        } catch (e) {
                          setState(() {
                            smsError = true;
                            smsErrorText = 'Invalid SMS code. Please try again.';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error: Invalid verification code.'),
                            ),
                          );
                        }
                      },
                      child: const Text('Verify'),
                    ),
                  ] else if (step == 3) ...[
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus(); // Close keyboard
                        String newPassword = newPasswordController.text.trim();
                        String confirmNewPassword = confirmNewPasswordController.text.trim();
                        if (!validateNewPassword(newPassword)) {
                          setState(() {
                            newPasswordError = true;
                          });
                          return;
                        }
                        if(!validateNewPassword(confirmNewPassword)){
                          setState(() {
                           confirmNewPasswordError = true;
                          });
                        }

                        try {
                            var result = await authService.setPassword(newPassword, confirmNewPassword);
                            if(result){
                              Navigator.of(context).pop(); // Close the dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset successfully'),
                                ),
                              );
                            }


                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error updating password: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                      child: const Text('Set New Password'),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}
