// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_ap/utils/app_text.dart';

class CustomContainerWidgets extends StatelessWidget {
  final String text;
  const CustomContainerWidgets({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(15.r),
      ),
      width: 345.w,
      height: 55.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
          CutsomText(text: text, size: 14.sp),
          Text(""),
        ],
      ),
    );
  }
}
