import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "บริการขนส่ง",
            style: GoogleFonts.notoSansThai(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black),
              onPressed: () => Get.toNamed('/notification'),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildPromoCard(),
            _buildUserOptions(),
            TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.orange,
              tabs: [
                Tab(text: "🚚 ขนส่งพัสดุ"),
                Tab(text: "🚕 ขนส่งผู้โดยสาร"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildServiceGrid(homeController.logisticsVehicles),
                  _buildServiceGrid(homeController.passengerVehicles),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
      ),
      child: Center(
        child: Text("🔥 โปรโมชั่นพิเศษ ลดค่าขนส่ง 20% 🔥",
            style: GoogleFonts.notoSansThai(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildUserOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed('/sender'),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
                ),
                child: Center(
                  child: Text("🚛 ผู้ส่ง",
                      style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed('/receiver'),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      colors: [Colors.orangeAccent, Colors.orange]),
                ),
                child: Center(
                  child: Text("🚚 ผู้รับ",
                      style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
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

  Widget _buildServiceGrid(RxList<dynamic> vehicleList) {
    return Obx(() {
      if (homeController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (vehicleList.isEmpty) {
        return Center(
            child: Text("ไม่มีข้อมูล",
                style: GoogleFonts.notoSansThai(fontSize: 16)));
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          padding: EdgeInsets.only(top: 10),
          physics: AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: vehicleList.length,
          itemBuilder: (context, index) {
            var service = vehicleList[index];
            return _buildServiceCard(service);
          },
        ),
      );
    });
  }

  Widget _buildServiceCard(dynamic service) {
    return GestureDetector(
      onTap: () {
        if (service['category'] == 'logistics') {
          Get.toNamed('/parcelbooking', arguments: service);
        } else {
          Get.toNamed('/passengerbooking', arguments: service);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                service['category'] == 'logistics'
                    ? Icons.local_shipping
                    : Icons.directions_car,
                size: 50,
                color: Colors.deepOrange),
            const SizedBox(height: 10),
            Text(service['name'],
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
