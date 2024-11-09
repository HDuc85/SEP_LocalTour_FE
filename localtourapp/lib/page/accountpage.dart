import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width, // Changed from size.height to size.width
      child: Scaffold(
        appBar: AppBar(title: Text("Account Page"),),
        body: Center(
          child: Text("This is Account Page"),
        ),
      ),
    );
  }
}
