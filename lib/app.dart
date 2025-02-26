import 'package:carebud/routes/router.dart';
import 'package:carebud/routes/routes.dart';
import 'package:carebud/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Your design's screen width and height
      minTextAdapt: true, // Optional, helps to adjust text sizes
      builder: (context, child) {
        return GetMaterialApp(
          theme: lightTheme, // Apply the light theme
          darkTheme: darkTheme, // Apply the dark theme
          themeMode: ThemeMode.system, // Switch themes based on system settings
          initialRoute: AppRoutes.adminnavbar, // Initial route
          getPages: AppRouter.routes, // Centralized route management
          defaultTransition: Transition.native,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}