// A figure dash for the minus sign, and an explicit + for a rise: the direction
// is never carried by colour on this page, so the sign and the arrow beside it
// are what make it readable.
String signedChangePercent(double changeRatio) {
  final changePercent = ((changeRatio - 1) * 100).round();
  if (changePercent == 0) {
    return '0%';
  }
  return '${changePercent < 0 ? '−' : '+'}${changePercent.abs()}%';
}
