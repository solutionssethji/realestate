import 'package:customer_app/theme/theme.dart';
import 'package:customer_app/utils/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'NEW':
      return AppTheme.info;
    case 'CONFIRMED':
    case 'COMPLETED':
      return AppTheme.success;
    case 'CANCELLED':
      return AppTheme.error;
    case 'CONTACTED':
      return AppTheme.midnightNavy;
    case 'FOLLOW_UP':
    case 'IN_PROGRESS':
      return AppTheme.warning;
    case 'RESOLVED':
    case 'CLOSED':
      return AppTheme.success;
    default:
      return AppTheme.midnightNavy;
  }
}

String translateStatus(BuildContext context, String status) {
  final l10n = context.l10n;
  switch (status.toUpperCase()) {
    case 'NEW':
      return l10n.statusNew;
    case 'CONFIRMED':
      return l10n.statusConfirmed;
    case 'COMPLETED':
      return l10n.statusCompleted;
    case 'CANCELLED':
      return l10n.statusCancelled;
    case 'CONTACTED':
      return l10n.statusContacted;
    case 'FOLLOW_UP':
      return l10n.statusFollowUp;
    case 'IN_PROGRESS':
      return l10n.statusInProgress;
    case 'RESOLVED':
      return l10n.statusResolved;
    case 'CLOSED':
      return l10n.statusClosed;
    default:
      return status;
  }
}

String formatDate(DateTime date, Locale locale) {
  if (locale.languageCode == 'hi') {
    final months = [
      'जन',
      'फ़र',
      'मार्च',
      'अप्र',
      'मई',
      'जून',
      'जुल',
      'अग',
      'सित',
      'अक्ट',
      'नव',
      'दिस',
    ];

    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);

    final minute = date.minute.toString().padLeft(2, '0');

    final amPm = date.hour >= 12 ? 'अपराह्न' : 'पूर्वाह्न';

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year} - '
        '$hour:$minute $amPm';
  }

  return DateFormat('MMM dd, yyyy - hh:mm a', locale.toString()).format(date);
}

String formatDateOnly(DateTime date, Locale locale) {
  if (locale.languageCode == 'hi') {
    final months = [
      'जन',
      'फ़र',
      'मार्च',
      'अप्र',
      'मई',
      'जून',
      'जुल',
      'अग',
      'सित',
      'अक्ट',
      'नव',
      'दिस',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
  return DateFormat('d MMM yyyy').format(date);
}
