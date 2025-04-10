import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import '../controllers/home_controller.dart';
import '../views/map_picker_view.dart';

class PassengerBookingView extends StatefulWidget {
  @override
  _PassengerBookingViewState createState() => _PassengerBookingViewState();
}

class _PassengerBookingViewState extends State<PassengerBookingView> {
  final HomeController homeController = Get.find();
  final TextEditingController passengerNameController = TextEditingController();

  final service = Get.arguments;
  late String selectedVehicle;
  late String selectedRideType;

  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  String pickupAddress = "เลือกสถานที่ขึ้นรถ";
  String dropoffAddress = "เลือกสถานที่ลงรถ";
  double distanceKm = 0.0;
  double calculatedPrice = 0.0;
  bool isCalculating = false;

  @override
  void initState() {
    super.initState();
    selectedVehicle = service['name'];
    selectedRideType = "normal";
  }

  Future<void> _calculateRoadDistance() async {
    if (pickupLocation == null || dropoffLocation == null) return;

    setState(() => isCalculating = true);

    String apiKey = "AIzaSyDXeajLpR8mnTjjq51KSsOrNey_0XVDHxM";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation!.latitude},${pickupLocation!.longitude}&destination=${dropoffLocation!.latitude},${dropoffLocation!.longitude}&key=$apiKey";

    try {
      final response = await Dio().get(apiUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        double meters =
            (data['routes'][0]['legs'][0]['distance']['value'] as int)
                .toDouble();
        distanceKm = meters / 1000;

        _calculatePrice();
      }
    } catch (e) {
      print("❌ ERROR: คำนวณระยะทางล้มเหลว -> $e");
    } finally {
      setState(() => isCalculating = false);
    }
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    String apiKey = "AIzaSyDXeajLpR8mnTjjq51KSsOrNey_0XVDHxM";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey";

    try {
      final response = await Dio().get(apiUrl);
      if (response.statusCode == 200) {
        return response.data['results'][0]['formatted_address'];
      }
    } catch (e) {
      print("❌ ERROR: ไม่สามารถดึงที่อยู่ -> $e");
    }
    return "${latLng.latitude}, ${latLng.longitude}";
  }

  void _calculatePrice() {
    double basePrice = double.tryParse(service['base_price'].toString()) ?? 0.0;
    double totalPrice = basePrice;

    if (distanceKm <= 5) {
      totalPrice += distanceKm * 10.0;
    } else if (distanceKm <= 10) {
      totalPrice += (5 * 10.0) + ((distanceKm - 5) * 7.5);
    } else if (distanceKm <= 20) {
      totalPrice += (5 * 10.0) + (5 * 7.5) + ((distanceKm - 10) * 12.0);
    } else {
      totalPrice +=
          (5 * 10.0) + (5 * 7.5) + (10 * 12.0) + ((distanceKm - 20) * 20.0);
    }

    setState(() {
      calculatedPrice = totalPrice;
    });
  }

  void _confirmBooking() {
    if (pickupLocation == null || dropoffLocation == null) {
      Get.snackbar("ข้อผิดพลาด", "กรุณาเลือกสถานที่ขึ้นรถและลงรถก่อน");
      return;
    }

    homeController.createPassengerOrder({
      "service_id": service['id'],
      "passenger_name": passengerNameController.text,
      "pickup_location":
          "${pickupLocation!.latitude},${pickupLocation!.longitude}",
      "dropoff_location":
          "${dropoffLocation!.latitude},${dropoffLocation!.longitude}",
      "distance_km": distanceKm,
      "total_price": calculatedPrice,
      "vehicle_type": selectedVehicle,
      "ride_type": selectedRideType,
    });

    Get.snackbar("สำเร็จ", "การจองเดินทางเสร็จสมบูรณ์");
    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("ยืนยันการเดินทาง", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleInfo(),
            const SizedBox(height: 16),
            _buildLocationPicker("สถานที่ขึ้นรถ", pickupLocation, (LatLng loc) {
              setState(() {
                pickupLocation = loc;
              });
              _calculateRoadDistance();
            }, pickupAddress),
            _buildLocationPicker("สถานที่ลงรถ", dropoffLocation, (LatLng loc) {
              setState(() {
                dropoffLocation = loc;
              });
              _calculateRoadDistance();
            }, dropoffAddress),
            _buildDistanceDisplay(),
            _buildPriceDisplay(),
            const SizedBox(height: 16),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplay() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ค่าบริการโดยประมาณ",
              style: GoogleFonts.notoSansThai(fontSize: 16)),
          Text("${calculatedPrice.toStringAsFixed(2)} บาท",
              style: GoogleFonts.notoSansThai(fontSize: 16, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildDistanceDisplay() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ระยะทาง",
              style: GoogleFonts.notoSansThai(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          Text("${distanceKm.toStringAsFixed(2)} กม.",
              style:
                  GoogleFonts.notoSansThai(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildLocationPicker(String title, LatLng? location,
      Function(LatLng) onSelected, String address) {
    return GestureDetector(
      onTap: () async {
        LatLng? result = await Get.to(() => MapPickerView());
        if (result != null) {
          onSelected(result);

          String newAddress = await _getAddressFromLatLng(result);

          setState(() {
            if (title.contains("ขึ้นรถ")) {
              pickupLocation = result;
              pickupAddress = newAddress;
            } else {
              dropoffLocation = result;
              dropoffAddress = newAddress;
            }
          });

          _calculateRoadDistance();
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(address,
                    style: GoogleFonts.notoSansThai(fontSize: 16))),
            Icon(Icons.map, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(service['name'] ?? "ไม่ทราบชื่อ",
              style: GoogleFonts.notoSansThai(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("ค่าบริการเริ่มต้น: ${service['base_price'] ?? "N/A"} บาท",
              style:
                  GoogleFonts.notoSansThai(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 5),
          Text("รายละเอียด: ${service['description'] ?? "ไม่มีข้อมูล"}",
              style:
                  GoogleFonts.notoSansThai(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: _confirmBooking,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
        ),
        child: Center(
          child: Text("ยืนยันการเดินทาง",
              style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
