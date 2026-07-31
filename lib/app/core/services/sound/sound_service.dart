import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:vitta/app/core/services/sound/sound_cue.dart';

class SoundService {
  SoundService({AudioPlayer? player}) : _player = player ?? AudioPlayer(playerId: 'vitta.cues');

  final AudioPlayer _player;

  bool _isConfigured = false;

  void play(SoundCue cue) => _play(cue).ignore();

  Future<void> _play(SoundCue cue) async {
    await _configure();
    await _player.stop();
    await _player.play(AssetSource(cue.assetPath));
  }

  Future<void> _configure() async {
    if (_isConfigured) {
      return;
    }
    _isConfigured = true;
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(contentType: .sonification, usageType: .alarm, audioFocus: .gainTransientMayDuck),
        iOS: AudioContextIOS(options: const {AVAudioSessionOptions.mixWithOthers, AVAudioSessionOptions.duckOthers}),
      ),
    );
    await _player.setReleaseMode(.stop);
  }
}
