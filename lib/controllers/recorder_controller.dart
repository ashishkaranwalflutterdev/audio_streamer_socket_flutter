import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket/controllers/app_controller.dart';

const int tSampleRate = 44100;
typedef _Fn = void Function();

class RecorderController extends GetxController{
  FlutterSoundRecorder? mRecorder = FlutterSoundRecorder();
  RxBool mRecorderIsInited = false.obs;
  RxBool mEnableVoiceProcessing = false.obs;

  StreamSubscription? _mRecordingDataSubscription;

  AppController _appController=Get.find<AppController>();

void toggleSwitch(){
  mEnableVoiceProcessing.toggle();
  update();
}

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await mRecorder!.openAudioSession();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.allowBluetooth |
      AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
      AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

      mRecorderIsInited.value = true;
  }


  Future<IOSink> createFile() async {
    var tempDir = await getTemporaryDirectory();
    _appController.mPath.value = '${tempDir.path}/flutter_sound_example.pcm';
    var outputFile = File(_appController.mPath.value);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  // ----------------------  Here is the code to record to a Stream ------------

  Future<void> record() async {
    assert(mRecorderIsInited.value);
    var sink = await createFile();
    var recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
          if (buffer is FoodData) {
            sink.add(buffer.data!);
          }
        });
    await mRecorder!.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: tSampleRate,
    );
    update();
  }
  // --------------------- (it was very simple, wasn't it ?) -------------------

  Future<void> stopRecorder() async {
    await mRecorder!.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    //_mplaybackReady = true;
  }

  _Fn? getRecorderFn() {
    if (!mRecorderIsInited.value) {
      return null;
    }
    return mRecorder!.isStopped
        ? record
        : () {
      stopRecorder().then((value) => update());
    };
  }

  @override
  void onInit() {
    // TODO: implement onInit
    _openRecorder();
    super.onInit();
  }


  @override
  void onClose() {
    // TODO: implement onClose
    stopRecorder();
    mRecorder?.closeAudioSession();
    mRecorder = null;
    super.onClose();
  }
}