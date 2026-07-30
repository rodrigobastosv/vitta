import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_capture_boundary.dart';
import 'package:vitta/app/design_system/components/general/vt_capture_controller.dart';

void main() {
  testWidgets('hands back the wrapped subtree as PNG bytes', (tester) async {
    final captureController = VTCaptureController();
    await tester.pumpWidget(
      MaterialApp(
        home: VTCaptureBoundary(
          controller: captureController,
          child: const SizedBox(width: 40, height: 40, child: ColoredBox(color: Colors.green)),
        ),
      ),
    );

    // toImage rasterizes off the fake-async zone the test binding installs, so
    // it only ever completes inside runAsync.
    final imageBytes = await tester.runAsync(() => captureController.capture(pixelRatio: 1));

    expect(imageBytes, isNotNull);
    expect(imageBytes!.sublist(1, 4), 'PNG'.codeUnits);
  });

  testWidgets('reports nothing rather than throwing when the boundary is not in the tree', (tester) async {
    final captureController = VTCaptureController();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(await captureController.capture(), isNull);
  });
}
