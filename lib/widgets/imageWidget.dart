import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/imgs/rasm.png",
      width: 343.w,
      height: 460.h,
      fit: BoxFit.fill,
    );
  }
}
