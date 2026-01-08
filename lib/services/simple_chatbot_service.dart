import 'package:flutter/material.dart';

/// Simple, reliable chatbot service that works immediately
/// Provides instant medical guidance without complex dependencies
class SimpleChatbotService extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isLoading = false;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();
    
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
    
    print('Simple Chatbot Service initialized successfully');
  }

  /// Process user query with instant responses
  Future<String> processQuery(String query) async {
    if (!_isInitialized) {
      await initialize();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      final response = _generateResponse(query);
      return response;
    } catch (e) {
      return _getErrorResponse();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate contextual response based on query
  String _generateResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // CPR/Cardiac Emergency
    if (_containsAny(lowerQuery, ['cpr', 'cardiac arrest', 'heart stopped', 'no pulse', 'unconscious', 'not breathing'])) {
      return '''
🫀 **Cardiac Emergency Response**

**CPR (Cardiopulmonary Resuscitation)**

**Step-by-step instructions:**
1. Check responsiveness and breathing
2. Call 911 immediately
3. Place hands on center of chest
4. Push hard and fast at least 2 inches deep
5. Allow complete chest recoil
6. 100-120 compressions per minute
7. Give 2 rescue breaths after 30 compressions
8. Continue until help arrives

**⚠️ Important Notes:**
Never perform CPR on someone breathing normally. Use AED if available.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Bleeding Control
    if (_containsAny(lowerQuery, ['bleed', 'bleeding', 'blood loss', 'cut', 'wound', 'hemorrhage', 'laceration'])) {
      return '''
🩸 **Bleeding Control Protocol**

**Severe Bleeding Control**

**Step-by-step instructions:**
1. Apply direct pressure with clean cloth
2. Elevate bleeding area above heart level
3. Add more bandages if blood soaks through
4. Apply pressure to pressure points if needed
5. Secure bandages firmly
6. Treat for shock
7. Seek immediate medical help

**⚠️ Important Notes:**
Do not remove embedded objects. Call 911 for severe bleeding.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Choking
    if (_containsAny(lowerQuery, ['choke', 'choking', 'airway', 'blockage', "can't breathe", 'throat', 'heimlich'])) {
      return '''
🫁 **Airway Obstruction Response**

**Choking Response**

**Step-by-step instructions:**
1. Ask "Are you choking?"
2. If person can cough, encourage coughing
3. If unable to speak: Stand behind, support chest
4. Give 5 firm back blows between shoulder blades
5. If unsuccessful, give 5 abdominal thrusts
6. Alternate until object is expelled
7. Begin CPR if person becomes unconscious

**⚠️ Important Notes:**
For infants under 1 year: Use back blows and chest thrusts instead.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Burns
    if (_containsAny(lowerQuery, ['burn', 'burns', 'fire', 'scald', 'hot', 'thermal injury'])) {
      return '''
🔥 **Burn Treatment Protocol**

**Burn Treatment**

**Step-by-step instructions:**
1. Remove person from heat source immediately
2. Cool burn with cool (not cold) running water for 10-20 minutes
3. Remove jewelry near burn area before swelling occurs
4. Cover with clean, dry cloth or sterile bandage
5. Do not break blisters or apply ice, butter, or ointments
6. Monitor for shock and treat accordingly
7. Seek medical attention for severe burns

**⚠️ Important Notes:**
Do not apply ice directly to burns. For chemical burns, brush off dry chemical before flushing with water.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Heart Attack
    if (_containsAny(lowerQuery, ['heart attack', 'chest pain', 'cardiac', 'angina', 'chest pressure'])) {
      return '''
❤️ **Cardiac Event Response**

**Heart Attack Response**

**Step-by-step instructions:**
1. Call 911 immediately
2. Help person rest in comfortable position
3. Loosen tight clothing
4. Give aspirin if person is not allergic (chew, don't swallow)
5. Monitor breathing and consciousness
6. Be prepared to perform CPR if needed
7. Stay with person until help arrives

**⚠️ Important Notes:**
Time is critical. Every minute counts in a heart attack. Do not drive to hospital yourself.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Stroke
    if (_containsAny(lowerQuery, ['stroke', 'brain', 'neurological', 'face drooping', 'arm weakness', 'speech'])) {
      return '''
🧠 **Neurological Emergency**

**Stroke Response (FAST Method)**

**Step-by-step instructions:**
1. **F**ace: Ask person to smile - does one side droop?
2. **A**rms: Ask person to raise both arms - does one drift down?
3. **S**peech: Ask person to repeat a phrase - is speech slurred?
4. **T**ime: Call 911 immediately if any signs present

**Additional steps:**
5. Note time symptoms started
6. Keep person calm and still
7. Do not give food, water, or medication
8. Monitor breathing and consciousness

**⚠️ Important Notes:**
Time-critical treatment window. Act FAST - every minute counts for brain tissue.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Seizures
    if (_containsAny(lowerQuery, ['seizure', 'convulsion', 'epilepsy', 'fit', 'tremoring'])) {
      return '''
⚡ **Seizure Response**

**Seizure Management**

**Step-by-step instructions:**
1. Stay calm and time the seizure
2. Clear area of dangerous objects
3. Do not restrain or put anything in mouth
4. Turn person on side to keep airway clear
5. Stay with person until they recover
6. Comfort and reassure person after seizure
7. Call 911 if seizure lasts more than 5 minutes

**⚠️ Important Notes:**
Never put anything in a person's mouth during a seizure. They will not swallow their tongue.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Allergic Reaction
    if (_containsAny(lowerQuery, ['allergy', 'allergic', 'anaphylaxis', 'hives', 'swelling', 'rash'])) {
      return '''
🤧 **Allergic Reaction Protocol**

**Allergic Reaction Response**

**Step-by-step instructions:**
1. Remove allergen if possible
2. Call 911 for severe reactions
3. For mild reactions: Give antihistamine if available
4. For severe reactions: Use EpiPen if prescribed
5. Monitor breathing closely
6. Keep person calm and still
7. Be prepared for worsening symptoms

**⚠️ Important Notes:**
Anaphylaxis can be life-threatening. Symptoms include difficulty breathing, swelling of face/throat, rapid pulse, dizziness.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // Diabetic Emergency
    if (_containsAny(lowerQuery, ['diabetes', 'blood sugar', 'insulin', 'hypoglycemia', 'diabetic'])) {
      return '''
🩸 **Diabetic Emergency**

**Diabetes Management**

**For Low Blood Sugar (Hypoglycemia):**
1. Give quick-acting sugar (juice, glucose tablets)
2. Wait 15 minutes and recheck blood sugar
3. If still low, give more sugar
4. Give protein snack once blood sugar rises
5. Seek medical attention if unconscious

**For High Blood Sugar (Hyperglycemia):**
1. Check blood sugar and ketones
2. Give insulin as prescribed
3. Encourage water intake
4. Monitor for improvement
5. Seek medical attention if no improvement

**⚠️ Important Notes:**
Know the person's diabetes management plan. Hypoglycemia can lead to unconsciousness quickly.

**🚨 EMERGENCY: Call 911 immediately if:**
- Person is unconscious or not breathing normally
- Severe bleeding that won't stop
- Signs of shock (pale skin, rapid pulse, confusion)
- Symptoms worsen or don't improve

**Need more help?** I can provide additional guidance on related topics.
''';
    }

    // General First Aid
    return '''
🏥 **VitalAid Medical Assistant**

I'm here to help with first aid and emergency medical guidance. I can assist with:

🫀 **Cardiac Emergencies** - CPR, heart attacks, cardiac arrest
🩸 **Bleeding Control** - Cuts, wounds, hemorrhage
🫁 **Airway Issues** - Choking, breathing difficulties  
🔥 **Burn Treatment** - Thermal, chemical, electrical burns
🦴 **Injuries** - Fractures, sprains, dislocations
🧠 **Neurological** - Strokes, seizures, head injuries
🩸 **Medical Conditions** - Diabetes, allergic reactions

**For immediate life-threatening emergencies, always call 911.**

What specific medical situation can I help you with?
''';
  }

  /// Helper method to check if query contains any of the keywords
  bool _containsAny(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword));
  }

  /// Error response
  String _getErrorResponse() {
    return '''
🏥 **VitalAid Medical Assistant**

I apologize, but I encountered an error processing your request. Please try rephrasing your question or ask about:

🫀 **Cardiac Emergencies** - CPR, heart attacks
🩸 **Bleeding Control** - Cuts, wounds
🫁 **Airway Issues** - Choking, breathing
🔥 **Burn Treatment** - Burns, scalds
🦴 **Injuries** - Fractures, sprains
🧠 **Neurological** - Strokes, seizures
🩸 **Medical Conditions** - Diabetes, allergies

For emergencies, always call 911 immediately.
''';
  }

  // Public API Methods
  Future<void> clearCache() async {
    // No cache to clear in simple implementation
    notifyListeners();
  }

  void addProcedure(dynamic procedure) {
    // Not applicable in simple implementation
  }

  List<dynamic> getCachedProcedures() {
    // Return empty list in simple implementation
    return [];
  }
}