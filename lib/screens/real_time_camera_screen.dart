import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:dermainsight/base_navigator.dart';
import 'package:dermainsight/managers/error_manager.dart';
import 'package:dermainsight/screens/ai_screen.dart';
import 'package:flutter/material.dart';
import '../model_service.dart'; // 📦 Görsel dönüştürücü


class RealTimeCameraScreen extends StatefulWidget {
  const RealTimeCameraScreen({super.key});

  @override
  State<RealTimeCameraScreen> createState() => _RealTimeCameraScreenState();
}

class _RealTimeCameraScreenState extends State<RealTimeCameraScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool isProcessing = false;
  String errMessage = "";
  FlashMode _flashMode = FlashMode.off;


  final modelService = ModelService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    modelService.loadModel(); // ✅ PyTorch modeli yükle
  }

  Future<void> _toggleFlash() async {
    if (!_cameraController.value.isInitialized) return;

    FlashMode newMode =
    _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;

    await _cameraController.setFlashMode(newMode);

    setState(() {
      _flashMode = newMode;
    });
  }


  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();

    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _processCapture() async {
    if (isProcessing || !_cameraController.value.isInitialized) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final XFile file = await _cameraController.takePicture();
      final Uint8List bytes = await file.readAsBytes();
      final result = await modelService.predict(bytes);

      if (result != null && result.isNotEmpty) {
        final similarity = result[0];
        log("📊 Benzerlik skoru: $similarity");
        double percentSimilarity = (100 - (similarity * 100)).toDouble();
        percentSimilarity = double.parse(percentSimilarity.toStringAsFixed(2));


        if (similarity < 0.40) {
          _showResultDialog("✅ Hastalık benzerliği tespit edildi\n📊 Skor: %$percentSimilarity", 0);
          File capturedFile = File(file.path);
          setState(() {
            errMessage = "";
            BaseNavigator.pushReplacement(context, AiScreen(selectedImage: capturedFile,), "/aiScreen");
          });
        } else {
          _showResultDialog("❌ Hastalık benzerliği bulunamadı. (📊 Skor: %$percentSimilarity)\nTekrar deneyiniz.", 1);
        }
      } else {
        _showResultDialog("⚠️ Modelden sonuç alınamadı. Tekrar deneyiniz.", 1);
      }

    } catch (e) {
      _showResultDialog("⚠️ Hata oluştu: $e", 2);
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showResultDialog(String message, int status) {
    log("Real Time Camera/\n$message");

    if(status == 1){
      setState(() {
        errMessage = message;
      });
    }

    if(status == 2){
      ErrorManager.showMessage(
        context: context,
        title: "Kamera Durumu",
        message: message,
        status: 0
      );
    }

  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? GestureDetector(
        onTap: _processCapture,
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: CameraPreview(_cameraController),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: Icon(
                  _flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _toggleFlash,
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "👆 Görüntü yakalamak için dokunun",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            if(errMessage != "")
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                    errMessage,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
