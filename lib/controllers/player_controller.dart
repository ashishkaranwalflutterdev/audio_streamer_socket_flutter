import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:socket/controllers/app_controller.dart';
import 'package:logger/logger.dart' show Level;

const int tSampleRate = 44100;
typedef _Fn = void Function();

class PlayerController extends GetxController{
  FlutterSoundPlayer? mPlayer = FlutterSoundPlayer(logLevel: Level.nothing);
  RxBool mPlayerIsInited = false.obs;
  RxBool mplaybackReady = false.obs;

  AppController _appController=Get.find<AppController>();


  @override
  void onInit() async{
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    mPlayer!.openAudioSession().then((value) {
        mPlayerIsInited.value = true;
        update();
    });

    super.onInit();
  }


  @override
  void onClose() {
    stopPlayer();

    mPlayer?.closeAudioSession();
    mPlayer = null;

    super.onClose();
  }


  void play() async {
    assert(mPlayerIsInited.value);
    await mPlayer!.startPlayer(
        fromURI: _appController.mPath.value,
        sampleRate: tSampleRate,
        codec: Codec.pcm16,
        numChannels: 1,
        whenFinished: () {
         update();
        }); // The readability of Dart is very special :-(
   update();
  }

  Future<void> stopPlayer() async {
    await mPlayer?.stopPlayer();
  }

  _Fn? getPlaybackFn() {
    if (!mPlayerIsInited.value) {
      return null;
    }
    return mPlayer!.isStopped
        ? play
        : () {
      stopPlayer().then((value) => update());
    };
  }
}