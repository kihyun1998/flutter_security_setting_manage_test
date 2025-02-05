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
