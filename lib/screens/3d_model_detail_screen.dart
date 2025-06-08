import 'dart:developer';

import 'package:dermainsight/managers/3d_model_manager.dart';
import 'package:dermainsight/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/drawer_widget.dart';

class ThreeDModelDetailScreen extends StatefulWidget {
  final String base64;
  const ThreeDModelDetailScreen({required this.base64, super.key});

  @override
  State<ThreeDModelDetailScreen> createState() => _ThreeDModelDetailScreenState();
}

class _ThreeDModelDetailScreenState extends State<ThreeDModelDetailScreen> {
  WebViewController? _controller;
  bool _pageLoaded = false;
  String? selectedRegion;
  String? selectedGlbPath;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _loadController(){
    _controller?.clearCache(); // temizle

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadFlutterAsset('assets/webgl/index.html')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            setState(() => _pageLoaded = true);

            // ⏳ Model yüklemesi
            if (selectedRegion != null && selectedGlbPath != null) {
              await Future.delayed(const Duration(milliseconds: 200));
              _sendModelData();
            }
          },
        ),
      );
  }

  void _sendModelData() {
    if (!_pageLoaded || selectedRegion == null || selectedGlbPath == null) return;

    final js = """
    setTimeout(() => {
      const container = document.getElementById('3dModelArea');
      if (container.offsetWidth > 0 && container.offsetHeight > 0) {
        window.dispatchEvent(new Event("resize"));
        setTimeout(() => {
          showModel("$selectedRegion", "$selectedGlbPath", "${widget.base64}");
        }, 200);
      } else {
        console.warn("📏 container boş. Tekrar deneniyor...");
        setTimeout(() => window.dispatchEvent(new Event("resize")), 300);
      }
    }, 300);
  """;

    _controller!.runJavaScript("""
  function tryShowModel() {
    const container = document.getElementById("3dModelArea");
    if (!container || container.offsetHeight === 0 || container.offsetWidth === 0) {
      console.log("📏 container boş. Tekrar deneniyor...");
      setTimeout(tryShowModel, 300);
      return;
    }
    showModel("$selectedRegion", "$selectedGlbPath", "${widget.base64}");
  }
  tryShowModel();
""");

  }


  void _loadModel(String region, String glbPath) {
    setState(() {
      selectedRegion = region;
      selectedGlbPath = glbPath;
    });

    if (!_pageLoaded) {
      // İlk defa yükleniyorsa WebView başlat
      _loadController();
    } else {
      // WebView zaten yüklü → model gönder
      _sendModelData();
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBarWidget(),
      body: Column(
        children: [
          _regionList(),
          if (!_pageLoaded)
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF1E1E1E),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, right: 15),
                        child: Image.asset("assets/img/blender_logo.png", width: width * 0.2),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Üst taraftan bir bölge seçiniz.",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          if (!kIsWeb && _controller != null)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final webViewHeight = constraints.maxHeight;

                  // ✅ Flutter → JS'e yükseklik gönder
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _controller!.runJavaScript(
                        'window.setContainerHeight(${webViewHeight.toInt().clamp(400, 10000)});'
                    );
                  });

                  return Container(
                    constraints: const BoxConstraints(minHeight: 400), // min 400px
                    color: const Color(0xFF1E1E1E),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: webViewHeight < 400 ? 400 : webViewHeight,
                        child: WebViewWidget(controller: _controller!),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _regionList() {
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ThreeDModelManager.getModelData().entries.map((item) {
            final key = item.key;
            final value = item.value;

            return GestureDetector(
              onTap: () {
                _loadModel(value[2], value[1]);
              },
              child: Container(
                height: double.infinity,
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Expanded(
                      child: Image.asset(
                        value[0],
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      key,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
