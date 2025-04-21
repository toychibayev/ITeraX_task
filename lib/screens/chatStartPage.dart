// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_ap/widgets/SentContainerWidget.dart';
import 'package:quran_ap/widgets/chatContainerWidget.dart';
import 'package:quran_ap/widgets/customContainerWidgets.dart';

class Chatstartpage extends StatelessWidget {
  const Chatstartpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            CustomContainerWidgets(text: "Fotiha surasi",),
            SizedBox(height: 10.sp),
            ChatContainerWidget(),
            SizedBox(height: 10.sp),
            SentContainerWidget(),
          ],
        ),
      ),
    );
  }
}
