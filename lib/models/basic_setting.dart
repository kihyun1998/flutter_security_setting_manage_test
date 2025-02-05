// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter_security_setting_manage_test/utils/constants.dart';

enum BasicSettingJsonKey {
  serverURL,
  port,
  timeout,
  enableLogging,
  ;

  String get key {
    return toString().split('.').last;
  }
}

class BasicSettings {
  final String serverURL;
  final int port;
  final int timeout;
  final bool enableLogging;
  BasicSettings({
    this.serverURL = AppConstants.defaultServerUrl,
    this.port = AppConstants.defaultPort,
    this.timeout = AppConstants.defaultTimeout,
    this.enableLogging = AppConstants.defaultEnableLogging,
  });

  Map<String, dynamic> toJson() => {
        BasicSettingJsonKey.serverURL.key: serverURL,
        BasicSettingJsonKey.port.key: port,
        BasicSettingJsonKey.timeout.key: timeout,
        BasicSettingJsonKey.enableLogging.key: enableLogging,
      };

  factory BasicSettings.fromJsson(Map<String, dynamic> json) {
    return BasicSettings(
      serverURL: json[BasicSettingJsonKey.serverURL.key] as String? ??
          AppConstants.defaultServerUrl,
      port: json[BasicSettingJsonKey.port.key] as int? ??
          AppConstants.defaultPort,
      timeout: json[BasicSettingJsonKey.timeout.key] as int? ??
          AppConstants.defaultTimeout,
      enableLogging: json[BasicSettingJsonKey.enableLogging.key] as bool? ??
          AppConstants.defaultEnableLogging,
    );
  }

  @override
  String toString() =>
      "BasicSettings(serverURL: $serverURL, port: $port, timeout: $timeout, enableLoggin: $enableLogging)";

  static BasicSettings fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return BasicSettings.fromJsson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Validation
  String? validate() {
    if (port < 0 || port > AppConstants.maxPortNumber) {
      return 'Port must be between 0 and ${AppConstants.maxPortNumber}';
    }
    if (timeout < AppConstants.minTimeout ||
        timeout > AppConstants.maxTimeout) {
      return 'Timeout must be between ${AppConstants.minTimeout} and ${AppConstants.maxTimeout}';
    }
    if (!serverURL.startsWith('http://') && !serverURL.startsWith('https://')) {
      return 'Server URL must start with http:// or https://';
    }
    return null;
  }

  BasicSettings copyWith({
    String? serverURL,
    int? port,
    bool? enableLogging,
  }) {
    return BasicSettings(
      serverURL: serverURL ?? this.serverURL,
      port: port ?? this.port,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}
