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
