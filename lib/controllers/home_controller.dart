import 'package:get/get.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();

  var isLoading = false.obs;
  var services = [].obs;
  var logisticsVehicles = [].obs;
  var passengerVehicles = [].obs;

  @override
  void onInit() {
    fetchTransportServices();
    super.onInit();
  }

  Future<void> fetchTransportServices() async {
    isLoading(true);
    try {
      final logistics = await _homeService.getLogisticsVehicles();
      final passenger = await _homeService.getPassengerVehicles();

      logisticsVehicles.assignAll(logistics);
      passengerVehicles.assignAll(passenger);
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    isLoading(true);
    try {
      final result = await _homeService.createOrder(orderData);
      if (result['success']) {
        Get.snackbar('สำเร็จ', 'สร้างออเดอร์เรียบร้อย');
        Get.toNamed('/tracking');
      } else {
        Get.snackbar('ผิดพลาด', result['message']);
      }
    } catch (e) {
      Get.snackbar('ผิดพลาด', 'ไม่สามารถสร้างออเดอร์ได้');
    } finally {
      isLoading(false);
    }
  }

  void createParcelOrder(Map<String, dynamic> orderData) {
    print("📌 Log: จองขนส่งพัสดุ -> $orderData");
  }

  void createPassengerOrder(Map<String, dynamic> orderData) {
    print("📌 Log: จองขนส่งผู้โดยสาร -> $orderData");
  }
}
