import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import '../controllers/home_controller.dart';
import '../controllers/auth_controller.dart';
import '../views/map_picker_view.dart';

class ParcelBookingView extends StatefulWidget {
  @override
  _ParcelBookingViewState createState() => _ParcelBookingViewState();
}

class _ParcelBookingViewState extends State<ParcelBookingView> {
  final HomeController homeController = Get.find();
  final AuthController authController = Get.find();
  final service = Get.arguments;

  late String selectedVehicle;
  late String selectedDeliveryType;
  double calculatedPrice = 0.0;
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  String pickupAddress = "เลือกสถานที่รับสินค้า";
  String dropoffAddress = "เลือกสถานที่ปลายทาง";
  double distanceKm = 0.0;
  bool isCalculating = false;

  @override
  void initState() {
    super.initState();
    selectedVehicle = service['name'];
    selectedDeliveryType = "standard";
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
      totalPrice += distanceKm * 8.0;
    } else if (distanceKm <= 10) {
      totalPrice += (5 * 8.0) + ((distanceKm - 5) * 5.5);
    } else if (distanceKm <= 20) {
      totalPrice += (5 * 8.0) + (5 * 5.5) + ((distanceKm - 10) * 9.0);
    } else if (distanceKm <= 30) {
      totalPrice +=
          (5 * 8.0) + (5 * 5.5) + (10 * 9.0) + ((distanceKm - 20) * 8.5);
    } else {
      totalPrice += (5 * 8.0) +
          (5 * 5.5) +
          (10 * 9.0) +
          (10 * 8.5) +
          ((distanceKm - 30) * 15.0);
    }

    setState(() {
      calculatedPrice = totalPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            Text("ยืนยันการขนส่งพัสดุ", style: TextStyle(color: Colors.black)),
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
            _buildLocationPicker("สถานที่รับสินค้า", pickupLocation,
                (LatLng loc) {
              setState(() {
                pickupLocation = loc;
              });
              _calculateRoadDistance();
            }, pickupAddress),
            _buildLocationPicker("สถานที่ปลายทาง", dropoffLocation,
                (LatLng loc) {
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

  Widget _buildLocationPicker(String title, LatLng? location,
      Function(LatLng) onSelected, String address) {
    return GestureDetector(
      onTap: () async {
        LatLng? result = await Get.to(() => MapPickerView());
        if (result != null) {
          onSelected(result);

          String newAddress = await _getAddressFromLatLng(result);

          setState(() {
            if (title.contains("รับสินค้า")) {
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
          Text("น้ำหนักสูงสุด: ${service['max_weight'] ?? "N/A"} กก.",
              style:
                  GoogleFonts.notoSansThai(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 5),
          Text(service['description'] ?? "ไม่มีคำอธิบาย",
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
          child: Text("ยืนยันการขนส่งพัสดุ",
              style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _confirmBooking() {
    if (pickupLocation == null || dropoffLocation == null) {
      Get.snackbar("ข้อผิดพลาด", "กรุณาเลือกสถานที่รับและปลายทางก่อน");
      return;
    }

    homeController.createParcelOrder({
      "service_id": service['id'],
      "sender_name": authController.currentUser['username'],
      "pickup_location":
          "${pickupLocation!.latitude},${pickupLocation!.longitude}",
      "dropoff_location":
          "${dropoffLocation!.latitude},${dropoffLocation!.longitude}",
      "distance_km": distanceKm,
      "total_price": calculatedPrice,
      "vehicle_type": selectedVehicle,
      "delivery_type": selectedDeliveryType,
    });

    Get.snackbar("สำเร็จ", "การจองขนส่งพัสดุเสร็จสมบูรณ์");
    Get.offAllNamed('/home');
  }
}
