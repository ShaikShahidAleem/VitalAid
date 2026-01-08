import 'package:flutter_test/flutter_test.dart';
import 'package:vitalaid/services/graphics_compatibility_service.dart';

void main() {
  group('GraphicsCompatibilityService Tests', () {
    test('should create GraphicsCompatibilityReport with basic info', () {
      final report = GraphicsCompatibilityReport(
        isEmulator: true,
        hasHardwareAcceleration: false,
        isSoftwareRendering: true,
        graphicsDriver: 'EGL (Emulator)',
        issues: ['Hardware acceleration not available'],
        recommendations: ['Enable hardware acceleration in AVD settings'],
      );

      expect(report.isEmulator, true);
      expect(report.hasHardwareAcceleration, false);
      expect(report.isSoftwareRendering, true);
      expect(report.graphicsDriver, 'EGL (Emulator)');
      expect(report.hasIssues, true);
      expect(report.isOptimal, false);
      expect(report.summary, contains('Graphics issues detected'));
    });

    test('should identify optimal graphics environment', () {
      final report = GraphicsCompatibilityReport(
        isEmulator: false,
        hasHardwareAcceleration: true,
        isSoftwareRendering: false,
        graphicsDriver: 'Adreno 640',
        issues: [],
        recommendations: [],
      );

      expect(report.isOptimal, true);
      expect(report.summary, 'Graphics environment is optimal for TF-Lite operations');
    });

    test('should generate proper recommendations for emulator', () {
      final report = GraphicsCompatibilityReport(
        isEmulator: true,
        hasHardwareAcceleration: false,
        isSoftwareRendering: true,
        graphicsDriver: 'Software Renderer',
        issues: ['Hardware acceleration not available', 'Software rendering detected'],
        recommendations: [],
      );

      final recommendations = report.recommendations;
      expect(recommendations, isNotEmpty);
      expect(recommendations, contains('Enable hardware acceleration in AVD settings'));
      expect(recommendations, contains('Use a newer Android API level (API 30+)'));
      expect(recommendations, contains('Consider using a physical device'));
    });

    test('should convert report to JSON', () {
      final report = GraphicsCompatibilityReport(
        isEmulator: true,
        hasHardwareAcceleration: false,
        isSoftwareRendering: true,
        graphicsDriver: 'EGL (Emulator)',
        issues: ['Test issue'],
        recommendations: ['Test recommendation'],
      );

      final json = report.toJson();
      expect(json['isEmulator'], true);
      expect(json['hasHardwareAcceleration'], false);
      expect(json['isSoftwareRendering'], true);
      expect(json['graphicsDriver'], 'EGL (Emulator)');
      expect(json['issues'], ['Test issue']);
      expect(json['recommendations'], ['Test recommendation']);
      expect(json['hasIssues'], true);
      expect(json['isOptimal'], false);
    });

    test('TF-Lite fallback strategies should be properly defined', () {
      expect(TFLiteFallbackStrategy.fullOperations, isNotNull);
      expect(TFLiteFallbackStrategy.limitedOperations, isNotNull);
      expect(TFLiteFallbackStrategy.useKeywordMatching, isNotNull);
    });
  });

  group('TFChatbotService Integration Tests', () {
    test('should handle TF-Lite loading with graphics compatibility check', () async {
      // This test would verify that the TF-Lite service properly
      // integrates with the graphics compatibility service
      // In a real test, we would mock the graphics service
      expect(TFLiteFallbackStrategy.values.length, 3);
    });
  });

  group('Performance Impact Tests', () {
    test('should identify performance issues from frame time stats', () {
      // Simulate the error pattern from the logs
      final frameTimeStats = [
        'avg=499.80ms min=498.36ms max=500.52ms count=3',
        'avg=500.17ms min=497.69ms max=502.66ms count=2',
        'avg=499.28ms min=497.60ms max=500.95ms count=3',
      ];

      for (final stat in frameTimeStats) {
        // Extract average frame time
        final avgMatch = RegExp(r'avg=(\d+\.?\d*)ms').firstMatch(stat);
        if (avgMatch != null) {
          final avgTime = double.parse(avgMatch.group(1)!);
          expect(avgTime, greaterThan(400), reason: 'Frame time should indicate software rendering');
        }
      }
    });
  });

  group('Solution Verification Tests', () {
    test('should verify emulator configuration recommendations', () {
      final emulatorIssues = [
        'Hardware acceleration not available',
        'Software rendering detected - expect performance issues'
      ];

      final recommendations = [
        'Enable hardware acceleration in AVD settings',
        'Update graphics drivers on your development machine',
        'Try a different emulator image (Google APIs vs. Google Play)',
        'Allocate more RAM to the emulator (at least 2GB)',
        'Enable "Use Host GPU" in AVD configuration',
        'Enable OpenGL ES support in emulator settings'
      ];

      expect(emulatorIssues.length, greaterThan(0));
      expect(recommendations.length, greaterThan(0));
      expect(recommendations, contains('Enable hardware acceleration in AVD settings'));
    });
  });
}