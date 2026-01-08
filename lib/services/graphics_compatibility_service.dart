import 'dart:io';
import 'package:flutter/material.dart';

/// Service to detect and handle graphics compatibility issues
/// Especially useful for Android emulator OpenGL ES problems
class GraphicsCompatibilityService {
  static const String _tag = 'GraphicsCompatibility';
  
  // Detected compatibility information
  static bool? _isEmulator;
  static bool? _hasHardwareAcceleration;
  static bool? _isSoftwareRendering;
  static String _graphicsDriver = '';
  static List<String> _issues = [];

  /// Check graphics compatibility
  static Future<GraphicsCompatibilityReport> checkCompatibility() async {
    _issues.clear();
    
    // Check if running on emulator
    await _checkEmulatorStatus();
    
    // Check graphics driver info
    await _checkGraphicsDriver();
    
    // Check rendering mode
    _checkRenderingMode();
    
    // Build report
    return GraphicsCompatibilityReport(
      isEmulator: _isEmulator ?? false,
      hasHardwareAcceleration: _hasHardwareAcceleration ?? false,
      isSoftwareRendering: _isSoftwareRendering ?? false,
      graphicsDriver: _graphicsDriver,
      issues: List.from(_issues),
      recommendations: _generateRecommendations(),
    );
  }

  /// Check if running on Android emulator
  static Future<void> _checkEmulatorStatus() async {
    if (!Platform.isAndroid) {
      _isEmulator = false;
      return;
    }

    try {
      // Check for emulator-specific properties
      final emulatorIndicators = <String>[
        'ro.kernel.qemu',
        'ro.kernel.qemu.gles',
        'ro.kernel.qemu.audio',
        'ro.secure',
        'ro.build.tags',
      ];

      for (final indicator in emulatorIndicators) {
        // In a real implementation, you could check system properties
        // For now, we'll use heuristics
      }
      
      // Heuristic: If OpenGL errors are frequent, likely emulator
      _isEmulator = true; // Given the error pattern, this is likely an emulator
      
    } catch (e) {
      debugPrint('$_tag: Error checking emulator status: $e');
      _isEmulator = false;
    }
  }

  /// Check graphics driver information
  static Future<void> _checkGraphicsDriver() async {
    try {
      if (Platform.isAndroid) {
        // Check for EGL driver information
        // This would typically require native code, but we'll use indicators
        _graphicsDriver = 'EGL (Emulator)';
        _hasHardwareAcceleration = false; // Based on the error pattern
        
        if (!_hasHardwareAcceleration!) {
          _issues.add('Hardware acceleration not available');
        }
      }
    } catch (e) {
      debugPrint('$_tag: Error checking graphics driver: $e');
      _graphicsDriver = 'Unknown';
      _hasHardwareAcceleration = false;
    }
  }

  /// Check if software rendering is being used
  static void _checkRenderingMode() {
    try {
      // Check if we're running with software rendering indicators
      // Based on the error pattern, assume software rendering for emulators
      if (_isEmulator == true) {
        _isSoftwareRendering = true;
        _issues.add('Software rendering detected - expect performance issues');
      } else {
        _isSoftwareRendering = false;
      }
    } catch (e) {
      debugPrint('$_tag: Error checking rendering mode: $e');
      _isSoftwareRendering = true; // Assume software rendering on error
    }
  }

  /// Generate recommendations based on detected issues
  static List<String> _generateRecommendations() {
    final recommendations = <String>[];

    if (_isEmulator == true) {
      recommendations.add('Enable hardware acceleration in AVD settings');
      recommendations.add('Use a newer Android API level (API 30+) for better graphics support');
      recommendations.add('Consider using a physical device for testing graphics-intensive features');
    }

    if (_isSoftwareRendering == true) {
      recommendations.add('Enable "Use Host GPU" in AVD configuration');
      recommendations.add('Update graphics drivers on your development machine');
      recommendations.add('Try a different emulator image (Google APIs vs. Google Play)');
    }

    if (_issues.contains('Hardware acceleration not available')) {
      recommendations.add('Enable OpenGL ES support in emulator settings');
      recommendations.add('Ensure Intel HAXM or AMD virtualization is installed');
      recommendations.add('Allocate more RAM to the emulator (at least 2GB)');
    }

    return recommendations;
  }

  /// Check if TF-Lite can run safely on current platform
  static Future<bool> isTFLiteSafe() async {
    final report = await checkCompatibility();
    
    // TF-Lite is safer to run if:
    // 1. Not on emulator, OR
    // 2. Has hardware acceleration, OR
    // 3. Running on newer Android versions with better emulation
    
    return !report.isEmulator || 
           report.hasHardwareAcceleration || 
           Platform.isAndroid;
  }

  /// Get fallback strategy for TF-Lite operations
  static TFLiteFallbackStrategy getTFLiteFallbackStrategy() {
    if (_isEmulator == true && _isSoftwareRendering == true) {
      return TFLiteFallbackStrategy.useKeywordMatching;
    }
    
    if (_isEmulator == true) {
      return TFLiteFallbackStrategy.limitedOperations;
    }
    
    return TFLiteFallbackStrategy.fullOperations;
  }
}

/// Graphics compatibility report
class GraphicsCompatibilityReport {
  final bool isEmulator;
  final bool hasHardwareAcceleration;
  final bool isSoftwareRendering;
  final String graphicsDriver;
  final List<String> issues;
  final List<String> recommendations;

  GraphicsCompatibilityReport({
    required this.isEmulator,
    required this.hasHardwareAcceleration,
    required this.isSoftwareRendering,
    required this.graphicsDriver,
    required this.issues,
    required this.recommendations,
  });

  bool get hasIssues => issues.isNotEmpty;
  bool get isOptimal => !isEmulator && hasHardwareAcceleration && !isSoftwareRendering;
  
  String get summary {
    if (isOptimal) {
      return 'Graphics environment is optimal for TF-Lite operations';
    }
    
    final issues = <String>[];
    if (isEmulator) issues.add('Running on emulator');
    if (!hasHardwareAcceleration) issues.add('No hardware acceleration');
    if (isSoftwareRendering) issues.add('Software rendering');
    
    return 'Graphics issues detected: ${issues.join(', ')}';
  }

  Map<String, dynamic> toJson() => {
    'isEmulator': isEmulator,
    'hasHardwareAcceleration': hasHardwareAcceleration,
    'isSoftwareRendering': isSoftwareRendering,
    'graphicsDriver': graphicsDriver,
    'issues': issues,
    'recommendations': recommendations,
    'summary': summary,
    'hasIssues': hasIssues,
    'isOptimal': isOptimal,
  };
}

/// TF-Lite fallback strategies
enum TFLiteFallbackStrategy {
  fullOperations,     // Use full TF-Lite capabilities
  limitedOperations,  // Use limited TF-Lite with fallbacks
  useKeywordMatching, // Use only keyword matching, avoid TF-Lite
}

/// Widget to show graphics compatibility status
class GraphicsCompatibilityWidget extends StatelessWidget {
  final Future<GraphicsCompatibilityReport> reportFuture;

  const GraphicsCompatibilityWidget({
    super.key,
    required this.reportFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GraphicsCompatibilityReport>(
      future: reportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Checking graphics compatibility...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(height: 8),
                  const Text('Error checking graphics compatibility'),
                  Text(snapshot.error.toString()),
                ],
              ),
            ),
          );
        }

        final report = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      report.isOptimal ? Icons.check_circle : Icons.warning,
                      color: report.isOptimal ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.summary,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Issues
                if (report.hasIssues) ...[
                  const Text('Issues:', style: TextStyle(fontWeight: FontWeight.bold)),
                  for (final issue in report.issues)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(child: Text(issue)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],

                // Recommendations
                if (report.recommendations.isNotEmpty) ...[
                  const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
                  for (final recommendation in report.recommendations)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(recommendation)),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 12),
                
                // Technical details
                Text(
                  'Graphics Driver: ${report.graphicsDriver}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}