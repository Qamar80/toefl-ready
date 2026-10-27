import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps text-to-speech (plays the sentences and questions) and
/// speech-to-text (records the learner). If the recognizer stops after a
/// pause, it restarts and keeps adding to the same transcript.
class SpeechService {
  SpeechService._();
  static final SpeechService I = SpeechService._();

  final _stt = SpeechToText();
  final _tts = FlutterTts();
  bool _sttReady = false, _ttsReady = false;

  bool _want = false;
  String _done = '';
  String _live = '';
  String _last = '';
  double _confSum = 0;
  int _confN = 0;
  void Function(String text)? _onText;

  String get text => '$_done $_live'.trim();

  /// Average recognizer confidence 0..1, or -1 if the device does not report it.
  double get confidence => _confN == 0 ? -1 : _confSum / _confN;

  Future<bool> init() async {
    if (!_ttsReady) {
      try {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(0.45);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
        await _tts.awaitSpeakCompletion(true);
        _ttsReady = true;
      } catch (_) {}
    }
    if (!_sttReady) {
      try {
        _sttReady = await _stt.initialize(onStatus: _onStatus, onError: _onError);
      } catch (_) {
        _sttReady = false;
      }
    }
    return _sttReady;
  }

  /// Speaks the text once and returns when it has finished.
  Future<void> speak(String t) async {
    try {
      await _tts.speak(t);
    } catch (_) {}
  }

  Future<void> startListening(void Function(String text) onText) async {
    _done = '';
    _live = '';
    _last = '';
    _confSum = 0;
    _confN = 0;
    _onText = onText;
    _want = true;
    await _begin();
  }

  Future<void> _begin() async {
    if (!_want || !_sttReady || _stt.isListening) return;
    try {
      await _stt.listen(
        onResult: _onResult,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 6),
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
      );
    } catch (_) {}
  }

  void _commit() {
    final t = _live.trim();
    if (t.isEmpty) return;
    _done = '$_done $t'.trim();
    _last = t;
    _live = '';
  }

  void _onResult(SpeechRecognitionResult r) {
    _live = r.recognizedWords;
    if (r.finalResult) {
      final t = r.recognizedWords.trim();
      if (t == _last) {
        _live = '';
      } else {
        if (r.confidence > 0 && t.isNotEmpty) {
          _confSum += r.confidence;
          _confN++;
        }
        _commit();
      }
    }
    _onText?.call(text);
  }

  void _onStatus(String s) {
    if ((s == 'done' || s == 'notListening') && _want) {
      _commit();
      _onText?.call(text);
      Future.delayed(const Duration(milliseconds: 250), _begin);
    }
  }

  void _onError(SpeechRecognitionError e) {
    if (_want && !e.permanent) {
      Future.delayed(const Duration(milliseconds: 400), _begin);
    }
  }

  /// Stops recording and returns the full transcript.
  Future<String> stopListening() async {
    _want = false;
    try {
      await _stt.stop();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 450)); // let the last result arrive
    _commit();
    return text;
  }

  Future<void> cancel() async {
    _want = false;
    try {
      await _stt.cancel();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }
}