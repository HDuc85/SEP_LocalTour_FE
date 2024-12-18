import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../data/models/vietmap_reverse_model.dart';

class AddressInfo extends StatelessWidget {
  final VietmapReverseModel data;
  final VoidCallback buildRoute;
  final VoidCallback buildAndStartRoute;
  const AddressInfo(
      {super.key,
      required this.data,
      required this.buildRoute,
      required this.buildAndStartRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.name ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
          Text(data.address ?? ''),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: vietmapColor)))),
                  onPressed: () {
                    buildRoute();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.alt_route_sharp, size: 17),
                      Text('Đường đi')
                    ],
                  )),
              TextButton(
                  style: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.all<Color>(vietmapColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: vietmapColor)))),
                  onPressed: () {
                    buildAndStartRoute();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.navigation_sharp, size: 17),
                      Text('Bắt đầu'),
                    ],
                  )),
            ],
          )
        ],
      ),
    );
  }
}
