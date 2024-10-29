import 'package:flutter/material.dart';

class NowLocation extends StatefulWidget {
  const NowLocation({super.key});

  @override
  State<NowLocation> createState() => _NowLocationState();
}

class _NowLocationState extends State<NowLocation> {
  String _location = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    // Clean up if necessary
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _location = '123 TKC street, Tan Dinh ward, District 1, HCM City';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your location',
              style: TextStyle(color: Colors.black, fontSize: 11),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                Flexible(
                  child: Text(
                    _location,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
