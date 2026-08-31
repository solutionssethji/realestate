import 'package:flutter/material.dart';
import '../main.dart';

class AppSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green.shade600, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.red.shade600, Icons.error_outline);
  }

  static void showGlobalError(String message) {
    _showGlobal(message, Colors.red.shade600, Icons.error_outline);
  }

  static void showGlobalSuccess(String message) {
    _showGlobal(message, Colors.green.shade600, Icons.check_circle_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Colors.blue.shade600, Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color bgColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 4,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void _showGlobal(String message, Color bgColor, IconData icon) {
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 4,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
