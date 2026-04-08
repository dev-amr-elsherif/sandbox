import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() async {
  // السطر ده مهم جداً عشان نتأكد إن الفلاتر جاهز قبل ما نعمل أي إعدادات خارجية زي فايربيز
  WidgetsFlutterBinding.ensureInitialized();

  // مكان محجوز لتعريف Firebase بعدين
  // await Firebase.initializeApp();

  runApp(const DevSyncApp());
}

class DevSyncApp extends StatelessWidget {
  const DevSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DevSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // ربط الخريطة اللي عملناها بالابلكيشن
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // حركة انتقال افتراضية ناعمة بين الشاشات
      defaultTransition: Transition.cupertino,
    );
  }
}
