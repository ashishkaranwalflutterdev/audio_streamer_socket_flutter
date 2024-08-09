import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket/app_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class AudioStreamer extends StatefulWidget {
  const AudioStreamer({super.key});

  @override
  _AudioStreamerState createState() => _AudioStreamerState();
}

class _AudioStreamerState extends State<AudioStreamer> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  io.Socket? socket;
  final StreamController<Food> _audioStreamController = StreamController<Food>();

  List<double> _waveformData = [];
  double _maxAmplitude = 1.0;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _initAudioRecorder();
  }

  Future<void> _initSocket() async {
    try {
      socket = io.io(AppConstants.kHost, <String, dynamic>{
        'transports': ['websocket'],
      });
      socket?.on('connect', (_) {
        print('Connected to server');
      });
    } catch (err) {
      print('Failed to connect to server: $err');
    }
  }

  Future<void> _initAudioRecorder() async {
    await _audioRecorder.openAudioSession();
    _audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        isRecording = true;
      });

      await _audioRecorder.startRecorder(
        codec: Codec.pcm16,
        sampleRate: 16000,
        bitRate: (16000 * 1 * 2),
        toStream: _audioStreamController.sink,
      );

      _audioStreamController.stream.listen((buffer) {
        if (buffer is FoodData) {
          Uint8List? audioData = buffer.data;
          if (audioData != null) {
            String base64Data = base64Encode(audioData);
            print('Sending audio chunk: ${base64Data.substring(0, 50)}...'); // Print partial data for readability
            socket?.emit('audio-chunk', base64Data);
            _updateWaveform(audioData);
          }
        }
      });

      print('Recording started');
    } catch (err) {
      print('Failed to start recording: $err');
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      isRecording = false;
    });

    try {
      await _audioRecorder.stopRecorder();
      _audioStreamController.close();
      print('Recording stopped');
    } catch (err) {
      print('Failed to stop recording: $err');
    }
  }

  void _updateWaveform(Uint8List audioData) {
    List<double> newData = audioData.buffer.asFloat32List().map((e) => e.toDouble()).toList();
    setState(() {
      _waveformData = newData;
      _maxAmplitude = newData.reduce((a, b) => a > b ? a : b).abs();
    });
  }

  @override
  void dispose() {
    _audioRecorder.closeAudioSession();
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Streamer')),
      floatingActionButton: FloatingActionButton.extended(
        shape: const StadiumBorder(),
        onPressed: () {
          !isRecording ? _startRecording() : _stopRecording();
        },
        icon: !isRecording ? const Icon(Icons.play_circle, color: Colors.white) : const Icon(Icons.stop, color: Colors.white),
        backgroundColor: !isRecording ? Colors.green : Colors.red,
        label: !isRecording ? const Text('Start', style: TextStyle(color: Colors.white)) : const Text('Stop', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: AvatarGlow(
          startDelay: const Duration(milliseconds: 1000),
          glowColor: Colors.orange,
          glowShape: BoxShape.circle,
          animate: isRecording,
          curve: Curves.fastOutSlowIn,
          child: Material(
            elevation: 8.0,
            shape: const CircleBorder(),
            color: Colors.orange,
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 40.0,
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(15.0), // Adjust the padding as needed
                  child: Image.asset(
                    'assets/mic.png',
                    fit: BoxFit.cover, // Ensure the image fits within the padding
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
