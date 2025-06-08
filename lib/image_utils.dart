import 'dart:typed_data';
import 'package:image/image.dart' as img;

Float32List convertToFloat32Grayscale(Uint8List imageBytes) {
  final img.Image original = img.decodeImage(imageBytes)!;
  final img.Image gray = img.grayscale(original);
  final img.Image resized = img.copyResize(gray, width: 128, height: 128);

  final Float32List buffer = Float32List(128 * 128);
  for (int y = 0; y < 128; y++) {
    for (int x = 0; x < 128; x++) {
      final pixel = resized.getPixel(x, y);
      final luminance = img.getLuminance(pixel) / 255.0;
      buffer[y * 128 + x] = luminance;
    }
  }

  return buffer;
}
