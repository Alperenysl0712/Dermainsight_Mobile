import 'package:flutter/material.dart';
import 'package:dermainsight/api/fastApi.dart';
import 'package:dermainsight/screens/error_screen.dart';

class BaseNavigator {
  static Future<void> push(BuildContext context, Widget page, String? routeName) async {
    await _navigateWithHealthCheck(
      context,
      page,
      routeName,
          (route) => Navigator.of(context).push(route),
    );
  }

  static Future<void> pushReplacement(BuildContext context, Widget page, String? routeName) async {
    await _navigateWithHealthCheck(
      context,
      page,
      routeName,
          (route) => Navigator.of(context).pushReplacement(route),
    );
  }

  static Future<void> pushAndRemoveAll(BuildContext context, Widget page, String? routeName) async {
    await _navigateWithHealthCheck(
      context,
      page,
      routeName,
          (route) => Navigator.of(context).pushAndRemoveUntil(route, (_) => false),
    );
  }

  static Future<void> _navigateWithHealthCheck(
      BuildContext context,
      Widget targetPage,
      String? routeName,
      Future<void> Function(MaterialPageRoute) navigationAction,
      ) async {
    try {
      final isHealthy = await FastApi.checkFastApiHealth();

      if (isHealthy) {
        await navigationAction(
          MaterialPageRoute(
            builder: (_) => targetPage,
            settings: RouteSettings(name: routeName ?? "/${targetPage.runtimeType}"),
          ),
        );
      } else {
        throw Exception("FastAPI false döndü.");
      }
    } catch (e) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ErrorScreen(
            statusCode: 503,
            message: "API bağlantısı başarısız",
            requestedPath: routeName ?? "/${targetPage.runtimeType}",
            exceptionDetails: e.toString(),
          ),
          settings: const RouteSettings(name: "/errorScreen"),
        ),
            (route) => false,
      );
    }
  }
}
