// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter_security_setting_manage_test/services/encryption_service.dart';

enum SecuritySettingJsonKey {
  apiKey,
  accessToken,
  refreshToken,
  lastModified,
  ;

  String get key {
    return toString().split('.').last;
  }
}

class SecuritySetting {
  final String apiKey;
  final String accessToken;
  final String refreshToken;
  final DateTime lastModified;

  SecuritySetting({
    required this.apiKey,
    required this.accessToken,
    required this.refreshToken,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        SecuritySettingJsonKey.apiKey.key: apiKey,
        SecuritySettingJsonKey.accessToken.key: accessToken,
        SecuritySettingJsonKey.refreshToken.key: refreshToken,
        SecuritySettingJsonKey.lastModified.key: lastModified.toIso8601String(),
      };

  factory SecuritySetting.fromJson(Map<String, dynamic> json) {
    return SecuritySetting(
      apiKey: json[SecuritySettingJsonKey.apiKey.key] as String,
      accessToken: json[SecuritySettingJsonKey.accessToken.key] as String,
      refreshToken: json[SecuritySettingJsonKey.refreshToken.key] as String,
      lastModified: DateTime.parse(
          json[SecuritySettingJsonKey.lastModified.key] as String),
    );
  }

  String toEncryptedString(EncryptionService encryptionService) {
    final jsonString = jsonEncode(toJson());
    return encryptionService.encryptData(jsonString);
  }

  // Create from encrypted string
  static SecuritySetting fromEncryptedString(
      String encryptedString, EncryptionService encryptionService) {
    final jsonString = encryptionService.decryptData(encryptedString);
    final json = jsonDecode(jsonString);
    return SecuritySetting.fromJson(json);
  }

  // String representation for debugging (with masked sensitive data)
  @override
  String toString() {
    return 'SecuritySettings(apiKey: ${_maskString(apiKey)}, '
        'accessToken: ${_maskString(accessToken)}, '
        'refreshToken: ${_maskString(refreshToken)}, '
        'lastModified: $lastModified)';
  }

  // Utility function to mask sensitive data
  String _maskString(String input) {
    if (input.length <= 4) return '*' * input.length;
    return '${input.substring(0, 4)}${'*' * (input.length - 4)}';
  }

  // Validation
  String? validate() {
    if (apiKey.isEmpty) {
      return 'API Key cannot be empty';
    }
    if (accessToken.isEmpty) {
      return 'Access Token cannot be empty';
    }
    if (refreshToken.isEmpty) {
      return 'Refresh Token cannot be empty';
    }
    return null;
  }

  SecuritySetting copyWith({
    String? apiKey,
    String? accessToken,
    String? refreshToken,
    DateTime? lastModified,
  }) {
    return SecuritySetting(
      apiKey: apiKey ?? this.apiKey,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
