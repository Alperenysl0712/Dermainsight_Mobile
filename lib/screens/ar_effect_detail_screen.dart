import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';



class ArEffectDetailScreen extends StatefulWidget{
  final String base64;
  const ArEffectDetailScreen({required this.base64, super.key});

  @override
  State<ArEffectDetailScreen> createState() => _ArEffectDetailScreenState();
}

class _ArEffectDetailScreenState extends State<ArEffectDetailScreen> {

  late CameraController _controller;
  bool _isCameraInitialized = false;


  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera(); // 🔥 kamera başlat
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kamera izni verilmedi!")),
      );
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Uint8List decodeBase64Image(String base64String){
    return base64Decode(base64String.split(',').last);
  }


  @override
  Widget build(BuildContext context) {
    final overlayImage = decodeBase64Image(widget.base64);

    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: CameraPreview(_controller),
          ), // 📷 Kamera
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Opacity(
              opacity: 1.0,
              child: Image.memory(
                overlayImage,
                width: 200,
                height: 200,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          )
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }

}

