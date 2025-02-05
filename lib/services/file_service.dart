import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/basic_setting.dart';
import '../models/security_setting.dart';
import '../utils/constants.dart';
import 'encryption_service.dart';

class FileService {
  final EncryptionService _encryptionService;
  Timer? _debounceTimer; // 🔥 디바운스 타이머 추가
  SecuritySetting? _cachedSecuritySettings; // 🔥 메모리 캐시 추가

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

  Future<void> cacheSecuritySettings(SecuritySetting settings) async {
    _cachedSecuritySettings = settings;

    // 기존 타이머가 있으면 취소 (디바운스 적용)
    _debounceTimer?.cancel();

    // 3초 후 자동 저장 (디바운스)
    _debounceTimer = Timer(const Duration(seconds: 3), () async {
      if (_cachedSecuritySettings != null) {
        await _saveSecuritySettings(_cachedSecuritySettings!);
      }
    });
  }

  // 보안 설정 저장 (암호화 실패 시 기본값 사용)
  Future<void> _saveSecuritySettings(SecuritySetting settings) async {
    try {
      final file = await _securitySettingsFile;
      final encryptedData = settings.toEncryptedString(_encryptionService);
      await file.writeAsString(encryptedData);
    } catch (e, stackTrace) {
      print('보안 설정 저장 실패: $e $stackTrace');
      // 암호화 실패 시 기본 설정값 저장
      final defaultSettings = SecuritySetting(
        apiKey: 'default-api-key',
        accessToken: 'default-access-token',
        refreshToken: 'default-refresh-token',
      );
      final file = await _securitySettingsFile;
      final defaultEncryptedData =
          defaultSettings.toEncryptedString(_encryptionService);
      await file.writeAsString(defaultEncryptedData);
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

  // 보안 설정 불러오기 (없거나 실패 시 기본값 사용)
  Future<SecuritySetting> loadSecuritySettings() async {
    try {
      final file = await _securitySettingsFile;
      if (!await file.exists()) {
        return _saveAndReturnDefaultSettings();
      }

      final encryptedData = await file.readAsString();

      // 데이터가 올바른 Base64 형식인지 검증
      if (!RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(encryptedData)) {
        throw FormatException('Invalid Base64 format');
      }

      return SecuritySetting.fromEncryptedString(
          encryptedData, _encryptionService);
    } catch (e, stackTrace) {
      print('보안 설정 불러오기 실패: $e, $stackTrace');

      await resetSecuritySettings();
      return _saveAndReturnDefaultSettings();
    }
  }

  Future<void> resetSecuritySettings() async {
    _debounceTimer?.cancel(); // 타이머 정리
    _cachedSecuritySettings = null; // 캐시 삭제

    final file = await _securitySettingsFile;
    if (await file.exists()) {
      await file.delete();
    }
  }

  // 기본 보안 설정 생성 및 저장 후 반환
  Future<SecuritySetting> _saveAndReturnDefaultSettings() async {
    final defaultSettings = SecuritySetting(
      apiKey: 'default-api-key',
      accessToken: 'default-access-token',
      refreshToken: 'default-refresh-token',
    );

    cacheSecuritySettings(defaultSettings);
    return defaultSettings;
  }

  // 모든 설정 파일 삭제 메서드 (초기화 용도)
  Future<void> clearAllSettings() async {
    try {
      _debounceTimer?.cancel(); // 🔥 타이머 정리
      _cachedSecuritySettings = null; // 🔥 캐시 삭제

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
