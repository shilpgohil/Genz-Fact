import 'dart:typed_data';
import 'dart:ui' as ui;

import 'duplicate_engine.dart';

Future<int?> perceptualHashFromBytes(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 36,
      targetHeight: 32,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final width = image.width;
    final height = image.height;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    if (data == null || width == 0 || height == 0) return null;
    return dHashFromRgba(data.buffer.asUint8List(), width, height);
  } catch (_) {
    return null;
  }
}
