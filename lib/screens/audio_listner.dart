import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:socket/app_constants.dart';
import 'package:socket/screens/wave_painter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;


class AudioListener extends StatefulWidget {
  @override
  _AudioListenerState createState() => _AudioListenerState();
}

class _AudioListenerState extends State<AudioListener> {
  io.Socket? socket;
  AudioPlayer _audioPlayer = AudioPlayer();
  List<int> _audioBuffer = [];
  List<double> _waveformData = [];
  double _maxAmplitude = 1.0;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  Future<void> _initSocket() async {
    try {
      socket = io.io(AppConstants.kHost, <String, dynamic>{
        'transports': ['websocket'],
      });

      socket?.on('connect', (_) {
        print('Connected to server');
        _startListening();
      });

      socket?.on('audio-chunk', (data) {
        _playAudioChunk(data);
        _updateWaveform(data);
      });
    } catch (err) {
      print('Failed to connect to server: $err');
    }
  }

  void _startListening() {
    print('Start listening');
    // You can add any additional setup logic here before starting to listen
  }

  Future<void> _playAudioChunk(String chunk) async {
    try {
      Uint8List audioData = base64Decode(chunk);

      // Print received audio chunk details
      print('Received audio chunk details: Size=${audioData.length}, Format=WAV');

      // Print buffer size before adding audio data
      print('Buffer size before adding audio data: ${_audioBuffer.length}');

      // Add audio data to the buffer
      _audioBuffer.addAll(audioData);

      // Print buffer size after adding audio data
      print('Buffer size after adding audio data: ${_audioBuffer.length}');

      if (_audioBuffer.length > 1024) {
        // If buffer size exceeds threshold, prepare and play audio
        Uint8List wavData = addWavHeader(_audioBuffer);
        Source audioSource = BytesSource(wavData, mimeType: 'audio/wav');

        // Print playback status before playing audio chunk
        print('Playback status before playing audio chunk: ${_audioPlayer.state}');

        // Play audio chunk
        _audioPlayer.play(audioSource, volume: 1.0);

        // Clear audio buffer after playback
        _audioBuffer.clear();

        // Print playback status after playing audio chunk
        print('Playback status after playing audio chunk: ${_audioPlayer.state}');
      }
    } catch (err, stackTrace) {
      // Print error details and stack trace
      print('Failed to play audio chunk: $err');
      print('Stack trace: $stackTrace');
    }
  }

  void _updateWaveform(String chunk) {
    Uint8List audioData = base64Decode(chunk);
    List<double> newData = audioData.map((e) => e.toDouble()).toList();
    setState(() {
      _waveformData = newData;
      _maxAmplitude = newData.reduce((a, b) => a > b ? a : b).abs();
    });
  }



  Uint8List addWavHeader(List<int> bytes) {
    int sampleRate = 16000;
    int byteRate = sampleRate * 2;
    int blockAlign = 2;

    var header = ByteData(44);
    header.setUint32(0, 0x46464952, Endian.little); // "RIFF"
    header.setUint32(4, bytes.length + 36, Endian.little); // file size
    header.setUint32(8, 0x45564157, Endian.little); // "WAVE"
    header.setUint32(12, 0x20746D66, Endian.little); // "fmt "
    header.setUint32(16, 16, Endian.little); // PCM chunk size
    header.setUint16(20, 1, Endian.little); // format type
    header.setUint16(22, 1, Endian.little); // channels
    header.setUint32(24, sampleRate, Endian.little); // sample rate
    header.setUint32(28, byteRate, Endian.little); // byte rate
    header.setUint16(32, blockAlign, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample
    header.setUint32(36, 0x61746164, Endian.little); // "data"
    header.setUint32(40, bytes.length, Endian.little); // data size

    var buffer = BytesBuilder();
    buffer.add(header.buffer.asUint8List());
    buffer.add(Uint8List.fromList(bytes));
    return buffer.toBytes();
  }

  @override
  void dispose() {
    socket?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Listener')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Listening to audio stream...'),
            SizedBox(height: 20),
            CustomPaint(
              size: Size(double.infinity, 400),
              painter: WaveformPainter(
                amplitudes: _waveformData,
                maxAmplitude: _maxAmplitude,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
