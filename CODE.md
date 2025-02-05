# flutter_security_setting_manage_test
## Project Structure

```
flutter_security_setting_manage_test/
├── lib/
    ├── models/
    │   ├── basic_setting.dart
    │   └── security_setting.dart
    ├── services/
    │   └── encryption_service.dart
    ├── utils/
    │   └── constants.dart
    └── main.dart
├── README.md
└── pubspec.yaml
```

## README.md
```md
# flutter_security_setting_manage_test
 

```
## lib/main.dart
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

```
## lib/models/basic_setting.dart
```dart
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

```
## lib/models/security_setting.dart
```dart
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

```
## lib/services/encryption_service.dart
```dart
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../utils/constants.dart';

class EncryptionService {
  static const String _delimiter = "::##::"; // 구분 패턴
  static const int _saltLength = 16;

  // final encrypt.Key _key = encrypt.Key.fromUtf8(AppConstants.encryptionKey);
  final encrypt.IV _iv = encrypt.IV.fromUtf8(AppConstants.encryptionIV);
  final _encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8(AppConstants.encryptionKey)));

  // 랜덤 salt 생성
  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(_saltLength, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // 해시 생성
  String _generateHash(String data) {
    final bytes = utf8.encode(data);
    return sha256.convert(bytes).toString();
  }

  // 데이터 암호화 및 저장 형식 생성
  String encryptData(String plainText) {
    // 1. 데이터 암호화
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);

    // 2. salt 생성 및 추가
    final salt = _generateSalt();
    final encryptedWithSalt = "${encrypted.base64}$salt";

    // 3. 해시 생성
    final hash = _generateHash(encryptedWithSalt);

    // 4. 최종 형식 생성: (암호화+salt)::##::(해시)
    final finalData = "$encryptedWithSalt$_delimiter$hash";

    // 5. base64 인코딩
    return base64Encode(utf8.encode(finalData));
  }

  // 데이터 복호화 및 검증
  String decryptData(String encodedData) {
    try {
      // 1. base64 디코딩
      final decodedData = utf8.decode(base64Decode(encodedData));

      // 2. 구분자로 분리
      final parts = decodedData.split(_delimiter);
      if (parts.length != 2) {
        throw FormatException('Invalid encrypted data format');
      }

      final encryptedWithSalt = parts[0];
      final storedHash = parts[1];

      // 3. 해시 검증
      final calculatedHash = _generateHash(encryptedWithSalt);
      if (calculatedHash != storedHash) {
        throw FormatException('Data integrity check failed');
      }

      // 4. salt 제거 (마지막 _saltLength만큼이 salt)
      final encryptedBase64 = encryptedWithSalt.substring(
          0, encryptedWithSalt.length - _saltLength);

      // 5. 복호화
      final encrypted = encrypt.Encrypted.fromBase64(encryptedBase64);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw FormatException('Failed to decrypt data: ${e.toString()}');
    }
  }
}

```
## lib/utils/constants.dart
```dart
class AppConstants {
  // File paths
  static const String basicSettingsFileName = 'basic_settings.json';
  static const String securitySettingsFileName = 'security_settings.json';

  // Encryption
  static const String encryptionKey =
      'your_32_length_secret_key_12345678'; // 32 bytes for AES-256
  static const String encryptionIV = 'your_16_length_iv'; // 16 bytes for AES

  // Validation
  static const int maxPortNumber = 65535;
  static const int minTimeout = 1;
  static const int maxTimeout = 300;

  // Default values
  static const String defaultServerUrl = 'http://localhost';
  static const int defaultPort = 8080;
  static const int defaultTimeout = 30;
  static const bool defaultEnableLogging = false;
}

```
## pubspec.yaml
```yaml
name: flutter_security_setting_manage_test
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.6.1

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  crypto: ^3.0.6
  cupertino_icons: ^1.0.8
  encrypt: ^5.0.3
  flutter:
    sdk: flutter
  path_provider: ^2.1.5

dev_dependencies:

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^5.0.0
  flutter_test:
    sdk: flutter

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec
# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true
  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg
  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images
  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package
  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

```
