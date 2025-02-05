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
