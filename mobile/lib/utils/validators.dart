import 'l10n_extension.dart';
import 'package:flutter/material.dart';

class AppValidators {
  static String? required(
    BuildContext context,
    String? value, [
    String? fieldName,
  ]) {
    if (value == null || value.trim().isEmpty) {
      final label = fieldName ?? context.l10n.validationThisField;
      return context.l10n.validationFieldRequired(label);
    }
    return null;
  }

  static String? phone(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationFieldRequired(context.l10n.mobileNumber);
    }
    if (value.trim().length != 10 || !RegExp(r'^\d+$').hasMatch(value.trim())) {
      return context.l10n.validationMobileLength;
    }
    return null;
  }

  static String? email(BuildContext context, String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
        return context.l10n.validationEmailFormat;
      }
    }
    return null;
  }

  static String? password(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationFieldRequired(context.l10n.passwordLabel);
    }
    if (value.trim().length < 6) {
      return context.l10n.validationPasswordLength;
    }
    return null;
  }

  static String? aadhaar(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationAadhaarRequired;
    }
    if (value.trim().length != 12 ||
        !RegExp(r'^[2-9]{1}[0-9]{11}$').hasMatch(value.trim())) {
      return context.l10n.validationAadhaarLength;
    }
    return null;
  }

  static String? pan(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationPanRequired;
    }
    if (value.trim().length != 10 ||
        !RegExp(
          r'^[A-Z]{3}[PCHFATBLJG]{1}[A-Z]{1}[0-9]{4}[A-Z]{1}$',
          caseSensitive: false,
        ).hasMatch(value.trim())) {
      return context.l10n.validationPanLength;
    }
    return null;
  }

  static String? accountNumber(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationAccountRequired;
    }
    if (!RegExp(r'^\d{9,18}$').hasMatch(value.trim())) {
      return context.l10n.validationAccountLength;
    }
    return null;
  }

  static String? ifscCode(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationIfscRequired;
    }
    if (!RegExp(
      r'^[A-Z]{4}0[A-Z0-9]{6}$',
      caseSensitive: false,
    ).hasMatch(value.trim())) {
      return context.l10n.validationIfscLength;
    }
    return null;
  }
}
