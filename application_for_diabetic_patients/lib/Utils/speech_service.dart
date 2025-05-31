import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  bool get isListening => _speechToText.isListening;
  bool get isSpeechAvailable => _speechEnabled;

  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  Future<void> startListening(void Function(SpeechRecognitionResult result) onResult,
    {String localeId = 'en/EN'}) async {
  await _speechToText.listen(onResult: onResult, localeId: localeId);
}


  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  double getConfidenceLevel(result) => result?.confidence ?? 0;
  SpeechToText get speechToText => _speechToText;
}
