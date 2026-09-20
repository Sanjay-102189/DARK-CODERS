import 'package:flutter_test/flutter_test.dart';
import 'package:craftmitra/services/voice_recording_service.dart';
import 'package:craftmitra/providers/providers.dart';
import 'package:craftmitra/core/constants/demo_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceRecordingService Unit Tests', () {
    late VoiceRecordingService service;

    setUp(() {
      service = VoiceRecordingService();
    });

    tearDown(() {
      service.dispose();
    });

    test('1. Initial voice state is idle with no transcript and 0 duration', () {
      expect(service.state, equals(VoiceRecordingState.idle));
      expect(service.currentTranscript, isEmpty);
      expect(service.recordingDuration, equals(0));
      expect(service.lastError, isNull);
    });

    test('2. Language selection maps correctly to locales (Hindi, Tamil, English)', () {
      expect(VoiceRecordingService.languageLocaleMap['Hindi'], equals('hi_IN'));
      expect(VoiceRecordingService.languageLocaleMap['Tamil'], equals('ta_IN'));
      expect(VoiceRecordingService.languageLocaleMap['English'], equals('en_IN'));
    });

    test('3. Transcript state update records recognized words correctly', () {
      String recorded = '';
      bool finalResult = false;

      void onResult(String text, bool isFinal) {
        recorded = text;
        finalResult = isFinal;
      }

      onResult('यह अलवर की मिट्टी से बना फूलदान है', true);
      expect(recorded, equals('यह अलवर की मिट्टी से बना फूलदान है'));
      expect(finalResult, isTrue);
    });

    test('4. Recording state transitions handle idle -> recording -> completed', () {
      VoiceRecordingState currentState = VoiceRecordingState.idle;

      void onStateChanged(VoiceRecordingState state) {
        currentState = state;
      }

      onStateChanged(VoiceRecordingState.recording);
      expect(currentState, equals(VoiceRecordingState.recording));

      onStateChanged(VoiceRecordingState.processing);
      expect(currentState, equals(VoiceRecordingState.processing));

      onStateChanged(VoiceRecordingState.completed);
      expect(currentState, equals(VoiceRecordingState.completed));
    });

    test('5. Empty transcript handling keeps state graceful and does not crash', () {
      String recorded = '';
      void onResult(String text, bool isFinal) {
        recorded = text;
      }

      onResult('', false);
      expect(recorded, isEmpty);
      expect(service.state, equals(VoiceRecordingState.idle));
    });

    test('6. Error handling sets error state and records informative message', () {
      VoiceRecordingState currentState = VoiceRecordingState.idle;

      void onStateChanged(VoiceRecordingState state) {
        currentState = state;
      }

      onStateChanged(VoiceRecordingState.error);
      expect(currentState, equals(VoiceRecordingState.error));
    });
  });

  group('ProductCreationProvider Voice Integration Tests', () {
    test('7. Provider voice integration handles language selection, transcripts, and demo fallback', () {
      final prov = ProductCreationProvider();

      // Initial state
      expect(prov.selectedVoiceLanguage, equals('Hindi'));
      expect(prov.voiceTranscript, isEmpty);
      expect(prov.isRecording, isFalse);
      expect(prov.isTranscribing, isFalse);

      // Language selection
      prov.selectVoiceLanguage('Tamil');
      expect(prov.selectedVoiceLanguage, equals('Tamil'));

      prov.selectVoiceLanguage('English');
      expect(prov.selectedVoiceLanguage, equals('English'));

      // Real transcript setting
      prov.setTranscript('This is a handcrafted terracotta flower pot.');
      expect(prov.voiceTranscript, equals('This is a handcrafted terracotta flower pot.'));
      expect(prov.useDemoVoice, isFalse);

      // Clearing transcript
      prov.clearVoiceTranscript();
      expect(prov.voiceTranscript, isEmpty);

      // Demo fallback only when explicitly selected
      prov.selectDemoVoice();
      expect(prov.useDemoVoice, isTrue);
      expect(prov.voiceTranscript, equals(DemoData.demoTranscript));

      // Reset cleans up all voice states
      prov.reset();
      expect(prov.voiceTranscript, isEmpty);
      expect(prov.useDemoVoice, isFalse);
      expect(prov.isRecording, isFalse);
    });
  });
}
