import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class AudioService {
  /// Play crisp bell chime when a single task is marked completed
  static void playTaskDoneSound() {
    try {
      if (kIsWeb) {
        js.context.callMethod('eval', [
          '''
          (function() {
            try {
              var AudioContext = window.AudioContext || window.webkitAudioContext;
              if (!AudioContext) return;
              var ctx = new AudioContext();
              var notes = [523.25, 659.25, 783.99]; // C5, E5, G5 chime
              var startTime = ctx.currentTime;
              notes.forEach(function(freq, i) {
                var osc = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.value = freq;
                var noteStart = startTime + (i * 0.08);
                gain.gain.setValueAtTime(0.3, noteStart);
                gain.gain.exponentialRampToValueAtTime(0.001, noteStart + 0.3);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start(noteStart);
                osc.stop(noteStart + 0.3);
              });
            } catch(e) {}
          })();
          '''
        ]);
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      debugPrint('Audio chime error: $e');
    }
  }

  /// Play celebration fanfare chord when ALL tasks are 100% completed
  static void playAllTasksDoneSound() {
    try {
      if (kIsWeb) {
        js.context.callMethod('eval', [
          '''
          (function() {
            try {
              var AudioContext = window.AudioContext || window.webkitAudioContext;
              if (!AudioContext) return;
              var ctx = new AudioContext();
              var notes = [523.25, 659.25, 783.99, 1046.50]; // Celebration Arpeggio
              var startTime = ctx.currentTime;
              notes.forEach(function(freq, i) {
                var osc = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.type = 'triangle';
                osc.frequency.value = freq;
                var noteStart = startTime + (i * 0.1);
                gain.gain.setValueAtTime(0.35, noteStart);
                gain.gain.exponentialRampToValueAtTime(0.001, noteStart + 0.6);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start(noteStart);
                osc.stop(noteStart + 0.6);
              });
            } catch(e) {}
          })();
          '''
        ]);
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('Audio fanfare error: $e');
    }
  }
}
