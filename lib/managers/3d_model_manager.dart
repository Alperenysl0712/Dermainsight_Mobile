import 'dart:convert';

import 'package:flutter/services.dart';

class ThreeDModelManager {
  static Map<String, List<String>> getModelData() {
    return {
      "Ense (Kafa)": [
        "assets/img/ense.png",      // Thumbnail
        kafaBase64,                 // GLB file name only
        "ense",                     // Material name
      ],
      "Sol Yanak (Kafa)": [
        "assets/img/sol_yanak.png",
        kafaBase64,
        "yanakSol",
      ],
      "Sağ Yanak (Kafa)": [
        "assets/img/sag_yanak.png",
        kafaBase64,
        "yanakSag",
      ],
      "El (Kol)": [
        "assets/img/el.png",
        kolBase64,
        "handUpper",
      ],
      "Omuz (Kol)": [
        "assets/img/omuz.png",
        kolBase64,
        "armUpper",
      ],
      "Baldır (Bacak)": [
        "assets/img/bacak.png",
        bacakBase64,
        "legUpper",
      ],
      "Ayak (Bacak)": [
        "assets/img/ayak.png",
        bacakBase64,
        "feetUpper",
      ],
    };
  }

  static String kafaBase64 = "";
  static String kolBase64 = "";
  static String bacakBase64 = "";

  static Future<void> loadBase64Models() async {
    kafaBase64 = await _loadAssetAsBase64('assets/webgl/kafa.glb');
    kolBase64 = await _loadAssetAsBase64('assets/webgl/kol.glb');
    bacakBase64 = await _loadAssetAsBase64('assets/webgl/bacak.glb');
  }

  static Future<String> _loadAssetAsBase64(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final list = bytes.buffer.asUint8List();
    return base64Encode(list);
  }
}
