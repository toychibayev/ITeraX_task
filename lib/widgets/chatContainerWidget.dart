// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_ap/widgets/YoutubeVideoContainer.dart';

class ChatContainerWidget extends StatelessWidget {
  const ChatContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(15.r),
      ),
      width: 360.w,
      height: 515.h,
      child: Column(children: [YoutubeVideoContainer()]),
    );
  }
}
