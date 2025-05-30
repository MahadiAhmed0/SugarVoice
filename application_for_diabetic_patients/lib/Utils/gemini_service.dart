// File: gemini_service.dart
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  final Gemini _gemini;
  
  // Enhanced health instruction with clearer role definition and response guidelines
  static const String _healthInstruction = 
      """You are Medico, a specialized AI health assistant for diabetic patients. 
      Your role is to provide accurate, concise health advice related to diabetes management. 

      **Strict Guidelines:**
      1. Only discuss health topics: diabetes, nutrition, exercise, medication, blood sugar, etc.
      2. For non-health queries, respond: "I specialize in diabetes health advice. How can I help with your health concerns?"
      3. Keep responses under 3 sentences unless detailed explanation is requested.
      4. Always verify medical facts before responding.
      5. For emergencies, advise contacting a doctor immediately.

      Current conversation:""";

  GeminiService({required String apiKey}) 
      : _gemini = Gemini.instance {
    // Initialize Gemini with configuration
    Gemini.init(
      apiKey: apiKey,
      enableDebugging: true, // For troubleshooting
    );
  }

  /// Streams responses from Gemini with optimized prompt handling
  Stream<String> getHealthResponse(String userQuery) {
    // Construct a single, well-formatted prompt
    final prompt = """
    $_healthInstruction
    
    User Query: "$userQuery"
    
    Please provide a concise, accurate response focused on diabetes health management:
    """;
    
    try {
      return _gemini.streamGenerateContent(prompt).asyncExpand((event) {
        final response = event.output;
        if (response == null || response.isEmpty) {
          return Stream.value("Let me think more about that. Could you please rephrase your health question?");
        }
        
        return Stream.value(response);
      });
    } catch (e) {
      return Stream.value("I'm currently updating my health knowledge. Please try again in a moment.");
    }
  }

  /// Optimized single response method with better error handling
  Future<String> getSingleHealthResponse(String userQuery) async {
    // Construct a focused prompt with clear instructions
    final prompt = """
    $_healthInstruction
    
    User: "$userQuery"
    
    Required Response:
    - Be specific to diabetes health
    - Maximum 2-3 sentences
    - Include actionable advice if applicable
    - If unsure, say "I recommend consulting your doctor about this"
    """;
    
    try {
      // Add slight delay to ensure proper initialization
      await Future.delayed(const Duration(milliseconds: 200));
      
      final response = await _gemini.text(prompt);
      return _processResponse(response?.output);
    } catch (e) {
      return "I'm currently optimizing my health advice. Please try again shortly.";
    }
  }

  /// Processes raw API response to ensure quality
  String _processResponse(String? rawResponse) {
    if (rawResponse == null || rawResponse.isEmpty) {
      return "I didn't catch that. Could you rephrase your health question?";
    }

    // Filter out unwanted phrases
    final filtered = rawResponse
        .replaceAll(RegExp(r'^(Sorry|Apologies),?', caseSensitive: false), '')
        .trim();

    return filtered.isEmpty 
        ? "How can I assist with your diabetes health concerns today?"
        : filtered;
  }
}