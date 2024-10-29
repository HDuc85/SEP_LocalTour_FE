import 'package:flutter/material.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: size.width, // Changed from size.height to size.width
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Map Page"),
          ),
          body: VietmapGL(
            styleString:
            'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=9e37b843f972388f80a9e51612cad4c1bc3877c71c107e46',
            initialCameraPosition:
            const CameraPosition(target: LatLng(10.762317, 106.654551)),
            onMapCreated: (VietmapController controller) {
              setState(() {
                // _mapController = controller;
              });
            },
          ),
        )
    );
  }
}
