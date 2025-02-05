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
