import 'package:flutter_test/flutter_test.dart';
import 'package:vitalaid/services/tf_chatbot_service.dart';

void main() {
  group('TFChatbotService ML Integration', () {
    late TFChatbotService chatbotService;

    setUp(() {
      chatbotService = TFChatbotService();
    });

    test('should initialize successfully', () async {
      await chatbotService.initialize();
      
      expect(chatbotService.isInitialized, true);
    });

    test('should process CPR query correctly', () async {
      await chatbotService.initialize();
      
      final response = await chatbotService.processQuery('How to perform CPR?');
      
      expect(response, isNotEmpty);
      expect(response, contains('CPR'));
      expect(response, contains('Cardiopulmonary Resuscitation'));
    });

    test('should process bleeding query correctly', () async {
      await chatbotService.initialize();
      
      final response = await chatbotService.processQuery('How to stop bleeding?');
      
      expect(response, isNotEmpty);
      expect(response.contains('bleeding') || response.contains('blood'), true);
    });

    test('should process choking query correctly', () async {
      await chatbotService.initialize();
      
      final response = await chatbotService.processQuery('What to do when someone is choking?');
      
      expect(response, isNotEmpty);
      expect(response.contains('choking') || response.contains('airway'), true);
    });

    test('should provide fallback response for unknown queries', () async {
      await chatbotService.initialize();
      
      final response = await chatbotService.processQuery('Random unrelated query xyz');
      
      expect(response, isNotEmpty);
      expect(response, contains('Medical Assistant'));
    });

    test('should have correct categories', () {
      final categories = chatbotService.categories;
      
      expect(categories, contains('emergency_cpr'));
      expect(categories, contains('bleeding_control'));
      expect(categories, contains('choking_airway'));
      expect(categories, contains('general_first_aid'));
    });

    test('should handle cache clearing', () async {
      await chatbotService.initialize();
      
      // Should not throw any exceptions
      expect(() async => await chatbotService.clearCache(), returnsNormally);
    });

    test('should process snake bite query correctly', () async {
      await chatbotService.initialize();
      
      final response = await chatbotService.processQuery('snake bite');
      
      expect(response, isNotEmpty);
      expect(response.contains('snake') || response.contains('poison') || response.contains('bite'), true);
      expect(response, contains('911'));
    });

    test('should process spider bite query correctly', () async {
      await chatbotService.initialize();
      
      final response = await chatbotService.processQuery('spider bite what to do');
      
      expect(response, isNotEmpty);
      expect(response.contains('spider') || response.contains('poison') || response.contains('bite'), true);
    });
  });
}