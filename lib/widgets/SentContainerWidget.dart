// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_ap/screens/alFatihaPage.dart';

class SentContainerWidget extends StatelessWidget {
  final Function(String)? onRecordingComplete;

  const SentContainerWidget({super.key, this.onRecordingComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(15.r),
      ),
      width: 345.w,
      height: 55.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Qiroatni tekshirish...",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const Alfatihapage()),
              );

              if (result != null && onRecordingComplete != null) {
                onRecordingComplete!(result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
              elevation: 0,
            ),
            child: Row(
              children: [
                Text(
                  "Qiroat qilish",
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
                SizedBox(width: 4.w),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
