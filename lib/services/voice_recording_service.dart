import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

/// States of voice recording and speech-to-text pipeline.
enum VoiceRecordingState {
  idle,
  recording,
  processing,
  completed,
  error,
}

/// Service handling microphone recording and multilingual speech recognition.
class VoiceRecordingService {
  final SpeechToText _speech = SpeechToText();

  VoiceRecordingState _state = VoiceRecordingState.idle;
  VoiceRecordingState get state => _state;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  String? _lastError;
  String? get lastError => _lastError;

  String _currentTranscript = '';
  String get currentTranscript => _currentTranscript;

  int _recordingDuration = 0;
  int get recordingDuration => _recordingDuration;

  Timer? _timer;
  String? _temporaryRecordingPath;
  String? get temporaryRecordingPath => _temporaryRecordingPath;

  /// Locale mapping for supported languages
  static const Map<String, String> languageLocaleMap = {
    'Hindi': 'hi_IN',
    'Tamil': 'ta_IN',
    'English': 'en_IN',
  };

  /// Formats speech recognition errors into actionable user messages.
  String _formatRecognitionError(String errorMsg) {
    final lower = errorMsg.toLowerCase();
    if (lower.contains('error_speech_timeout') || lower.contains('no_match')) {
      return 'No speech detected. Please speak closer to the microphone.';
    } else if (lower.contains('error_audio')) {
      return 'Audio recording issue. Please check microphone hardware.';
    } else if (lower.contains('error_permission')) {
      return 'Microphone permission denied. Please allow microphone access in device Settings.';
    } else if (lower.contains('error_network')) {
      return 'Network error during speech recognition. Please check internet connection.';
    } else if (lower.contains('error_busy')) {
      return 'Speech engine is busy. Please try again.';
    }
    return 'Voice recognition issue: $errorMsg';
  }

  /// Forces re-initialization of speech engine (e.g. after user grants permission in settings).
  Future<bool> retryInitialization({
    Function(VoiceRecordingState state)? onStateChanged,
  }) async {
    _isAvailable = false;
    _lastError = null;
    return await initialize(onStateChanged: onStateChanged);
  }

  /// Initializes the speech recognition engine and checks permissions.
  Future<bool> initialize({
    Function(VoiceRecordingState state)? onStateChanged,
  }) async {
    if (_isAvailable) return true;

    try {
      debugPrint('[VoiceRecordingService] Checking speech recognition initialization...');
      _isAvailable = await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          debugPrint('[VoiceRecordingService] Speech recognition error: ${error.errorMsg} (permanent: ${error.permanent})');
          _lastError = _formatRecognitionError(error.errorMsg);
          _state = VoiceRecordingState.error;
          _stopTimer();
          onStateChanged?.call(_state);
        },
        onStatus: (String status) {
          debugPrint('[VoiceRecordingService] Speech recognition status: $status');
          if (status == 'listening') {
            _state = VoiceRecordingState.recording;
          } else if (status == 'notListening' || status == 'done') {
            if (_state == VoiceRecordingState.recording) {
              _state = _currentTranscript.isNotEmpty
                  ? VoiceRecordingState.completed
                  : VoiceRecordingState.idle;
              _stopTimer();
            }
          }
          onStateChanged?.call(_state);
        },
        debugLogging: true,
      );

      final hasPermission = await _speech.hasPermission;
      debugPrint('[VoiceRecordingService] initialize completed: isAvailable=$_isAvailable, hasPermission=$hasPermission');

      if (!_isAvailable) {
        if (!hasPermission) {
          _lastError = 'Microphone permission denied. Please grant microphone access in App Settings.';
        } else {
          _lastError = 'Speech Recognition service unavailable on this device. Please check that Google Speech Services or Google app is enabled in Android Settings.';
        }
        _state = VoiceRecordingState.error;
      }
    } catch (e) {
      debugPrint('[VoiceRecordingService] Initialization exception: $e');
      _isAvailable = false;
      _lastError = 'Speech recognition initialization failed: $e';
      _state = VoiceRecordingState.error;
    }

    return _isAvailable;
  }

  /// Starts listening in the specified language (Hindi, Tamil, English).
  Future<bool> startRecording({
    required String language,
    required void Function(String text, bool isFinal) onResult,
    required void Function(VoiceRecordingState state) onStateChanged,
  }) async {
    _lastError = null;
    _currentTranscript = '';
    _recordingDuration = 0;

    // Verify or perform initialization
    if (!_isAvailable) {
      final initialized = await initialize(onStateChanged: onStateChanged);
      if (!initialized) {
        _state = VoiceRecordingState.error;
        onStateChanged(_state);
        return false;
      }
    }

    final localeId = languageLocaleMap[language] ?? 'hi_IN';
    _temporaryRecordingPath = 'temp_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      _state = VoiceRecordingState.recording;
      onStateChanged(_state);
      _startTimer(onStateChanged);

      await _speech.listen(
        onResult: (result) {
          _currentTranscript = result.recognizedWords;
          debugPrint('[VoiceRecordingService] Recognized: $_currentTranscript (final: ${result.finalResult})');
          onResult(_currentTranscript, result.finalResult);

          if (result.finalResult) {
            _state = VoiceRecordingState.completed;
            _stopTimer();
            onStateChanged(_state);
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          localeId: localeId,
        ),
      );

      return true;
    } catch (e) {
      debugPrint('[VoiceRecordingService] listen exception: $e');
      _state = VoiceRecordingState.error;
      _lastError = e.toString();
      _stopTimer();
      onStateChanged(_state);
      return false;
    }
  }

  /// Stops the current recording session.
  Future<void> stopRecording({
    required void Function(VoiceRecordingState state) onStateChanged,
  }) async {
    _stopTimer();
    try {
      _state = VoiceRecordingState.processing;
      onStateChanged(_state);

      await _speech.stop();

      _state = _currentTranscript.isNotEmpty
          ? VoiceRecordingState.completed
          : VoiceRecordingState.idle;
      onStateChanged(_state);
    } catch (e) {
      debugPrint('[VoiceRecordingService] stop exception: $e');
      _state = VoiceRecordingState.idle;
      onStateChanged(_state);
    }
  }

  /// Cancels listening and resets state.
  Future<void> cancelRecording({
    required void Function(VoiceRecordingState state) onStateChanged,
  }) async {
    _stopTimer();
    try {
      await _speech.cancel();
    } catch (_) {}
    _state = VoiceRecordingState.idle;
    onStateChanged(_state);
  }

  void _startTimer(void Function(VoiceRecordingState state) onStateChanged) {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _recordingDuration++;
      onStateChanged(_state);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _stopTimer();
    try {
      _speech.cancel();
    } catch (_) {}
  }
}
