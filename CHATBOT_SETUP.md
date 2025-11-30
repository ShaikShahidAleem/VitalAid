# VitalAid AI Chatbot Setup Guide

This guide will help you set up the VitalAid AI chatbot with cloud API integration for enhanced first aid guidance.

## 🚀 Features

- **Hybrid Approach**: Cloud AI for complex queries + Local knowledge base for offline use
- **Smart Caching**: Saves common responses for faster loading
- **Offline Support**: Basic first aid guidance even without internet
- **Professional UI**: Matches VitalAid app design perfectly
- **Safety-Focused**: Built-in medical disclaimers and emergency protocols

## 📦 Installation

### 1. Dependencies
The chatbot requires these packages (already added to `pubspec.yaml`):
- `shared_preferences: ^2.2.2` - For caching responses
- `http: ^1.1.0` - For API calls
- `provider: ^6.1.1` - For state management

### 2. File Structure
```
lib/
├── chatbot_page.dart          # Chatbot UI
├── services/
│   └── chatbot_service.dart   # Core chatbot logic
└── main.dart                  # Updated with Provider
```

## 🔑 Configuration

### OpenAI API Setup (Recommended)

1. **Get API Key**: Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. **Add to Service**: Update `lib/services/chatbot_service.dart`:
   ```dart
   const String apiUrl = 'https://api.openai.com/v1/chat/completions';
   
   // Replace this line with your actual API key:
   'Authorization': 'Bearer YOUR_OPENAI_API_KEY',
   ```

3. **Environment Variables** (Recommended for production):
   ```dart
   // In production, use environment variables
   final apiKey = Platform.environment['OPENAI_API_KEY'];
   ```

### Alternative AI Providers

#### Google Gemini
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

// Replace _getCloudResponse method for Gemini
final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: 'YOUR_GEMINI_API_KEY',
);
```

#### Anthropic Claude
```dart
// Use REST API with custom endpoint
final response = await http.post(
  Uri.parse('https://api.anthropic.com/v1/messages'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_CLAUDE_API_KEY',
  },
  // ... rest of implementation
);
```

## 🎛️ Customization

### Offline Knowledge Base
Edit `_firstAidResponses` in `chatbot_service.dart` to add/modify:

```dart
final Map<String, String> _firstAidResponses = {
  'your_keyword': '''
  Your custom response here...
  ''',
};
```

### System Prompt
Customize `_getSystemPrompt()` to adjust AI behavior:

```dart
String _getSystemPrompt() {
  return '''
  Your custom system prompt...
  ''';
}
```

### UI Theming
Update colors in `chatbot_page.dart` to match your brand:

```dart
// App bar gradient
colors: [Color(0xFF44CDFF), Color(0xFF0EA5E9)],

// Button gradient  
colors: [Color(0xFF44CDFF), Color(0xFF0EA5E9)],
```

## 🏥 Medical Safety Features

### Built-in Safety
- ✅ Automatic emergency service reminders
- ✅ Medical disclaimers on all responses
- ✅ Professional help escalation
- ✅ Content filtering for medical accuracy

### Custom Emergency Keywords
Add to `_firstAidResponses` for priority handling:

```dart
'heart attack': '''**HEART ATTACK WARNING**

Call 911 immediately if person has:
- Chest pain lasting more than 5 minutes
- Pain spreading to arm, jaw, neck, or back
- Shortness of breath
- Cold sweat, nausea, vomiting

What to do:
1. Call 911 - Don't wait
2. Have person sit down and rest
3. Loosen tight clothing
4. If conscious, give aspirin (if no allergies)
5. If unconscious and no pulse, start CPR
''',
```

## 🧪 Testing

### Manual Testing
1. Test online mode with API key
2. Test offline mode (disable internet)
3. Test cached responses
4. Verify emergency keywords work

### Test Scenarios
- "How to perform CPR?"
- "What to do in a heart attack?"
- "How to stop bleeding?"
- Emergency situations
- Non-medical queries

## 🔧 Troubleshooting

### Common Issues

#### API Errors
```dart
// Check these in _getCloudResponse():
// 1. API key is valid
// 2. Network connectivity
// 3. API quota limits
// 4. Request format
```

#### Cache Issues
```dart
// Clear cache if responses aren't loading:
context.read<ChatbotService>().clearCache();

// Or manually in app menu
```

#### Offline Mode Not Working
- Check `_isOnline` detection
- Verify internet connectivity logic
- Test with actual offline environment

### Performance Optimization

#### Cache Management
```dart
// Limit cache size for performance
if (_responseCache.length > 100) {
  _responseCache.clear();
  await _saveCache();
}
```

#### Response Timeout
```dart
// Add timeout to API calls
final response = await http.post(
  Uri.parse(apiUrl),
  // ... headers
).timeout(const Duration(seconds: 30));
```

## 🔒 Security Considerations

### API Key Security
- ✅ Never hardcode API keys in source code
- ✅ Use environment variables in production
- ✅ Rotate API keys regularly
- ✅ Monitor API usage

### Medical Content Safety
- ✅ Always include disclaimers
- ✅ Emphasize professional medical advice
- ✅ Include emergency service information
- ✅ Regular content audit and updates

### Privacy
- ✅ No user data stored in cloud
- ✅ Cached responses are local only
- ✅ API calls don't include personal information
- ✅ Consider data residency for compliance

## 🚀 Production Deployment

### Environment Setup
1. Set up environment variables on your platform
2. Configure secure API key management
3. Set up monitoring and logging
4. Test with production credentials

### Performance Monitoring
- Track response times
- Monitor API usage and costs
- Log errors and exceptions
- Monitor cache hit rates

### Maintenance
- Regular API key rotation
- Update offline knowledge base
- Monitor medical content accuracy
- User feedback integration

## 📱 Integration Points

### Home Screen
- Available in Quick Actions as "AI Assistant"
- Bottom navigation bar chat icon
- Easy one-tap access

### Medical Records
- Can reference previous medical records
- Context-aware responses based on user history
- Integration with medical data (future enhancement)

### Emergency Mode
- Quick access from emergency button
- Offline-first response approach
- Emergency-specific prompts

---

**🎉 Your VitalAid AI Chatbot is now ready to provide intelligent first aid guidance!**

For support or questions, refer to the code comments in `chatbot_service.dart` and `chatbot_page.dart`.