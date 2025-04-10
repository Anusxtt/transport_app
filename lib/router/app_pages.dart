import 'package:get/get.dart';
import 'package:transport_app/views/ParcelBookingView.dart';
import 'package:transport_app/views/PassengerBookingView.dart';
import '../views/consolidationView.dart';
import '../views/trackingView.dart';
import '../views/booking_view.dart';
import '../views/profileView.dart';
import '../views/notificationView.dart';
import '../views/homeView.dart';
import '../views/loginView.dart';
import '../views/mapView.dart';
import '../views/registerView.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => HomeView(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(),
    ),
    GetPage(
      name: Routes.map,
      page: () => MapView(),
    ),
    GetPage(
      name: Routes.notification,
      page: () => NotificationView(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => ProfileView(),
    ),
    GetPage(
      name: Routes.parcelbooking,
      page: () => ParcelBookingView(),
    ),
    GetPage(
      name: Routes.tracking,
      page: () => TrackingView(),
    ),
    GetPage(
      name: Routes.consolidation,
      page: () => ConsolidationView(),
    ),
    GetPage(
      name: Routes.passengerbooking,
      page: () => PassengerBookingView(),
    ),
  ];
}
