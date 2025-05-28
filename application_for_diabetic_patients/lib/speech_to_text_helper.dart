import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextHelper extends ValueNotifier<bool> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  String _lastWords = '';

  SpeechToTextHelper() : super(false);

  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;

  Future<void> initialize() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        notifyListeners();
      },
    );
    notifyListeners();
  }

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isAvailable) return;

    _lastWords = '';
    value = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastWords = result.recognizedWords;
          onResult(_lastWords);
          stopListening();
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    if (!value) return;

    await _speech.stop();
    value = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}