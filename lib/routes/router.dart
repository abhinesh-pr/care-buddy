import 'package:carebud/views/admin/caretaker.dart';
import 'package:get/get.dart';
import '../views/admin/admi_nav_bar.dart';
import '../views/admin/admin_dashboard.dart';
import '../views/auth.dart';
import 'routes.dart';

class AppRouter {
  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.auth, page: () => AuthPage()),
    GetPage(name: AppRoutes.admindash, page: () => AdminDash()),
    GetPage(name: AppRoutes.admincaretaker, page: () => AdminCareTaker()),
    GetPage(name: AppRoutes.adminnavbar, page: () => AdminNavBar()),
  ];
}