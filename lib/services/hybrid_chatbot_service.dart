import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Simplified Hybrid Classification + Knowledge Base Implementation
/// This demonstrates the architecture without TF-Lite dependencies
/// 
/// Full implementation requires:
/// - pubspec.yaml: sqflite: ^2.3.0, tflite_flutter: ^0.10.4
/// - Model files: assets/models/medical_classifier.tflite
/// - TF-Lite runtime setup

class HybridChatbotService extends ChangeNotifier {
  // Medical categories for classification
  static const List<String> _medicalCategories = [
    'emergency_cpr',
    'bleeding_control', 
    'choking_airway',
    'burns_treatment',
    'fractures_injury',
    'heart_attack',
    'stroke_neurological',
    'poisoning_toxic',
    'allergic_reaction',
    'diabetic_emergency',
    'seizures_convulsions',
    'general_first_aid'
  ];

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Enhanced knowledge base
  final Map<String, MedicalProcedure> _procedureDatabase = {};
  final Map<String, List<String>> _categoryKeywords = {};
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get categories => _medicalCategories;

  /// Initialize the hybrid system
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Build keyword mappings
      await _buildCategoryKeywords();
      
      // Initialize knowledge base
      await _initializeKnowledgeBase();

      _isInitialized = true;
      _error = null;
      print('Hybrid Chatbot initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize: $e';
      print('Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Process user query through hybrid system
  Future<String> processQuery(String query) async {
    if (!_isInitialized) {
      await initialize();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Classify the query using keyword matching
      final classification = await _classifyQuery(query);
      
      // Step 2: Search knowledge base
      final procedures = _searchProcedures(classification.category, query);
      
      // Step 3: Generate response
      final response = _generateResponse(classification, procedures, query);
      
      return response;
    } catch (e) {
      _error = 'Query processing failed: $e';
      return _getFallbackResponse();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Query Classification using enhanced keyword matching
  Future<QueryClassification> _classifyQuery(String query) async {
    final lowerQuery = query.toLowerCase();
    double maxConfidence = 0.0;
    String bestCategory = 'general_first_aid';
    String? matchedKeyword;
    
    // Score each category based on keyword matches
    for (final category in _medicalCategories) {
      final keywords = _categoryKeywords[category] ?? [];
      
      for (final keyword in keywords) {
        if (lowerQuery.contains(keyword)) {
          // Calculate confidence based on keyword specificity and frequency
          final confidence = _calculateKeywordConfidence(keyword, lowerQuery);
          if (confidence > maxConfidence) {
            maxConfidence = confidence;
            bestCategory = category;
            matchedKeyword = keyword;
          }
        }
      }
    }
    
    return QueryClassification(
      category: bestCategory,
      confidence: maxConfidence,
      matchedKeyword: matchedKeyword,
    );
  }

  /// Calculate keyword confidence score
  double _calculateKeywordConfidence(String keyword, String query) {
    // Base confidence on keyword length and specificity
    double baseScore = math.min(keyword.length / 10.0, 1.0);
    
    // Boost for exact matches
    if (query.contains(keyword)) {
      baseScore *= 1.2;
    }
    
    // Boost for multi-word medical terms
    if (keyword.contains(' ')) {
      baseScore *= 1.1;
    }
    
    // Emergency terms get highest confidence
    if (_isEmergencyKeyword(keyword)) {
      baseScore *= 1.3;
    }
    
    return math.min(baseScore, 1.0);
  }

  /// Search procedures in knowledge base
  List<MedicalProcedure> _searchProcedures(String category, String query) {
    final results = <MedicalProcedure>[];
    
    // Primary search: category-based
    for (final procedure in _procedureDatabase.values) {
      if (procedure.category == category && procedure.confidenceScore >= 0.7) {
        results.add(procedure);
      }
    }
    
    // Secondary search: keyword-based if needed
    if (results.length < 2) {
      final keywords = query.toLowerCase().split(RegExp(r'\\s+'));
      
      for (final procedure in _procedureDatabase.values) {
        if (results.contains(procedure)) continue;
        
        final hasKeyword = procedure.keywords.any((keyword) => 
          keywords.any((queryWord) => 
            queryWord.length > 3 && keyword.contains(queryWord)
          )
        );
        
        if (hasKeyword && procedure.confidenceScore >= 0.5) {
          results.add(procedure);
        }
      }
    }
    
    // Sort by confidence score
    results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    
    return results.take(3).toList();
  }

  /// Generate contextual response
  String _generateResponse(
    QueryClassification classification,
    List<MedicalProcedure> procedures,
    String originalQuery
  ) {
    if (procedures.isEmpty) {
      return _getFallbackResponse();
    }

    final primaryProcedure = procedures.first;
    
    // Build response based on procedure data
    final buffer = StringBuffer();
    
    // Header with confidence indicator
    buffer.writeln('🏥 **VitalAid Medical Assistant**');
    if (classification.matchedKeyword != null) {
      buffer.writeln('_Found relevant information for: "${classification.matchedKeyword}"_');
    }
    buffer.writeln('');
    
    // Category-specific introduction
    buffer.writeln(_getCategoryIntroduction(classification.category));
    buffer.writeln('');
    
    // Main procedure steps
    buffer.writeln('**${primaryProcedure.name}**');
    buffer.writeln('');
    buffer.writeln(primaryProcedure.description);
    buffer.writeln('');
    
    buffer.writeln('**Step-by-step instructions:**');
    for (int i = 0; i < primaryProcedure.steps.length; i++) {
      buffer.writeln('${i + 1}. ${primaryProcedure.steps[i]}');
    }
    
    buffer.writeln('');
    
    // Important notes
    if (primaryProcedure.notes.isNotEmpty) {
      buffer.writeln('**⚠️ Important Notes:**');
      buffer.writeln(primaryProcedure.notes);
      buffer.writeln('');
    }
    
    // Emergency warning for critical categories
    if (_isEmergencyCategory(classification.category)) {
      buffer.writeln('**🚨 EMERGENCY: Call 911 immediately if:**');
      buffer.writeln('- Person is unconscious or not breathing normally');
      buffer.writeln('- Severe bleeding that won\'t stop');
      buffer.writeln('- Signs of shock (pale skin, rapid pulse, confusion)');
      buffer.writeln('- Symptoms worsen or don\'t improve');
      buffer.writeln('');
    }
    
    // Related procedures if available
    if (procedures.length > 1) {
      buffer.writeln('**Related topics:**');
      for (int i = 1; i < math.min(procedures.length, 3); i++) {
        buffer.writeln('• ${procedures[i].name}');
      }
      buffer.writeln('');
    }
    
    // Additional resources
    buffer.writeln('**Need more help?** Ask about related symptoms or conditions.');
    
    return buffer.toString();
  }

  // Data Initialization
  Future<void> _buildCategoryKeywords() async {
    _categoryKeywords.addAll({
      'emergency_cpr': [
        'cpr', 'cardiac arrest', 'heart stopped', 'no pulse', 'unconscious', 
        'not breathing', 'chest compressions', 'resuscitation'
      ],
      'bleeding_control': [
        'bleed', 'bleeding', 'blood loss', 'cut', 'wound', 'hemorrhage', 
        'laceration', 'blood', 'gash', 'puncture'
      ],
      'choking_airway': [
        'choke', 'choking', 'airway', 'blockage', 'can\'t breathe', 'throat', 
        'heimlich', 'abdominal thrust', 'cannot breathe'
      ],
      'burns_treatment': [
        'burn', 'burns', 'fire', 'scald', 'hot', 'thermal injury', 'fire burn',
        'flame', 'hot liquid', 'steam'
      ],
      'fractures_injury': [
        'broken', 'fracture', 'bone', 'sprain', 'dislocation', 'injury',
        'broken bone', 'crack', 'twisted ankle', 'arm fracture'
      ],
      'heart_attack': [
        'heart attack', 'chest pain', 'cardiac', 'angina', 'chest pressure',
        'heart pain', 'left arm pain', 'chest tightness'
      ],
      'stroke_neurological': [
        'stroke', 'brain', 'neurological', 'face drooping', 'arm weakness', 
        'speech', 'brain attack', 'cva', 'facial droop', 'slurred speech'
      ],
      'poisoning_toxic': [
        'poison', 'poisoning', 'overdose', 'toxic', 'chemical', 'ingestion',
        'swallowed', 'toxic exposure', 'drug overdose', 'chemical burn'
      ],
      'allergic_reaction': [
        'allergy', 'allergic', 'anaphylaxis', 'hives', 'swelling', 'rash',
        'bee sting', 'food allergy', 'allergic shock', 'hive'
      ],
      'diabetic_emergency': [
        'diabetes', 'blood sugar', 'insulin', 'hypoglycemia', 'diabetic',
        'low blood sugar', 'high blood sugar', 'diabetic coma', 'insulin shock'
      ],
      'seizures_convulsions': [
        'seizure', 'convulsion', 'epilepsy', 'fit', 'tremoring', 'shaking',
        'epileptic', 'grand mal', 'petit mal', 'tonic clonic'
      ],
      'general_first_aid': [
        'first aid', 'emergency', 'medical help', 'injury', 'accident',
        'medical emergency', 'urgent care', 'what to do', 'help'
      ],
    });
  }

  Future<void> _initializeKnowledgeBase() async {
    // Initialize with enhanced medical procedures
    final procedures = [
      // CPR Procedure
      MedicalProcedure(
        id: 1,
        category: 'emergency_cpr',
        name: 'CPR (Cardiopulmonary Resuscitation)',
        description: 'Life-saving technique for cardiac arrest to maintain circulation and oxygenation',
        steps: [
          'Check responsiveness: Tap shoulders and shout "Are you okay?"',
          'Call 911 immediately if no response',
          'Position: Place person on back on firm surface',
          'Hand placement: Heel of one hand on center of chest between nipples',
          'Compressions: Push hard and fast at least 2 inches deep',
          'Rate: 100-120 compressions per minute',
          'Allow complete chest recoil between compressions',
          'Rescue breaths: After 30 compressions, give 2 breaths',
          'Continue cycles until help arrives or person shows signs of life'
        ],
        keywords: ['cpr', 'cardiac arrest', 'heart stopped', 'unconscious', 'chest compressions'],
        notes: 'Never perform CPR on someone breathing normally. Use AED if available. Hands-only CPR is effective.',
        severity: 'critical',
        confidenceScore: 0.95,
      ),
      
      // Bleeding Control
      MedicalProcedure(
        id: 2,
        category: 'bleeding_control',
        name: 'Severe Bleeding Control',
        description: 'Control life-threatening blood loss through direct pressure and elevation',
        steps: [
          'Apply direct pressure with clean cloth or gauze on wound',
          'Do NOT remove blood-soaked material, add more on top',
          'Elevate bleeding area above heart level if possible',
          'If bleeding continues, apply pressure to nearest artery',
          'Secure bandages firmly but not too tight',
          'Treat for shock: lay person down, elevate legs if no spinal injury',
          'Monitor breathing and consciousness',
          'Seek immediate medical help'
        ],
        keywords: ['bleeding', 'blood loss', 'hemorrhage', 'cut', 'wound', 'blood'],
        notes: 'Do not remove embedded objects. Tourniquets only for life-threatening limb bleeding.',
        severity: 'critical',
        confidenceScore: 0.93,
      ),
      
      // Choking Response
      MedicalProcedure(
        id: 3,
        category: 'choking_airway',
        name: 'Choking Response',
        description: 'Clear airway obstruction using back blows and abdominal thrusts',
        steps: [
          'Ask "Are you choking?" to confirm',
          'If person can cough or speak, encourage coughing',
          'If unable to speak/cough: Stand behind person',
          'Support chest with one hand, bend person forward',
          'Give 5 firm back blows between shoulder blades with heel of hand',
          'If unsuccessful, give 5 abdominal thrusts (Heimlich maneuver)',
          'Alternate between 5 back blows and 5 abdominal thrusts',
          'Continue until object is expelled or person becomes unconscious',
          'If unconscious, begin CPR immediately'
        ],
        keywords: ['choking', 'airway', 'blockage', 'heimlich', 'throat', 'cannot breathe'],
        notes: 'For infants under 1 year: Use back blows and chest thrusts instead of abdominal thrusts.',
        severity: 'critical',
        confidenceScore: 0.92,
      ),
      
      // Burns Treatment
      MedicalProcedure(
        id: 4,
        category: 'burns_treatment',
        name: 'Burn Treatment',
        description: 'Cool burn and provide appropriate care based on severity',
        steps: [
          'Remove person from heat source immediately',
          'Cool burn with cool (not cold) running water for 10-20 minutes',
          'Remove jewelry/tight items from burned area before swelling',
          'Do NOT break blisters or remove stuck clothing',
          'Cover with clean, non-stick bandage or cling film',
          'Do NOT apply ice, butter, oils, or home remedies',
          'Take pain relievers if appropriate',
          'Seek medical help for large burns or burns on face/hands/joints'
        ],
        keywords: ['burn', 'burns', 'fire', 'scald', 'hot', 'thermal injury'],
        notes: 'Chemical burns require immediate medical attention. Electrical burns need emergency care.',
        severity: 'moderate',
        confidenceScore: 0.90,
      ),
      
      // Heart Attack
      MedicalProcedure(
        id: 5,
        category: 'heart_attack',
        name: 'Heart Attack Response',
        description: 'Recognize and respond to heart attack symptoms immediately',
        steps: [
          'Call 911 immediately - don\'t wait for symptoms to worsen',
          'Help person sit down and rest in comfortable position',
          'Loosen tight clothing around neck and chest',
          'If conscious and not allergic, give aspirin to chew',
          'Monitor breathing and consciousness continuously',
          'Be prepared to perform CPR if person becomes unconscious',
          'Stay calm and reassure the person',
          'Note time symptoms started for medical team'
        ],
        keywords: ['heart attack', 'chest pain', 'cardiac', 'chest pressure', 'left arm pain'],
        notes: 'Time is critical. Aspirin helps prevent clotting but avoid if allergic.',
        severity: 'critical',
        confidenceScore: 0.94,
      ),
      
      // Stroke Recognition
      MedicalProcedure(
        id: 6,
        category: 'stroke_neurological',
        name: 'Stroke Recognition (FAST)',
        description: 'Use FAST method to recognize stroke symptoms and act quickly',
        steps: [
          'Face: Ask person to smile - does one side droop?',
          'Arms: Ask person to raise both arms - does one drift down?',
          'Speech: Ask person to say a simple phrase - is speech slurred?',
          'Time: If any FAST sign is present, call 911 immediately',
          'Note the time when symptoms first appeared',
          'Keep person comfortable and calm',
          'Do NOT give food, water, or medication',
          'If unconscious but breathing, place in recovery position'
        ],
        keywords: ['stroke', 'brain', 'face drooping', 'arm weakness', 'speech', 'fast'],
        notes: 'Time-critical treatment can prevent permanent brain damage. Every minute counts.',
        severity: 'critical',
        confidenceScore: 0.96,
      ),
    ];

    for (final procedure in procedures) {
      _procedureDatabase[procedure.name] = procedure;
    }
  }

  // Utility Methods
  String _getCategoryIntroduction(String category) {
    const introductions = {
      'emergency_cpr': '🫀 **Cardiac Emergency Response**',
      'bleeding_control': '🩸 **Bleeding Control Protocol**',
      'choking_airway': '🫁 **Airway Obstruction Response**',
      'burns_treatment': '🔥 **Burn Treatment Protocol**',
      'fractures_injury': '🦴 **Injury Management**',
      'heart_attack': '❤️ **Cardiac Event Response**',
      'stroke_neurological': '🧠 **Neurological Emergency**',
      'poisoning_toxic': '☠️ **Poisoning Response**',
      'allergic_reaction': '🤧 **Allergic Reaction Protocol**',
      'diabetic_emergency': '🩸 **Diabetic Emergency**',
      'seizures_convulsions': '⚡ **Seizure Response**',
      'general_first_aid': '🏥 **First Aid Guidance**',
    };
    
    return introductions[category] ?? '🏥 **Medical Assistant**';
  }

  bool _isEmergencyCategory(String category) {
    const emergencyCategories = [
      'emergency_cpr',
      'bleeding_control', 
      'choking_airway',
      'heart_attack',
      'stroke_neurological',
    ];
    
    return emergencyCategories.contains(category);
  }

  bool _isEmergencyKeyword(String keyword) {
    const emergencyKeywords = [
      'cpr', 'cardiac arrest', 'heart attack', 'stroke', 'unconscious',
      'not breathing', 'severe bleeding', 'choking', 'airway'
    ];
    
    return emergencyKeywords.contains(keyword.toLowerCase());
  }

  String _getFallbackResponse() {
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

  // Public API Methods
  void clearCache() {
    notifyListeners();
  }

  List<MedicalProcedure> getAllProcedures() {
    return _procedureDatabase.values.toList();
  }

  List<MedicalProcedure> getProceduresByCategory(String category) {
    return _procedureDatabase.values
        .where((proc) => proc.category == category)
        .toList();
  }

  void addProcedure(MedicalProcedure procedure) {
    _procedureDatabase[procedure.name] = procedure;
    notifyListeners();
  }

  // For TF-Lite integration (future enhancement)
  Future<void> loadTFModel() async {
    // Placeholder for TF-Lite model loading
    // This would initialize the actual ML model
    print('TF-Lite model integration placeholder');
  }
}

// Data Models
class QueryClassification {
  final String category;
  final double confidence;
  final String? matchedKeyword;

  QueryClassification({
    required this.category,
    required this.confidence,
    this.matchedKeyword,
  });
}

class MedicalProcedure {
  final int? id;
  final String category;
  final String name;
  final String description;
  final List<String> steps;
  final List<String> keywords;
  final String notes;
  final String severity;
  final double confidenceScore;

  MedicalProcedure({
    this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.steps,
    required this.keywords,
    required this.notes,
    required this.severity,
    required this.confidenceScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'name': name,
      'description': description,
      'steps': steps,
      'keywords': keywords,
      'notes': notes,
      'severity': severity,
      'confidence_score': confidenceScore,
    };
  }
}