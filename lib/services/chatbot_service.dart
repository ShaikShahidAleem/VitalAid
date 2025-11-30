import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String? _apiKey;

  // Cache for offline responses
  final Map<String, String> _responseCache = {};

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  // Predefined first aid responses for offline mode
  final Map<String, String> _firstAidResponses = {
    'cpr': '''
**CPR (Cardiopulmonary Resuscitation) Steps:**

1. **Check Responsiveness:** Tap the person's shoulders and shout "Are you okay?"

2. **Call Emergency:** If no response, call 911 immediately

3. **Position:** Place the person on their back on a firm surface

4. **Hand Placement:** 
   - Place heel of one hand on center of chest between nipples
   - Place other hand on top, interlacing fingers

5. **Compressions:**
   - Push hard and fast at least 2 inches deep
   - Allow complete chest recoil
   - 100-120 compressions per minute

6. **Rescue Breaths (if trained):**
   - Tilt head back, lift chin
   - Pinch nose, cover mouth with your mouth
   - Give 2 breaths after 30 compressions

7. **Continue:** Repeat cycles of 30 compressions and 2 breaths until help arrives

**IMPORTANT:** Never perform CPR on someone who is breathing normally.
''',
    'bleeding': '''
**Controlling Bleeding:**

1. **Direct Pressure:**
   - Apply firm pressure directly on the wound with clean cloth/gauze
   - Do NOT remove blood-soaked material, add more on top

2. **Elevate:** If possible, raise the bleeding area above heart level

3. **Pressure Points:** If bleeding continues, apply pressure to nearest artery

4. **Tourniquet (extreme cases only):**
   - Use as last resort for life-threatening limb bleeding
   - Place 2-3 inches above wound, never on joint
   - Tighten until bleeding stops, note time

**Seek immediate medical help for:**
- Heavy bleeding that doesn't stop in 10-15 minutes
- Deep cuts or wounds
- Bleeding from head, neck, or torso
- Signs of shock (pale skin, rapid pulse, confusion)
''',
    'choking': '''
**Choking Response:**

**For Adults & Children (Conscious):**

1. **Ask:** "Are you choking?"

2. **Heimlich Maneuver:**
   - Stand behind person
   - Place arms around waist
   - Make fist, place thumb side against stomach
   - Grasp fist with other hand
   - Give quick, upward thrusts

3. **Repeat:** Continue until object is expelled or person becomes unconscious

**For Infants (Under 1 year):**
1. Support infant's head and neck
2. Place face-down on your forearm, head lower than chest
3. Give 5 back blows between shoulder blades
4. Turn face-up, give 5 chest thrusts
5. Continue alternating

**Call 911 immediately if:**
- Person cannot speak, cough, or breathe
- Person becomes unconscious
- Object is not expelled after several attempts
''',
    'burns': '''
**Burn First Aid:**

**1st Degree (Minor):**
- Red, painful, no blisters
- Cool with running water for 10-20 minutes
- Apply aloe vera gel
- Do NOT break blisters

**2nd Degree (Moderate):**
- Red, painful, with blisters
- Cool with water, do NOT break blisters
- Apply sterile, non-stick bandage
- Seek medical attention for large areas

**3rd Degree (Severe):**
- White/charred, may be painless (nerve damage)
- DO NOT remove clothing stuck to skin
- Cover with clean, dry cloth
- Call 911 immediately

**Never use:** Ice, butter, oils, or home remedies on burns.
''',
    'heart attack': '''
**Heart Attack Warning Signs:**

**Call 911 Immediately if person has:**
- Chest pain or pressure lasting more than 5 minutes
- Pain spreading to arm, jaw, neck, or back
- Shortness of breath
- Cold sweat, nausea, vomiting
- Dizziness or lightheadedness

**What to do:**
1. Call 911 - Don't wait
2. Have person sit down and rest
3. Loosen tight clothing
4. If conscious, give aspirin (if no allergies)
5. If unconscious and no pulse, start CPR

**Remember:** Time is critical. Quick action can save lives.
''',
    'fracture': '''
**Suspected Fracture:**

**DO NOT:**
- Move the injured person unnecessarily
- Try to realign the bone
- Remove clothing unless necessary for treatment

**DO:**
1. Immobilize the area:
   - Support above and below injury
   - Use splints if available
   - Do not secure directly over fracture

2. Control bleeding with direct pressure
3. Apply ice wrapped in cloth (not directly on skin)
4. Elevate if possible

**Seek immediate medical attention for:**
- Open fractures (bone visible)
- Severe deformity
- Loss of pulse or sensation
- Suspected spinal injury
- Multiple fractures
''',
    'emergency': '''
**General Emergency Response:**

**Step 1: Assess the Situation**
- Ensure scene is safe
- Check for dangers to yourself and victim

**Step 2: Call for Help**
- Call 911 for serious injuries
- Provide clear information about:
  - Location
  - Nature of emergency
  - Number of people involved
  - Your contact information

**Step 3: Provide Care**
- Life-threatening conditions first
- Keep person calm and still
- Monitor breathing and consciousness

**Step 4: Document**
- Note time of injury
- What happened
- Treatment provided
- Any changes in condition
''',
  };

  ChatbotService() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Check internet connectivity
    await _checkConnectivity();
    
    // Load cached responses
    await _loadCache();
    
    // Test API key if online
    if (_isOnline) {
      await _testApiKey();
    } else {
      // If offline, we'll rely on offline responses initially
      print('Starting in offline mode, will test API when connection available');
    }
    
    // Add welcome message
    _addWelcomeMessage();
    
    notifyListeners();
  }

  String _getApiKey() {
    // First try to get from environment, fallback to embedded key
    // In production, you'd want to get this from secure configuration
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AIzaSyA3IVcHxJphI9O5-SOws7_cj7az8XURNbo');
    return apiKey;
  }

  Future<void> _testApiKey() async {
    try {
      print('Testing API key...');
      // Use environment variable or fallback to embedded key
      final apiKey = _getApiKey();
      if (apiKey.isEmpty) {
        print('No API key available, staying offline');
        _isOnline = false;
        return;
      }
      
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      
      // Use a simpler test prompt
      final response = await model.generateContent([Content.text('Hi')]);
      
      if (response.text != null && response.text!.isNotEmpty) {
        print('API key test successful');
        _isOnline = true;
      } else {
        print('API key test failed: empty response');
        _isOnline = false;
      }
    } catch (e) {
      print('API key test failed: $e');
      print('Will use offline mode for now');
      _isOnline = false;
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      content: '''
🏥 **Welcome to VitalAid First Aid Assistant!**

I'm here to provide you with reliable first aid guidance and emergency medical information. Whether online or offline, I can help with:

🩺 **Essential First Aid** - CPR, bleeding control, burns, fractures
🚨 **Emergency Response** - Heart attacks, choking, breathing difficulties  
💊 **Medical Guidance** - When to seek professional help
🔄 **Always Available** - Ready to assist whenever you need me

**Important:** My guidance is for informational purposes only and should not replace professional medical advice. For serious emergencies, always call 911 immediately.

What first aid question can I help you with today?''',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(welcomeMessage);
  }

  Future<void> _checkConnectivity() async {
    try {
      // Try a more reliable connectivity check
      final result = await InternetAddress.lookup('www.google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print('Connectivity check: ${_isOnline ? "Online" : "Offline"}');
    } catch (e) {
      _isOnline = false;
      print('Connectivity check failed: $e');
    }
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString('chatbot_cache');
      if (cacheString != null) {
        final cacheData = json.decode(cacheString) as Map<String, dynamic>;
        _responseCache.addAll(cacheData.map((key, value) => 
          MapEntry(key, value.toString())
        ));
      }
    } catch (e) {
      print('Error loading cache: $e');
    }
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = json.encode(_responseCache);
      await prefs.setString('chatbot_cache', cacheString);
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  Future<String> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return '';

    _isLoading = true;
    notifyListeners();

    // Add user message
    _addMessage(userMessage, true);

    try {
      // Check cache first
      final cacheKey = userMessage.toLowerCase().trim();
      print('Cache key: $cacheKey, Cache available: ${_responseCache.containsKey(cacheKey)}');
      
      if (_responseCache.containsKey(cacheKey)) {
        print('Using cached response');
        _addMessage(_responseCache[cacheKey]!, false);
        _isLoading = false;
        notifyListeners();
        return _responseCache[cacheKey]!;
      }

      // Try to provide offline response first for common first aid queries
      final lowerMessage = userMessage.toLowerCase();
      String response;
      
      // Check if this is a common first aid question we can answer offline
      if (_isCommonFirstAidQuery(lowerMessage)) {
        print('Using offline response for common first aid query');
        response = _getLocalResponse(userMessage);
      } else {
        // Generate response based on connectivity and complexity
        print('Online status: $_isOnline');
        
        if (_isOnline) {
          print('Attempting online response...');
          try {
            response = await _getCloudResponse(userMessage);
            print('Online response successful');
          } catch (apiError) {
            print('Online response failed: $apiError, falling back to offline');
            // If online fails, try offline response
            response = _getLocalResponse(userMessage);
          }
        } else {
          print('Using offline response...');
          response = _getLocalResponse(userMessage);
        }
      }

      // Cache the response
      _responseCache[cacheKey] = response;
      await _saveCache();

      _addMessage(response, false);
      return response;
    } catch (e) {
      print('Error in sendMessage: $e');
      
      // Even in error case, try to provide helpful offline response
      final lowerMessage = userMessage.toLowerCase();
      if (_isCommonFirstAidQuery(lowerMessage)) {
        final offlineResponse = _getLocalResponse(userMessage);
        _addMessage(offlineResponse, false);
        return offlineResponse;
      }
      
      // Only show connection error as last resort
      final errorMessage = _getDetailedErrorResponse(e.toString());
      _addMessage(errorMessage, false);
      return errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _getCloudResponse(String message) async {
    print('Attempting to call Gemini API...');
    
    try {
      // Initialize Google Gemini with the configured API key
      final apiKey = _getApiKey();
      if (apiKey.isEmpty) {
        throw Exception('No API key available');
      }
      
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      print('Model initialized successfully');
      
      // Create the prompt - simplified for better compatibility
      final prompt = '''
${_getSystemPrompt()}

User Question: ${message}

Please provide a helpful first aid response.
''';

      final content = [Content.text(prompt)];
      
      print('Calling Gemini API...');
      final response = await model.generateContent(content);
      
      print('Gemini API response received');
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        print('Empty response from Gemini');
        throw Exception('Empty response from Gemini API');
      }
    } catch (e) {
      print('Gemini API Error: $e');
      print('Error type: ${e.runtimeType}');
      
      // Re-throw the exception so it gets caught by the outer catch block
      rethrow;
    }
  }

  bool _isCommonFirstAidQuery(String message) {
    final keywords = [
      'cpr', 'cardiac arrest', 'heart attack', 'chest pain',
      'bleed', 'bleeding', 'cut', 'wound', 'blood loss',
      'choke', 'choking', 'airway', 'breathing',
      'burn', 'burns', 'fire', 'scald',
      'break', 'broken', 'fracture', 'bone', 'sprain',
      'emergency', 'accident', 'first aid', '急救',
      'unconscious', 'seizure', 'convulsion',
      'poison', 'poisoning', 'overdose',
      'allergy', 'allergic', 'anaphylaxis',
      'diabetes', 'blood sugar', 'insulin',
      'stroke', 'brain', 'neurological',
      'asthma', 'breathing difficulty', 'respiratory'
    ];
    
    return keywords.any((keyword) => message.contains(keyword));
  }

  String _getLocalResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Check for specific first aid keywords
    if (lowerMessage.contains('cpr') || lowerMessage.contains('cardiac arrest')) {
      return _firstAidResponses['cpr']!;
    }
    
    if (lowerMessage.contains('bleed') || lowerMessage.contains('cut') || lowerMessage.contains('wound')) {
      return _firstAidResponses['bleeding']!;
    }
    
    if (lowerMessage.contains('choke') || lowerMessage.contains('airway')) {
      return _firstAidResponses['choking']!;
    }
    
    if (lowerMessage.contains('burn') || lowerMessage.contains('fire')) {
      return _firstAidResponses['burns']!;
    }
    
    if (lowerMessage.contains('heart attack') || lowerMessage.contains('chest pain')) {
      return _firstAidResponses['heart attack']!;
    }
    
    if (lowerMessage.contains('break') || lowerMessage.contains('fracture') || lowerMessage.contains('bone')) {
      return _firstAidResponses['fracture']!;
    }
    
    if (lowerMessage.contains('emergency') || lowerMessage.contains('accident')) {
      return _firstAidResponses['emergency']!;
    }

    // Generic offline response
    return '''
I'm currently offline and can only provide basic first aid information. 

For online assistance with more complex queries, please ensure you have an internet connection.

**Common topics I can help with offline:**
- CPR procedures
- Bleeding control
- Choking response
- Burn treatment
- Heart attack symptoms
- Fracture care

**For urgent medical emergencies, always call 911 immediately.**
''';
  }

  String _getSystemPrompt() {
    return '''
You are VitalAid AI, a professional first aid and emergency medical guidance assistant. Your role is to:

**Primary Responsibilities:**
1. Provide accurate first aid instructions for common emergencies
2. Give clear, step-by-step guidance
3. Emphasize safety and when to seek professional help
4. Be calm, reassuring, and authoritative

**Safety Guidelines:**
- Always recommend calling 911 for serious/life-threatening emergencies
- Advise seeking professional medical attention when uncertain
- Never provide definitive medical diagnoses
- Use simple, clear language
- Focus on immediate, life-saving interventions

**Response Format:**
- Use clear headings (## or **)
- Include numbered steps when appropriate
- Highlight important warnings
- Keep responses concise but complete

**Emergency Keywords to prioritize:**
- CPR, cardiac arrest, heart attack
- Bleeding, cuts, wounds, blood loss
- Choking, airway obstruction
- Burns, fire injuries
- Fractures, broken bones
- Seizures, unconsciousness

Always remind users that your guidance is informational and should not replace professional medical care.
''';
  }

  String _getErrorResponse(String error) {
    return '''
🤖 **I'm here to help with first aid guidance!**

I'm currently using my offline knowledge base to provide you with basic first aid information. I can help with:

✅ **CPR procedures**
✅ **Bleeding control**  
✅ **Choking response**
✅ **Burn treatment**
✅ **Emergency response steps**
✅ **Heart attack symptoms**
✅ **Fracture care**

**For urgent medical emergencies, always call 911 immediately.**

What first aid topic would you like help with?
''';
  }

  String _getDetailedErrorResponse(String error) {
    return '''
🏥 **First Aid Assistant Ready**

I'm powered by an offline knowledge base with comprehensive first aid guidance!

**Popular first aid topics I can help with:**
• "How to perform CPR?"
• "What to do for bleeding?"
• "How to help someone choking?"
• "What are heart attack symptoms?"
• "How to treat burns?"
• "What to do in an emergency?"

**For immediate life-threatening emergencies, always call 911.**

What specific first aid question do you have?
''';
  }

  void _addMessage(String content, bool isUser) {
    final message = ChatMessage(
      content: content,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  void clearCache() {
    _responseCache.clear();
    _saveCache();
    notifyListeners();
  }

  Future<void> refreshConnectivity() async {
    await _checkConnectivity();
    notifyListeners();
  }

  int get cachedResponsesCount => _responseCache.length;
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}