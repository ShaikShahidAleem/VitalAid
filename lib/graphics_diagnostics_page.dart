import 'package:flutter/material.dart';
import 'services/graphics_compatibility_service.dart';

/// Diagnostic page for checking graphics compatibility and OpenGL ES issues
class GraphicsDiagnosticsPage extends StatefulWidget {
  const GraphicsDiagnosticsPage({super.key});

  @override
  State<GraphicsDiagnosticsPage> createState() => _GraphicsDiagnosticsPageState();
}

class _GraphicsDiagnosticsPageState extends State<GraphicsDiagnosticsPage> {
  Future<GraphicsCompatibilityReport>? _reportFuture;
  bool _isRunningDiagnostics = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunningDiagnostics = true;
      _reportFuture = GraphicsCompatibilityService.checkCompatibility();
    });

    await _reportFuture;
    
    setState(() {
      _isRunningDiagnostics = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphics Diagnostics'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunningDiagnostics ? null : _runDiagnostics,
            tooltip: 'Re-run diagnostics',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'OpenGL ES Compatibility Check',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This diagnostic tool checks if your device/emulator supports the graphics features required by TF-Lite operations.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main diagnostics widget
            GraphicsCompatibilityWidget(reportFuture: _reportFuture!),

            const SizedBox(height: 16),

            // Common solutions
            _buildCommonSolutionsCard(),

            const SizedBox(height: 16),

            // Emulator-specific instructions
            _buildEmulatorInstructionsCard(),

            const SizedBox(height: 16),

            // Test buttons
            _buildTestButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonSolutionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Common Solutions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Try these solutions in order:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildSolutionStep(
              '1. Enable Hardware Acceleration',
              'In Android Studio: Tools → AVD Manager → Edit AVD → Advanced Settings → Enable "Use Host GPU"',
            ),
            
            _buildSolutionStep(
              '2. Update Graphics Drivers',
              'Update your graphics drivers on your development machine (NVIDIA, AMD, or Intel)',
            ),
            
            _buildSolutionStep(
              '3. Use Different Emulator Image',
              'Try "Google APIs" image instead of "Google Play" image',
            ),
            
            _buildSolutionStep(
              '4. Increase Emulator RAM',
              'Allocate at least 2GB RAM to the emulator in AVD settings',
            ),
            
            _buildSolutionStep(
              '5. Try Physical Device',
              'For testing graphics-intensive features, consider using a physical Android device',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmulatorInstructionsCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.computer, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Emulator Setup Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              'Detailed steps to fix emulator graphics issues:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildEmulatorStep(
              '1. Open Android Virtual Device (AVD) Manager',
              '• Android Studio → Tools → AVD Manager\n• Or use: flutter emulator --launch <emulator_name>',
            ),
            
            _buildEmulatorStep(
              '2. Edit Your AVD',
              '• Click the "Edit" (pencil) icon for your emulator\n• This opens the AVD configuration',
            ),
            
            _buildEmulatorStep(
              '3. Enable Hardware Acceleration',
              '• Click "Show Advanced Settings"\n• Scroll to "Emulated Performance"\n• Set "Graphics" to "Hardware - GLES 2.0"\n• Enable "Use Host GPU"',
            ),
            
            _buildEmulatorStep(
              '4. Allocate More RAM',
              '• In "Emulated Performance" → "RAM"\n• Set to 2048 MB or higher\n• Enable "VM Heap" of at least 512 MB',
            ),
            
            _buildEmulatorStep(
              '5. Save and Restart',
              '• Click "Finish" to save changes\n• Cold boot the emulator (not just restart)\n• Wait for full boot before testing',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmulatorStep(String title, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Testing & Verification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunningDiagnostics ? null : _runDiagnostics,
                    icon: _isRunningDiagnostics 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                    label: const Text('Re-run Diagnostics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showTFTestDialog(),
                    icon: const Icon(Icons.smart_toy),
                    label: const Text('Test TF-Lite'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'After applying fixes, run diagnostics again to verify improvements.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTFTestDialog() async {
    final report = await GraphicsCompatibilityService.checkCompatibility();
    final isSafe = await GraphicsCompatibilityService.isTFLiteSafe();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('TF-Lite Test Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSafe ? Icons.check_circle : Icons.warning,
                  color: isSafe ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isSafe ? 'TF-Lite should work properly' : 'TF-Lite may have issues',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSafe ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Environment: ${report.graphicsDriver}'),
            Text('Emulator: ${report.isEmulator ? "Yes" : "No"}'),
            Text('Hardware Acceleration: ${report.hasHardwareAcceleration ? "Yes" : "No"}'),
            Text('Software Rendering: ${report.isSoftwareRendering ? "Yes" : "No"}'),
            const SizedBox(height: 12),
            if (!isSafe) ...[
              Text(
                'Recommendations:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              ...report.recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• $rec'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}