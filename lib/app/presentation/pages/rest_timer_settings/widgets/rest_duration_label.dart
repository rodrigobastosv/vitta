String restDurationLabel(Duration rest) {
  final minutes = rest.inMinutes;
  final seconds = rest.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
