class AppConstants {
  // File paths
  static const String basicSettingsFileName = 'basic_settings.json';
  static const String securitySettingsFileName = 'security_settings.json';

  // Encryption
  static const String encryptionKey =
      'e4c09b8a8f4e7f6635b14a8b292f91a7d7e8c7a00e5b68c8a8b0f1d6a4a4a7e8'; // 32 bytes for AES-256
  static const String encryptionIV =
      '7ac075ded8f50f175b888d5b32b30961'; // 16 bytes for AES

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
