import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class VTTextStyles {
  static TextStyle display(BuildContext context) =>
      GoogleFonts.archivo(fontSize: 34, fontWeight: .w800, height: 1.05, letterSpacing: -1, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle headline(BuildContext context) =>
      GoogleFonts.archivo(fontSize: 24, fontWeight: .w800, height: 1.15, letterSpacing: -0.5, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle title(BuildContext context) =>
      GoogleFonts.archivo(fontSize: 18, fontWeight: .w800, height: 1.2, letterSpacing: -0.2, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle body(BuildContext context) =>
      GoogleFonts.archivo(fontSize: 15, fontWeight: .w400, height: 1.45, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle bodyStrong(BuildContext context) =>
      GoogleFonts.archivo(fontSize: 15, fontWeight: .w700, height: 1.45, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle caption(BuildContext context) =>
      GoogleFonts.archivo(fontSize: 13, fontWeight: .w500, height: 1.3, color: Theme.of(context).colorScheme.onSurfaceVariant);

  static TextStyle overline(BuildContext context) =>
      GoogleFonts.archivo(fontSize: 11, fontWeight: .w600, height: 1.3, letterSpacing: 0.4, color: Theme.of(context).colorScheme.onSurfaceVariant);
}
