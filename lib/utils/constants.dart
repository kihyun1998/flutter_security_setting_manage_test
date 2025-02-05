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
