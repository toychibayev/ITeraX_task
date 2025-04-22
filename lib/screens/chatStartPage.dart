// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_ap/widgets/SentContainerWidget.dart';
import 'package:quran_ap/widgets/customContainerWidgets.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as aw;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:quran_ap/widgets/youtubeVideoContainer.dart';

class Chatstartpage extends StatefulWidget {
  const Chatstartpage({super.key});

  @override
  State<Chatstartpage> createState() => _ChatstartpageState();
}

class AudioRecording {
  final String filePath;
  final String timestamp;
  final aw.PlayerController controller;
  bool isPlaying;
  int duration;
  Stream<aw.PlayerState>? playerStateStream;

  AudioRecording({
    required this.filePath,
    required this.timestamp,
    required this.controller,
    this.isPlaying = false,
    this.duration = 0,
    this.playerStateStream,
  });

  Map<String, dynamic> toMap() {
    return {'filePath': filePath, 'timestamp': timestamp, 'duration': duration};
  }

  static Future<AudioRecording?> fromMap(Map<String, dynamic> map) async {
    final filePath = map['filePath'];

    if (!File(filePath).existsSync()) {
      return null;
    }

    final controller = aw.PlayerController();
    try {
      await controller.preparePlayer(path: filePath);
      final duration = map['duration'] ?? await controller.getDuration() ?? 0;

      return AudioRecording(
        filePath: filePath,
        timestamp: map['timestamp'],
        controller: controller,
        duration: duration,
      );
    } catch (e) {
      log("Error creating recording from saved data: $e");
      controller.dispose();
      return null;
    }
  }
}

class _ChatstartpageState extends State<Chatstartpage> {
  List<AudioRecording> recordings = [];
  static const String storageKey = 'saved_recordings';

  @override
  void initState() {
    super.initState();
    _loadSavedRecordings();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var recording in recordings) {
      recording.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSavedRecordings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recordingsJson = prefs.getString(storageKey);

      if (recordingsJson != null) {
        final List<dynamic> recordingsList = jsonDecode(recordingsJson);

        List<AudioRecording> loadedRecordings = [];
        for (var recordingMap in recordingsList) {
          final recording = await AudioRecording.fromMap(recordingMap);
          if (recording != null) {
            loadedRecordings.add(recording);
            // Setup listener
            recording.controller.onPlayerStateChanged.listen((state) {
              if (mounted) {
                setState(() {
                  if (state == aw.PlayerState.stopped ||
                      state == aw.PlayerState.paused) {
                    recording.isPlaying = false;
                  } else if (state == aw.PlayerState.playing) {
                    recording.isPlaying = true;
                  }
                });
              }
            });
          }
        }

        if (loadedRecordings.isNotEmpty) {
          setState(() {
            recordings = loadedRecordings;
          });
        }
      }
    } catch (e) {
      log("Error loading saved recordings: $e");
    }
  }

  Future<void> _saveRecordings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> recordingsList =
          recordings.map((recording) => recording.toMap()).toList();

      await prefs.setString(storageKey, jsonEncode(recordingsList));
    } catch (e) {
      log("Error saving recordings: $e");
    }
  }

  String _formatCurrentDateTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}, ${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year.toString().substring(2)}";
  }

  Future<void> _playRecording(int index) async {
    if (index >= recordings.length) return;

    for (int i = 0; i < recordings.length; i++) {
      if (i != index && recordings[i].isPlaying) {
        await recordings[i].controller.pausePlayer();
        setState(() {
          recordings[i].isPlaying = false;
        });
      }
    }

    final recording = recordings[index];

    if (recording.isPlaying) {
      await recording.controller.pausePlayer();
      setState(() {
        recording.isPlaying = false;
      });
    } else {
      try {
        if (!await recording.controller.isPrepared()) {
          await recording.controller.preparePlayer(path: recording.filePath);
        }

        final duration = await recording.controller.getDuration();
        final position = await recording.controller.getCurrentPosition() ?? 0;

        if (position >= duration - 500) {
          await recording.controller.seekTo(0);
        }

        // Start playback
        await recording.controller.startPlayer();

        setState(() {
          recording.isPlaying = true;
        });
      } catch (e) {
        log("Error playing recording: $e");

        try {
          recording.controller.dispose();
          final newController = aw.PlayerController();
          await newController.preparePlayer(path: recording.filePath);

          setState(() {
            recordings[index] = AudioRecording(
              filePath: recording.filePath,
              timestamp: recording.timestamp,
              controller: newController,
              duration: recording.duration,
            );
          });

          _setupPlayerStateListener(index, newController);
          await newController.startPlayer();

          setState(() {
            recordings[index].isPlaying = true;
          });
        } catch (e2) {
          log("Failed to recover player: $e2");
        }
      }
    }
  }

  void _setupPlayerStateListener(int index, aw.PlayerController controller) {
    if (index >= recordings.length) return;

    controller.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          if (state == aw.PlayerState.stopped ||
              state == aw.PlayerState.paused) {
            recordings[index].isPlaying = false;
          } else if (state == aw.PlayerState.playing) {
            recordings[index].isPlaying = true;
          }
        });
      }
    });
  }

  Future<void> _loadAudioFile(String path) async {
    if (File(path).existsSync()) {
      final controller = aw.PlayerController();

      try {
        await controller.preparePlayer(path: path);
        final duration = await controller.getDuration();
        final timestamp = _formatCurrentDateTime();

        setState(() {
          recordings.add(
            AudioRecording(
              filePath: path,
              timestamp: timestamp,
              controller: controller,
              duration: duration,
            ),
          );
        });

        _setupPlayerStateListener(recordings.length - 1, controller);

        _saveRecordings();
      } catch (e) {
        log("Error loading audio file: $e");
        controller.dispose();
      }
    }
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _deleteRecording(int index) async {
    if (index >= recordings.length) return;

    final recording = recordings[index];

    if (recording.isPlaying) {
      await recording.controller.pausePlayer();
    }

    recording.controller.dispose();

    setState(() {
      recordings.removeAt(index);
    });

    _saveRecordings();

    try {
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      log("Error deleting file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            CustomContainerWidgets(text: "Fotiha surasi"),
            SizedBox(height: 10.h),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(
                  children: [
                    // Video thumbnail with play button
                    YoutubeVideoContainer(),

                    // Audio players - show all recordings
                    if (recordings.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0; i < recordings.length; i++)
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 20.h,
                                    left: 16.w,
                                    right: 16.w,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Play button
                                          Container(
                                            width: 40.r,
                                            height: 40.r,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF3E80FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                recordings[i].isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 24.r,
                                              ),
                                              onPressed:
                                                  () => _playRecording(i),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),

                                          // Waveform
                                          Expanded(
                                            child: aw.AudioFileWaveforms(
                                              size: Size(
                                                MediaQuery.of(
                                                      context,
                                                    ).size.width -
                                                    150.w, 
                                                40.h,
                                              ),
                                              playerController:
                                                  recordings[i].controller,
                                              playerWaveStyle:
                                                  const aw.PlayerWaveStyle(
                                                    fixedWaveColor: Color(
                                                      0xFFBBDEFB,
                                                    ),
                                                    liveWaveColor: Color(
                                                      0xFF3E80FF,
                                                    ),
                                                    seekLineColor: Color(
                                                      0xFF3E80FF,
                                                    ),
                                                    showSeekLine: true,
                                                  ),
                                              enableSeekGesture: true,
                                              waveformType:
                                                  aw.WaveformType.long,
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),

                                          // Duration
                                          Text(
                                            _formatDuration(
                                              recordings[i].duration,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),

                                          // Delete button
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red[300],
                                              size: 20.r,
                                            ),
                                            onPressed:
                                                () => _deleteRecording(i),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.h,
                                          right: 4.w,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            recordings[i].timestamp,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SentContainerWidget(
              onRecordingComplete: (String path) {
                _loadAudioFile(path);
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension PlayerControllerExtension on aw.PlayerController {
  Future<int?> getCurrentPosition() async {
    try {
      return 0; 
    } catch (e) {
      return 0;
    }
  }

  Future<bool> isPrepared() async {
    try {
      final duration = await getDuration();
      return duration > 0;
    } catch (e) {
      return false;
    }
  }
}
