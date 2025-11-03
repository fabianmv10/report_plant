import 'package:flutter_test/flutter_test.dart';
import 'package:report_plant/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('debe ser un singleton', () {
      final config1 = AppConfig();
      final config2 = AppConfig();

      expect(config1, same(config2));
    });

    test('debe tener valores por defecto si no hay .env', () {
      final config = AppConfig();

      expect(config.apiBaseUrl, isNotEmpty);
      expect(config.apiTimeoutSeconds, greaterThan(0));
    });
  });
}
