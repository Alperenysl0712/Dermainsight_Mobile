import 'package:flutter/material.dart';

class ErrorManager {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(message, style: TextStyle(fontSize: 15)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Tamam"),
              ),
            ],
          ),
    );
  }

  static void showMessage({
    required BuildContext context,
    required String title,
    required String message,
    int? status = 0,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            scrollable: true,
            alignment: Alignment.center,
            title: Text(
              title,
              style: TextStyle(
                color: status == 0 ? Colors.red : status == 1 ? Colors.green : Colors.orangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(message, style: TextStyle(fontSize: 15)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Tamam"),
              ),
            ],
          ),
    );
  }
}
