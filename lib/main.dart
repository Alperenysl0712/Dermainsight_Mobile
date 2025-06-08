import 'package:dermainsight/managers/3d_model_manager.dart';
import 'package:flutter/material.dart';
import 'package:dermainsight/screens/login_screen.dart';
import 'package:dermainsight/screens/error_screen.dart';
import 'package:dermainsight/api/fastApi.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ThreeDModelManager.loadBase64Models();
  bool isHealthy = false;
  String? errorDetails;

  try {
    isHealthy = await FastApi.checkFastApiHealth();
  } catch (e) {
    isHealthy = false;
    errorDetails = e.toString();
  }

  runApp(MyApp(
    isHealthy: isHealthy,
    errorDetails: errorDetails,
  ));
}

class MyApp extends StatelessWidget {
  final bool isHealthy;
  final String? errorDetails;

  const MyApp({required this.isHealthy, this.errorDetails, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isHealthy ? LoginScreen() : ErrorScreen(requestedPath: "/loginScreen", exceptionDetails: errorDetails ?? "",),
    );
  }
}
