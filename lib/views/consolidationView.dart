import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/consolidation_controller.dart';

class ConsolidationView extends StatefulWidget {
  @override
  _ConsolidationViewState createState() => _ConsolidationViewState();
}

class _ConsolidationViewState extends State<ConsolidationView> {
  final ConsolidationController consolidationController =
      Get.put(ConsolidationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Consolidation",
          style: GoogleFonts.notoSansThai(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () => consolidationController.fetchConsolidations(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (consolidationController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (consolidationController.consolidations.isEmpty) {
            return Center(child: Text("ไม่มีข้อมูล Consolidation"));
          }

          return ListView.builder(
            itemCount: consolidationController.consolidations.length,
            itemBuilder: (context, index) {
              var consolidation = consolidationController.consolidations[index];
              return _buildConsolidationCard(consolidation);
            },
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildConsolidationCard(dynamic consolidation) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed('/consolidation-detail', arguments: consolidation),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 จังหวัด: ${consolidation['province']}",
                style: GoogleFonts.notoSansThai(
                    fontSize: 16, color: Colors.white)),
            Text("🏙 เมือง: ${consolidation['city']}",
                style: GoogleFonts.notoSansThai(
                    fontSize: 16, color: Colors.white)),
            Text("📌 สถานที่ใกล้เคียง: ${consolidation['nearby']}",
                style: GoogleFonts.notoSansThai(
                    fontSize: 16, color: Colors.white)),
            Text("💰 ราคา: ${consolidation['price']} บาท",
                style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text("👥 จำนวนที่เข้าร่วม: ${consolidation['people']} คน",
                style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 1,
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
