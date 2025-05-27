import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechNavigation {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  Future<String> listenForCommand() async {
    if (!_speechEnabled) {
      await initSpeech();
      if (!_speechEnabled) return '';
    }

    _lastWords = '';
    
    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastWords = result.recognizedWords.toLowerCase();
        }
      },
      listenFor: const Duration(seconds: 5),
    );

    await Future.delayed(const Duration(seconds: 5));
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }

    return _lastWords;
  }

  String? getNavigationCommand(String spokenText) {
    final text = spokenText.toLowerCase();
    
    if (text.contains('check sugar') || text.contains('sugar check') || text.contains('sugar')) {
      return 'Check Sugar';
    } else if (text.contains('medicine') || text.contains('log medicine') || text.contains('take medicine')) {
      return 'Take/Log Medicine';
    } else if (text.contains('food') || text.contains('advice') || text.contains('food advice')) {
      return 'Food Advice';
    } else if (text.contains('call') || text.contains('family') || text.contains('call family')) {
      return 'Call Family';
    } else if (text.contains('diary') || text.contains('offline') || text.contains('offline diary')) {
      return 'Offline Diary';
    }
    
    return null;
  }
}