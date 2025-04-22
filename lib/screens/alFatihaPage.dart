// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

// Aliased imports
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:audio_waveforms/audio_waveforms.dart' as aw;

import 'package:quran_ap/widgets/customContainerWidgets.dart';
import 'package:quran_ap/widgets/imageWidget.dart';

class Alfatihapage extends StatefulWidget {
  const Alfatihapage({super.key});

  @override
  State<Alfatihapage> createState() => _AlfatihapageState();
}

class _AlfatihapageState extends State<Alfatihapage>
    with SingleTickerProviderStateMixin {
  final fs.FlutterSoundRecorder _recorder = fs.FlutterSoundRecorder();
  final ap.AudioPlayer _player = ap.AudioPlayer();
  late aw.PlayerController _playerController;

  String? _filePath;
  bool isRecording = false;
  bool isPlaying = false;
  bool isPaused = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _recordDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _playerController = aw.PlayerController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, mikrofon uchun ruxsat bering")),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/fatiha_qiroat_$timestamp.aac';
    _filePath = path;

    await _recorder.startRecorder(toFile: path, codec: fs.Codec.aacADTS);

    _animationController.repeat(reverse: true);
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration++);
    });

    setState(() => isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _animationController.stop();
    _timer?.cancel();
    _timer = null;

    if (_recordDuration < 10) {
      setState(() {
        isRecording = false;
        _filePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Iltimos, kamida 10 soniya davomida qiroat qiling."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _loadWaveform();

    setState(() => isRecording = false);
  }

  Future<void> _loadWaveform() async {
    if (_filePath != null && File(_filePath!).existsSync()) {
      _playerController.dispose();
      _playerController = aw.PlayerController();
      await _playerController.preparePlayer(path: _filePath!);

      _playerController.onPlayerStateChanged.listen((state) {
        setState(() {
          if (state == aw.PlayerState.stopped) {
            isPlaying = false;
            isPaused = false;
          } else if (state == aw.PlayerState.playing) {
            isPlaying = true;
            isPaused = false;
          } else if (state == aw.PlayerState.paused) {
            isPlaying = false;
            isPaused = true;
          }
        });
      });

      setState(() {});
    }
  }

  Future<void> _playRecording() async {
    if (_filePath == null || !File(_filePath!).existsSync()) return;

    if (isPlaying) {
      await _playerController.pausePlayer();
      setState(() {
        isPlaying = false;
        isPaused = true;
      });
    } else if (isPaused) {
      await _playerController.startPlayer();
      setState(() {
        isPlaying = true;
        isPaused = false;
      });
    } else {
      await _playerController.startPlayer();
      setState(() {
        isPlaying = true;
        isPaused = false;
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.dispose();
    _animationController.dispose();
    _timer?.cancel();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            CustomContainerWidgets(text: "Fotiha surasini qiroat qilish"),
            ImageWidget(),
            if (!isRecording && _filePath == null) ...[
              Text(
                "Qiroatni yozib yuborish uchun quyidagi tugmani 1 marta bosing",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "Qiroatni 10dan 120 sekundgacha yuboring",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
            ],
            if (isRecording || (_filePath == null))
              ScaleTransition(
                scale:
                    isRecording ? _scaleAnimation : AlwaysStoppedAnimation(1.0),
                child: IconButton(
                  icon: Icon(
                    isRecording ? Icons.stop_circle : Icons.mic,
                    color: Colors.green,
                    size: 64.sp,
                  ),
                  onPressed: () {
                    if (isRecording) {
                      _stopRecording();
                    } else {
                      _startRecording();
                    }
                  },
                ),
              ),
            if (isRecording)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  "$_recordDuration",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            if (_filePath != null && !isRecording) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: aw.AudioFileWaveforms(
                  size: Size(double.infinity, 50.h),
                  playerController: _playerController,
                  playerWaveStyle: const aw.PlayerWaveStyle(
                    fixedWaveColor: Color(0xFFBAC2E2),
                    showSeekLine: true,
                  ),
                  enableSeekGesture: false,
                  waveformType: aw.WaveformType.long,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause
                            : (isPaused ? Icons.play_arrow : Icons.play_arrow),
                        color: Colors.green,
                      ),
                      onPressed: _playRecording,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_filePath != null &&
                            File(_filePath!).existsSync()) {
                          Navigator.pop(context, _filePath);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: const Text("Yuborish"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _filePath = null;
                          _recordDuration = 0;
                          isPlaying = false;
                          isPaused = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
