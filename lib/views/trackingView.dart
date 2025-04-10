import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackingView extends StatelessWidget {
  final order = Get.arguments; // รับข้อมูลออเดอร์ที่เพิ่งสร้าง

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ติดตามการขนส่ง")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("ข้อมูลคนขับ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("ชื่อ: ${order['driver']['name']}"),
            Text("เบอร์โทร: ${order['driver']['phone']}"),
            Text("ทะเบียนรถ: ${order['driver']['vehicle_number']}"),
            ElevatedButton(onPressed: () {}, child: Text("โทรหาคนขับ")),
            ElevatedButton(onPressed: () {}, child: Text("แชทกับคนขับ")),
          ],
        ),
      ),
    );
  }
}
