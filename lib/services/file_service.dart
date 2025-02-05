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
