import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPickerView extends StatefulWidget {
  @override
  _MapPickerViewState createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  GoogleMapController? mapController;
  LatLng selectedLocation = LatLng(13.324603, 100.973677);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("ข้อผิดพลาด", "กรุณาเปิด GPS ก่อนใช้งาน");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("ข้อผิดพลาด", "ต้องการสิทธิ์เข้าถึงตำแหน่งที่ตั้ง");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("ข้อผิดพลาด", "กรุณาเปิดสิทธิ์ GPS ใน Settings");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("❌ ERROR: $_checkLocationPermission -> $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("เลือกสถานที่", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: selectedLocation, zoom: 14),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: (LatLng latLng) {
              setState(() {
                selectedLocation = latLng;
              });
            },
            markers: {
              Marker(
                markerId: MarkerId("selectedLocation"),
                position: selectedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              )
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Get.back(result: selectedLocation),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  Text("ยืนยันตำแหน่ง", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
