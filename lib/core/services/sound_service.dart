import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Offline audio service for tactile click sounds using [AudioPlayer] with native [SystemSound] fallback.
class SoundService {
  SoundService._internal();

  static final SoundService instance = SoundService._internal();

  AudioPlayer? _player;
  bool _isInitialized = false;

  /// Initializes the local [AudioPlayer] instance.
  void initialize() {
    if (_isInitialized) return;
    try {
      _player = AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (_) {
      // SystemSound fallback available if audioplayers fails to initialize
    }
  }

  /// Plays the subtle tactile click sound asset.
  Future<void> playClickSound() async {
    try {
      if (_player != null) {
        await _player?.stop();
        await _player?.play(AssetSource('audio/click.wav'), volume: 0.6);
      } else {
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {
      // Graceful fallback to native system click
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Releases audio player resources.
  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {}
    _player = null;
    _isInitialized = false;
  }
}
