# flutter_security_setting_manage_test
## Project Structure

```
flutter_security_setting_manage_test/
├── lib/
    ├── models/
    │   ├── basic_setting.dart
    │   └── security_setting.dart
    ├── screens/
    │   ├── basic_settings_page.dart
    │   ├── home_page.dart
    │   └── security_settings_page.dart
    ├── services/
    │   ├── encryption_service.dart
    │   └── file_service.dart
    ├── utils/
    │   └── constants.dart
    └── main.dart
├── README.md
├── basic_settings.json
├── plan.md
└── security_settings.json
```

## README.md
```md
# flutter_security_setting_manage_test
 

```
## basic_settings.json
```json
{
    "serverUrl": "http://example.com",
    "port": 8080,
    "timeout": 300,
    "enableLogging": true
}
```
## lib/main.dart
```dart
import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '설정 관리자',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
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
## lib/screens/basic_settings_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_security_setting_manage_test/utils/constants.dart';

import '../models/basic_setting.dart';
import '../services/encryption_service.dart';
import '../services/file_service.dart';

class BasicSettingsPage extends StatefulWidget {
  const BasicSettingsPage({super.key});

  @override
  State<BasicSettingsPage> createState() => _BasicSettingsPageState();
}

class _BasicSettingsPageState extends State<BasicSettingsPage> {
  // 폼 키 및 컨트롤러들
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serverUrlController;
  late TextEditingController _portController;
  late TextEditingController _timeoutController;
  late bool _enableLogging;

  // 서비스 인스턴스
  late final FileService _fileService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 컨트롤러 초기화
    _serverUrlController = TextEditingController();
    _portController = TextEditingController();
    _timeoutController = TextEditingController();
    _enableLogging = false;

    // FileService 초기화 및 설정 불러오기
    _fileService = FileService(EncryptionService());
    _loadSettings();
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _serverUrlController.dispose();
    _portController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  // 설정 불러오기
  Future<void> _loadSettings() async {
    try {
      final settings = await _fileService.loadBasicSettings();
      setState(() {
        _serverUrlController.text = settings.serverURL;
        _portController.text = settings.port.toString();
        _timeoutController.text = settings.timeout.toString();
        _enableLogging = settings.enableLogging;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정을 불러오는 데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  // 설정 저장하기
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final settings = BasicSettings(
        serverURL: _serverUrlController.text,
        port: int.parse(_portController.text),
        timeout: int.parse(_timeoutController.text),
        enableLogging: _enableLogging,
      );

      // 유효성 검증
      final validationError = settings.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      await _fileService.saveBasicSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 저장에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('기본 설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 서버 URL 입력 필드
              TextFormField(
                controller: _serverUrlController,
                decoration: const InputDecoration(
                  labelText: '서버 URL',
                  hintText: 'http://example.com',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '서버 URL을 입력하세요';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL은 http:// 또는 https://로 시작해야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 포트 입력 필드
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: '포트',
                  hintText: '8080',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '포트 번호를 입력하세요';
                  }
                  final port = int.tryParse(value);
                  if (port == null ||
                      port < 0 ||
                      port > AppConstants.maxPortNumber) {
                    return '유효한 포트 번호를 입력하세요 (0-${AppConstants.maxPortNumber})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 타임아웃 입력 필드
              TextFormField(
                controller: _timeoutController,
                decoration: const InputDecoration(
                  labelText: '타임아웃 (초)',
                  hintText: '30',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '타임아웃 값을 입력하세요';
                  }
                  final timeout = int.tryParse(value);
                  if (timeout == null ||
                      timeout < AppConstants.minTimeout ||
                      timeout > AppConstants.maxTimeout) {
                    return '유효한 타임아웃 값을 입력하세요 (${AppConstants.minTimeout}-${AppConstants.maxTimeout})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 로깅 활성화 스위치
              SwitchListTile(
                title: const Text('로깅 활성화'),
                subtitle: const Text('디버그 정보를 로그 파일에 저장합니다'),
                value: _enableLogging,
                onChanged: (bool value) {
                  setState(() {
                    _enableLogging = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // 저장 버튼
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('설정 저장'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```
## lib/screens/home_page.dart
```dart
import 'package:flutter/material.dart';

import 'basic_settings_page.dart';
import 'security_settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정 관리자'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 기본 설정 카드
              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('기본 설정'),
                  subtitle: const Text('서버 URL, 포트, 타임아웃 등의 기본 설정을 관리합니다.'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BasicSettingsPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // 보안 설정 카드
              Card(
                child: ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('보안 설정'),
                  subtitle: const Text('API 키, 토큰 등의 보안 설정을 관리합니다.'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecuritySettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```
## lib/screens/security_settings_page.dart
```dart
import 'package:flutter/material.dart';

import '../models/security_setting.dart';
import '../services/encryption_service.dart';
import '../services/file_service.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiKeyController;
  late TextEditingController _accessTokenController;
  late TextEditingController _refreshTokenController;
  late final FileService _fileService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _accessTokenController = TextEditingController();
    _refreshTokenController = TextEditingController();
    _fileService = FileService(EncryptionService());
    _loadSecuritySettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _accessTokenController.dispose();
    _refreshTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final settings = await _fileService.loadSecuritySettings();
      setState(() {
        _apiKeyController.text = settings.apiKey;
        _accessTokenController.text = settings.accessToken;
        _refreshTokenController.text = settings.refreshToken;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('보안 설정을 불러오는 데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveSecuritySettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final settings = SecuritySetting(
        apiKey: _apiKeyController.text,
        accessToken: _accessTokenController.text,
        refreshToken: _refreshTokenController.text,
      );

      final validationError = settings.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      await _fileService.saveSecuritySettings(settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('보안 설정이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('보안 설정 저장 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('보안 설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'API Key를 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accessTokenController,
                decoration: const InputDecoration(
                  labelText: 'Access Token',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Access Token을 입력하세요'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _refreshTokenController,
                decoration: const InputDecoration(
                  labelText: 'Refresh Token',
                  prefixIcon: Icon(Icons.refresh),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Refresh Token을 입력하세요'
                    : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveSecuritySettings,
                icon: const Icon(Icons.save),
                label: const Text('보안 설정 저장'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
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
## lib/services/file_service.dart
```dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/basic_setting.dart';
import '../models/security_setting.dart';
import '../utils/constants.dart';
import 'encryption_service.dart';

class FileService {
  final EncryptionService _encryptionService;

  FileService(this._encryptionService);

  // 앱의 로컬 저장소 디렉토리 경로를 가져오는 메서드
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 기본 설정 파일의 전체 경로를 가져오는 메서드
  Future<File> get _basicSettingsFile async {
    final path = await _localPath;
    return File('$path/${AppConstants.basicSettingsFileName}');
  }

  // 보안 설정 파일의 전체 경로를 가져오는 메서드
  Future<File> get _securitySettingsFile async {
    final path = await _localPath;
    return File('$path/${AppConstants.securitySettingsFileName}');
  }

  // 기본 설정을 저장하는 메서드
  Future<void> saveBasicSettings(BasicSettings settings) async {
    try {
      final file = await _basicSettingsFile;
      await file.writeAsString(settings.toJsonString());
    } catch (e) {
      throw Exception('기본 설정 저장 실패: ${e.toString()}');
    }
  }

  // 보안 설정을 저장하는 메서드
  Future<void> saveSecuritySettings(SecuritySetting settings) async {
    try {
      final file = await _securitySettingsFile;
      final encryptedData = settings.toEncryptedString(_encryptionService);
      await file.writeAsString(encryptedData);
    } catch (e) {
      throw Exception('보안 설정 저장 실패: ${e.toString()}');
    }
  }

  // 기본 설정을 불러오는 메서드
  Future<BasicSettings> loadBasicSettings() async {
    try {
      final file = await _basicSettingsFile;
      if (!await file.exists()) {
        // 파일이 없으면 기본값으로 설정
        return BasicSettings();
      }

      final jsonString = await file.readAsString();
      return BasicSettings.fromJsonString(jsonString);
    } catch (e) {
      throw Exception('기본 설정 불러오기 실패: ${e.toString()}');
    }
  }

  // 보안 설정을 불러오는 메서드
  Future<SecuritySetting> loadSecuritySettings() async {
    try {
      final file = await _securitySettingsFile;
      if (!await file.exists()) {
        throw Exception('보안 설정 파일이 존재하지 않습니다.');
      }

      final encryptedData = await file.readAsString();
      return SecuritySetting.fromEncryptedString(
          encryptedData, _encryptionService);
    } catch (e) {
      throw Exception('보안 설정 불러오기 실패: ${e.toString()}');
    }
  }

  // 모든 설정 파일 삭제 메서드 (초기화 용도)
  Future<void> clearAllSettings() async {
    try {
      final basicFile = await _basicSettingsFile;
      final securityFile = await _securitySettingsFile;

      if (await basicFile.exists()) {
        await basicFile.delete();
      }
      if (await securityFile.exists()) {
        await securityFile.delete();
      }
    } catch (e) {
      throw Exception('설정 파일 삭제 실패: ${e.toString()}');
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
## plan.md
```md
네, 두 가지 설정 페이지를 비교하는 구조로 만들어보겠습니다.

```
lib/
├── main.dart
├── models/
│   ├── basic_settings.dart
│   └── security_settings.dart
├── services/
│   ├── encryption_service.dart
│   └── file_service.dart
├── screens/
│   ├── basic_settings_page.dart
│   ├── security_settings_page.dart
│   └── home_page.dart
└── utils/
    ├── constants.dart
    └── validators.dart
```

주요 컴포넌트 설명:

1. **models/**
   - `basic_settings.dart`: 일반 JSON 직렬화/역직렬화 모델
   - `security_settings.dart`: 암호화/복호화가 필요한 보안 설정 모델

2. **services/**
   - `encryption_service.dart`: 암호화/복호화 및 해시 생성 로직
   - `file_service.dart`: 파일 읽기/쓰기 처리

3. **screens/**
   - `home_page.dart`: 두 설정 페이지로 이동할 수 있는 메인 화면
   - `basic_settings_page.dart`: 기본 설정 페이지
   - `security_settings_page.dart`: 보안 설정 페이지

4. **utils/**
   - `constants.dart`: 파일 경로, 키 등 상수 정의
   - `validators.dart`: 설정값 검증 로직

이제 기본적인 앱을 만들어볼까요? main.dart부터 시작해서 하나씩 구현해나가면 될 것 같습니다. 어떤 부분부터 보고 싶으신가요?

참고로 각 설정 파일은 다음과 같은 형태가 될 것 같습니다:

```json
// basic_settings.json
{
  "serverUrl": "http://example.com",
  "port": 8080,
  "timeout": 30,
  "enableLogging": true
}

// security_settings.json (암호화 전)
{
  "apiKey": "your-secret-key",
  "accessToken": "your-access-token",
  "refreshToken": "your-refresh-token",
  "lastModified": "2024-02-05T12:00:00Z",
  "hash": "generated-hash-value"
}
```

```
파일 저장 > 암호화 > 암호화에 salt추가 > (암호화+salt)를 해시 > (암호화+salt)(내가 정의한 구분 패턴)(암호화+salt 해시값) > base64 인코딩
```

이렇게 해서 파일 읽을 때는


```
base64 디코딩 > 구분 패턴으로 암호화+salt와 해시값 구분 > 암호화+salt를 해시 > 여기서 나온 해시 값과 기존에 있던 해시값 비교 > 암호화+salt에서 salt를 제거 하고 decrypt
```
```
## security_settings.json
```json
{
    "apiKey": "your-secret-key",
    "accessToken": "your-access-token",
    "refreshToken": "your-refresh-token",
    "lastModified": "2024-02-05T12:00:00Z",
    "hash": "generated-hash-value"
}
```
