import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final LatLng initialPosition = LatLng(13.7563, 100.5018); // กรุงเทพฯ
  final WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse('wss://your-backend.com/realtime'));

  LatLng vehiclePosition = LatLng(13.7563, 100.5018); // ตำแหน่งเริ่มต้นรถขนส่ง
  String deliveryStatus = "รับสินค้าแล้ว";

  @override
  void initState() {
    super.initState();
    _listenToWebSocket();
  }

  void _listenToWebSocket() {
    channel.stream.listen((message) {
      // แปลงข้อความ JSON -> อัปเดตตำแหน่งรถขนส่ง
      var data = message as Map<String, dynamic>;
      setState(() {
        vehiclePosition = LatLng(data['lat'], data['lng']);
        deliveryStatus = data['status'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // **แผนที่**
          FlutterMap(
            options: MapOptions(
              initialCenter: initialPosition,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  // ตำแหน่งรถขนส่งแบบเรียลไทม์
                  Marker(
                    point: vehiclePosition,
                    width: 50.0,
                    height: 50.0,
                    child:
                        Icon(Icons.local_shipping, color: Colors.red, size: 50),
                  ),
                  // จุดหมายปลายทาง
                  Marker(
                    point: LatLng(13.7623, 100.5048), // เปลี่ยนเป็นตำแหน่งจริง
                    width: 50.0,
                    height: 50.0,
                    child:
                        Icon(Icons.location_on, color: Colors.blue, size: 50),
                  ),
                ],
              ),
            ],
          ),

          // **Header: Title & Profile**
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "แผนที่",
                  style: GoogleFonts.notoSansThai(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.jpg'),
                  radius: 20,
                ),
              ],
            ),
          ),

          // **การ์ดแสดงสถานะ**
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "แสดงการจัดส่งแบบเรียลไทม์",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStatusItem(
                      "📦 รับสินค้าแล้ว", deliveryStatus == "รับสินค้าแล้ว"),
                  _buildStatusItem(
                      "🚛 กำลังขนส่ง", deliveryStatus == "กำลังขนส่ง"),
                  _buildStatusItem(
                      "📍 ใกล้ถึงที่หมาย", deliveryStatus == "ใกล้ถึงที่หมาย"),
                  _buildStatusItem("✅ จัดส่งเรียบร้อยแล้ว",
                      deliveryStatus == "จัดส่งเรียบร้อยแล้ว"),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // **สถานะการขนส่ง**
  Widget _buildStatusItem(String status, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        status,
        style: GoogleFonts.notoSansThai(
          fontSize: 16,
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // **Navigation Bar**
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 2, // ✅ index 2 -> แผนที่
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Get.toNamed('/home');
            break;
          case 1:
            Get.toNamed('/consolidation');
            break;
          case 2:
            Get.toNamed('/map'); // ✅ คงอยู่ที่หน้าแผนที่
            break;
          case 3:
            Get.toNamed('/notification');
            break;
          case 4:
            Get.toNamed('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าแรก"),
        BottomNavigationBarItem(
            icon: Icon(Icons.group), label: "Consolidation"),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "แผนที่"),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: "แจ้งเตือน"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "บัญชี"),
      ],
    );
  }
}
