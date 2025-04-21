import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CutsomText extends StatefulWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;

  const CutsomText({
    super.key,
    required this.text,
    this.size,
    this.color, this.weight,
  });

  @override
  State<CutsomText> createState() => CutsomTextState();
}

class CutsomTextState extends State<CutsomText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
        fontFamily: "Montserrat",
        color: widget.color,
        fontWeight: widget.weight ?? FontWeight.w700,
        fontSize: widget.size ?? 18.sp,
      ),
    );
  }
}
