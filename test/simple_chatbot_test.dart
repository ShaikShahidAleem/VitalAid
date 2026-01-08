import 'package:flutter_test/flutter_test.dart';
import 'package:vitalaid/services/simple_chatbot_service.dart';

void main() {
  group('SimpleChatbotService Tests', () {
    late SimpleChatbotService service;

    setUp(() {
      service = SimpleChatbotService();
    });

    test('should initialize successfully', () async {
      expect(service.isInitialized, false);
      expect(service.isLoading, false);

      await service.initialize();

      expect(service.isInitialized, true);
      expect(service.isLoading, false);
    });

    test('should process CPR query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('How to perform CPR?');

      expect(response, contains('CPR'));
      expect(response, contains('Cardiac Emergency'));
      expect(response, contains('Step-by-step instructions'));
      expect(response, contains('Call 911 immediately'));
    });

    test('should process bleeding query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('How to stop bleeding?');

      expect(response, contains('Bleeding Control'));
      expect(response, contains('Apply direct pressure'));
      expect(response, contains('Step-by-step instructions'));
    });

    test('should process choking query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('What to do when choking?');

      expect(response, contains('Airway Obstruction'));
      expect(response, contains('Choking Response'));
      expect(response, contains('back blows'));
    });

    test('should process burn query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('How to treat burns?');

      expect(response, contains('Burn Treatment'));
      expect(response, contains('cool running water'));
    });

    test('should process heart attack query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('Heart attack symptoms');

      expect(response, contains('Cardiac Event'));
      expect(response, contains('Heart Attack Response'));
      expect(response, contains('Call 911 immediately'));
    });

    test('should process stroke query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('Stroke symptoms');

      expect(response, contains('Neurological Emergency'));
      expect(response, contains('FAST Method'));
      expect(response, contains('Face drooping'));
    });

    test('should process seizure query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('Seizure first aid');

      expect(response, contains('Seizure Management'));
      expect(response, contains('Stay calm and time the seizure'));
      expect(response, contains('Do not restrain'));
    });

    test('should process allergic reaction query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('Allergic reaction');

      expect(response, contains('Allergic Reaction'));
      expect(response, contains('Remove allergen if possible'));
      expect(response, contains('EpiPen'));
    });

    test('should process diabetic emergency query correctly', () async {
      await service.initialize();

      final response = await service.processQuery('Diabetic emergency');

      expect(response, contains('Diabetic Emergency'));
      expect(response, contains('Hypoglycemia'));
      expect(response, contains('blood sugar'));
    });

    test('should return general response for unknown queries', () async {
      await service.initialize();

      final response = await service.processQuery('Random unrelated question');

      expect(response, contains('VitalAid Medical Assistant'));
      expect(response, contains('first aid and emergency medical guidance'));
      expect(response, contains('What specific medical situation'));
    });

    test('should handle case-insensitive queries', () async {
      await service.initialize();

      final response1 = await service.processQuery('CPR');
      final response2 = await service.processQuery('cpr');
      final response3 = await service.processQuery('Cpr');

      expect(response1, contains('CPR'));
      expect(response2, contains('CPR'));
      expect(response3, contains('CPR'));
    });

    test('should handle partial keyword matches', () async {
      await service.initialize();

      final response = await service.processQuery('cardiac arrest');

      expect(response, contains('Cardiac Emergency'));
      expect(response, contains('CPR'));
    });

    test('should maintain loading state during processing', () async {
      await service.initialize();

      // Start processing
      final future = service.processQuery('CPR');
      expect(service.isLoading, true);

      await future;
      expect(service.isLoading, false);
    });

    test('should provide comprehensive medical guidance', () async {
      await service.initialize();

      final response = await service.processQuery('emergency');

      // Should include multiple medical categories
      expect(response, contains('Cardiac Emergencies'));
      expect(response, contains('Bleeding Control'));
      expect(response, contains('Airway Issues'));
      expect(response, contains('Burn Treatment'));
      expect(response, contains('Neurological'));
    });

    test('should include emergency warnings in critical responses', () async {
      await service.initialize();

      final cprResponse = await service.processQuery('CPR');
      final bleedingResponse = await service.processQuery('bleeding');

      // Both should have emergency warnings
      expect(cprResponse, contains('🚨 EMERGENCY: Call 911 immediately'));
      expect(bleedingResponse, contains('🚨 EMERGENCY: Call 911 immediately'));
    });

    test('should include important safety notes', () async {
      await service.initialize();

      final response = await service.processQuery('CPR');

      expect(response, contains('⚠️ Important Notes'));
      expect(response, contains('Never perform CPR on someone breathing normally'));
    });

    test('should handle empty query gracefully', () async {
      await service.initialize();

      final response = await service.processQuery('');

      expect(response, isNotEmpty);
      expect(response, contains('VitalAid Medical Assistant'));
    });

    test('should handle whitespace-only queries', () async {
      await service.initialize();

      final response = await service.processQuery('   ');

      expect(response, isNotEmpty);
      expect(response, contains('VitalAid Medical Assistant'));
    });
  });

  group('Keyword Matching Tests', () {
    late SimpleChatbotService service;

    setUp(() {
      service = SimpleChatbotService();
    });

    test('should match CPR-related keywords', () async {
      await service.initialize();

      final keywords = ['cpr', 'cardiac arrest', 'heart stopped', 'no pulse', 'unconscious', 'not breathing'];

      for (final keyword in keywords) {
        final response = await service.processQuery(keyword);
        expect(response, contains('Cardiac Emergency'));
      }
    });

    test('should match bleeding-related keywords', () async {
      await service.initialize();

      final keywords = ['bleed', 'bleeding', 'blood loss', 'cut', 'wound', 'hemorrhage', 'laceration'];

      for (final keyword in keywords) {
        final response = await service.processQuery(keyword);
        expect(response, contains('Bleeding Control'));
      }
    });

    test('should match choking-related keywords', () async {
      await service.initialize();

      final keywords = ['choke', 'choking', 'airway', 'blockage', "can't breathe", 'throat', 'heimlich'];

      for (final keyword in keywords) {
        final response = await service.processQuery(keyword);
        expect(response, contains('Airway Obstruction'));
      }
    });
  });

  group('Response Quality Tests', () {
    late SimpleChatbotService service;

    setUp(() {
      service = SimpleChatbotService();
    });

    test('should provide step-by-step instructions', () async {
      await service.initialize();

      final response = await service.processQuery('CPR');

      // Should have numbered steps
      expect(RegExp(r'\d+\.').hasMatch(response), true);
      expect(response, contains('Step-by-step instructions'));
    });

    test('should include emergency contact information', () async {
      await service.initialize();

      final response = await service.processQuery('emergency');

      expect(response, contains('Call 911'));
    });

    test('should use consistent formatting', () async {
      await service.initialize();

      final cprResponse = await service.processQuery('CPR');
      final bleedingResponse = await service.processQuery('bleeding');

      // Both should have similar structure
      expect(cprResponse, contains('🏥 **VitalAid Medical Assistant**'));
      expect(bleedingResponse, contains('🏥 **VitalAid Medical Assistant**'));

      expect(cprResponse, contains('**Step-by-step instructions:**'));
      expect(bleedingResponse, contains('**Step-by-step instructions:**'));
    });

    test('should provide additional help prompts', () async {
      await service.initialize();

      final response = await service.processQuery('CPR');

      expect(response, contains('Need more help'));
    });
  });
}