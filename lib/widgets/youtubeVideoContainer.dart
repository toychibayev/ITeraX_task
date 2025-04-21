// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_ap/utils/app_text.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoContainer extends StatefulWidget {
  const YoutubeVideoContainer({super.key});

  @override
  State<YoutubeVideoContainer> createState() => _YoutubeVideoContainerState();
}

class _YoutubeVideoContainerState extends State<YoutubeVideoContainer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'PLHddf-1MHY', // YouTube video ID
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, right: 20),
      padding: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(5.r),
      ),
      width: 300.w,
      height: 180.h,
      child: Column(
        children: [
          YoutubePlayer(
            width: 280,
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
          ),
          SizedBox(
            width: 280,
            child: CutsomText(
              text: "Fotiha surasida yo'l qo'yilishi mumkin bo'lgan xatolar",
              size: 14.sp,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
