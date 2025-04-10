import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationView extends StatefulWidget {
  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('wss://your-backend.com/notifications'));

  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _listenToWebSocket();
  }

  void _listenToWebSocket() {
    channel.stream.listen((message) {
      setState(() {
        notifications.insert(0, message);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "การแจ้งเตือน",
          style: GoogleFonts.notoSansThai(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationItem(notifications[index]);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildNotificationItem(String notification) {
    return GestureDetector(
      onTap: () => Get.toNamed('/notification-detail', arguments: notification),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
        ),
        child: Text(
          notification,
          style: GoogleFonts.notoSansThai(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 3,
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
            Get.toNamed('/map');
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
