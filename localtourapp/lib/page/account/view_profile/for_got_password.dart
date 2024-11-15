import 'package:flutter/material.dart';
import 'package:localtourapp/mock_firebase.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordDialog {
  static void show(BuildContext context, {FirebaseAuth? firebaseAuth}) {
    final auth = firebaseAuth ?? MockFirebaseAuth(); // Switch between real and mock Firebase
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final FocusNode newPasswordFocus = FocusNode();
    bool isPhoneVerified = false;
    bool newPasswordError = false;

    // Helper function to validate the new password
    bool validateNewPassword(String password) {
      final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
      return passwordRegExp.hasMatch(password);
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Unfocus to close keyboard
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Forgot Password'),
                content: isPhoneVerified
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        border: const OutlineInputBorder(),
                        hintText: 'Enter your new password',
                        errorText: newPasswordError
                            ? 'Password must have 1 uppercase letter, 1 special character, 1 number, and be at least 8 characters long'
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          newPasswordError = !validateNewPassword(value);
                        });
                      },
                    ),
                  ],
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Input your phone number to reset password:'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Phone number',
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (!isPhoneVerified)
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus(); // Close keyboard after phone number input
                        try {
                          await auth.verifyPhoneNumber(
                            phoneNumber: phoneController.text,
                            verificationCompleted: (PhoneAuthCredential credential) async {
                              await auth.signInWithCredential(credential);
                              setState(() {
                                isPhoneVerified = true;
                              });
                            },
                            verificationFailed: (FirebaseAuthException e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Phone verification failed: ${e.message}')),
                              );
                            },
                            codeSent: (String verificationId, int? resendToken) async {
                              final String smsCode = await _promptUserForSMSCode(context);
                              final credential = PhoneAuthProvider.credential(
                                  verificationId: verificationId, smsCode: smsCode);

                              try {
                                await auth.signInWithCredential(credential);
                                FocusScope.of(context).unfocus(); // Close keyboard after successful authentication
                                setState(() {
                                  isPhoneVerified = true;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error: Invalid verification code.')),
                                );
                              }
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {},
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      },
                      child: const Text('Authenticate'),
                    ),
                  if (isPhoneVerified)
                    ElevatedButton(
                      onPressed: () async {
                        if (!validateNewPassword(newPasswordController.text)) {
                          setState(() {
                            newPasswordError = true;
                          });
                          return;
                        }

                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        userProvider.currentUser.passwordHash = newPasswordController.text;
                        userProvider.updateUser(userProvider.currentUser);

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset successfully')),
                        );
                      },
                      child: const Text('Set New Password'),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Helper function to show an input dialog for SMS code
  static Future<String> _promptUserForSMSCode(BuildContext context) async {
    String smsCode = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter SMS Code'),
          content: TextField(
            onChanged: (value) {
              smsCode = value;
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "SMS Code"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return smsCode;
  }
}
