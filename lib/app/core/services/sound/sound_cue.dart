enum SoundCue {
  restTick('audio/rest_tick.wav'),
  restEnd('audio/rest_end.wav');

  const SoundCue(this.assetPath);

  final String assetPath;
}
