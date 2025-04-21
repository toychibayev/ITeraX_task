import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_ap/screens/chatStartPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(
              0xFFF3F5F8,
            ), // to‘g‘ridan-to‘g‘ri fon rangi
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF3F5F8),
            ),
            appBarTheme: AppBarTheme(backgroundColor: const Color(0xFFF3F5F8)),
            useMaterial3: true,
          ),
          home: const Chatstartpage(),
        );
      },
    );
  }
}
