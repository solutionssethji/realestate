import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AppValidators {
  static String? required(BuildContext context, String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      final label = fieldName ?? 'This field';
      return '$label is required';
    }
    return null;
  }

  static String? phone(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${AppLocalizations.of(context).mobileNumber} is required';
    }
    if (value.trim().length != 10 || !RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? email(BuildContext context, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
        return 'Enter a valid email address';
      }
    }
    return null;
  }

  static String? password(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${AppLocalizations.of(context).passwordLabel} is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? aadhaar(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar Number is required';
    }
    if (value.trim().length != 12 || !RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Enter a valid 12-digit Aadhaar Number';
    }
    return null;
  }

  static String? pan(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN Number is required';
    }
    if (value.trim().length != 10 || !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$', caseSensitive: false).hasMatch(value.trim())) {
      return 'Enter a valid 10-character PAN Number';
    }
    return null;
  }
}
