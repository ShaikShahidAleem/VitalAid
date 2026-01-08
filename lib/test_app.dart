import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/tf_chatbot_service.dart';

/// Test-friendly version of MyApp that doesn't require Firebase initialization
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TFChatbotService()),
      ],
      child: MaterialApp(
        title: 'VitalAid (Test)',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 126, 239)),
        ),
        home: const Scaffold(
          body: Center(
            child: Text('VitalAid Test App'),
          ),
        ),
      ),
    );
  }
}