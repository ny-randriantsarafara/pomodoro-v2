import 'package:audioplayers/audioplayers.dart';
import 'sound_adapter.dart';

class AudioplayersSoundAdapter implements SoundAdapter {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> play(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {
      // Sound playback is best-effort and never blocks navigation.
    }
  }
}
