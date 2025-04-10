import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';

class BookingView extends StatefulWidget {
  @override
  _BookingViewState createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final HomeController homeController = Get.find();
  final TextEditingController senderController = TextEditingController();
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();

  final service = Get.arguments;
  late String selectedVehicle;
  late String selectedDeliveryType;

  @override
  void initState() {
    super.initState();
    selectedVehicle = service['name'];
    selectedDeliveryType = "standard";
  }

  void _confirmBooking() {
    homeController.createOrder({
      "service_id": service['id'],
      "sender_name": senderController.text,
      "receiver_name": receiverController.text,
      "pickup_location": pickupController.text,
      "dropoff_location": dropoffController.text,
      "vehicle_type": selectedVehicle,
      "delivery_type": selectedDeliveryType,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "ยืนยันการขนส่ง",
          style: GoogleFonts.notoSansThai(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("รายละเอียดขนส่ง"),
            const SizedBox(height: 16),
            _buildTextField(senderController, "ชื่อผู้ส่ง"),
            _buildTextField(receiverController, "ชื่อผู้รับ"),
            _buildTextField(pickupController, "สถานที่รับสินค้า"),
            _buildTextField(dropoffController, "สถานที่ปลายทาง"),
            const SizedBox(height: 16),
            _buildTitle("เลือกประเภทรถ"),
            _buildDropdown([selectedVehicle], (value) {
              setState(() {
                selectedVehicle = value!;
              });
            }),
            const SizedBox(height: 16),
            _buildTitle("เลือกประเภทการส่ง"),
            _buildDropdown(["standard", "express", "economy"], (value) {
              setState(() {
                selectedDeliveryType = value!;
              });
            }),
            const SizedBox(height: 20),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style:
          GoogleFonts.notoSansThai(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> options, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: options.first,
        isExpanded: true,
        underline: SizedBox(),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
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
          child: Text("ยืนยันการขนส่ง",
              style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
