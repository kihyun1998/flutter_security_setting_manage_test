import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../utils/constants.dart';

class EncryptionService {
  static const String _delimiter = "::##::"; // 구분 패턴
  static const int _saltLength = 16;

  // final encrypt.Key _key = encrypt.Key.fromUtf8(AppConstants.encryptionKey);
  final encrypt.IV _iv;
  final encrypt.Key _key;

  EncryptionService()
      : _key = encrypt.Key.fromBase16(AppConstants.encryptionKey),
        _iv = encrypt.IV.fromBase16(AppConstants.encryptionIV) {
    // 🔥 키 길이 검증
    if (_key.bytes.length != 32) {
      throw Exception(
          'Invalid Key length: ${_key.bytes.length}. Key must be exactly 32 bytes.');
    }
    // 🔥 IV 길이 검증
    if (_iv.bytes.length != 16) {
      throw Exception(
          'Invalid IV length: ${_iv.bytes.length}. IV must be exactly 16 bytes.');
    }
  }

  final _encrypter = encrypt.Encrypter(
    encrypt.AES(encrypt.Key.fromBase16(AppConstants.encryptionKey)),
  );

  static get hex => null;

  // 랜덤 salt 생성
  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(_saltLength, (i) => random.nextInt(256));
    if (values.length != _saltLength) {
      throw Exception('Generated Salt length is invalid: ${values.length}');
    }
    return base64Url.encode(values).substring(0, _saltLength); // 정확한 길이 유지
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
