import 'package:flutter_test/flutter_test.dart';
import 'package:nabdh_alyaman/core/config/app_config.dart';

void main() {
  test('AppConfig default API base URL includes /api/v1', () {
    expect(AppConfig.apiBaseUrl, contains('/api/v1'));
  });
}
