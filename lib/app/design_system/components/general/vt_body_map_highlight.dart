import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_body_part.dart';

class VTBodyMapHighlight extends Equatable {
  const VTBodyMapHighlight({required this.part, required this.color, required this.intensity});

  final VTBodyPart part;
  final Color color;
  final double intensity;

  @override
  List<Object?> get props => [part, color, intensity];
}
