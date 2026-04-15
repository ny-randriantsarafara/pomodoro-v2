abstract class SoundAdapter {
  Future<void> play(String assetPath);
}

class RecordingSoundAdapter implements SoundAdapter {
  final List<String> played = [];

  @override
  Future<void> play(String assetPath) async {
    played.add(assetPath);
  }
}

class NoOpSoundAdapter implements SoundAdapter {
  @override
  Future<void> play(String assetPath) async {}
}
