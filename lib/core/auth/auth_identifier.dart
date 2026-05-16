import 'package:email_validator/email_validator.dart';

/// Normalizes [raw] login identifier per backend contract.
/// Phones are sent without `+` (e.g. `967771234567`). Emails lowercase.
String? normalizeAuthIdentifier(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (EmailValidator.validate(trimmed)) {
    return trimmed.toLowerCase();
  }

  final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');
  if (digitsOnly.length == 12 && digitsOnly.startsWith('967')) {
    return digitsOnly;
  }
  // Local form 7xxxxxxxx (9 digits, Yemen mobiles)
  if (digitsOnly.length == 9 && digitsOnly.startsWith('7')) {
    return '967$digitsOnly';
  }
  if (digitsOnly.length == 9 && trimmed.startsWith('0')) {
    return '967${digitsOnly.substring(1)}';
  }
  return null;
}
