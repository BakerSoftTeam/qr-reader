import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manager of information read by the scanner and sent as keyboard events.
class ScannerManager {
  /// Due to information coming as events, we wait for the next event for some time.
  /// This value is the default duration between events in the data sequence read once.
  static const Duration _defaultDuration = Duration(milliseconds: 300);

  /// The event source for devices that work as a hardware keyboard.
  ///
  /// See https://developer.android.com/reference/android/view/InputDevice#SOURCE_KEYBOARD
  static const int _hardwareKeyboardSourceEvent = 257;

  /// List of default target event sources, if special doesn't set
  static const List<int> _defaultTargetEventSources = [
    _hardwareKeyboardSourceEvent,
  ];

  /// A list of characters that should be filtered out from the scanned text.
  ///
  /// https://en.wikipedia.org/wiki/Unicode_control_characters
  static const List<String> _controlCharacters = ['\u0000'];

  /// Contains all event sources which should be detected as scanner input
  final List<int> targetSources;

  final KeyEventManager _keyEventManager;
  final _controller = StreamController<String>.broadcast();
  final List<RawKeyEvent> _events = [];
  final Duration _duration;
  Timer? _timer;

  ScannerManager({
    this.targetSources = _defaultTargetEventSources,
    KeyEventManager? keyEventManager,
    Duration? eventDuration,
  })  : _keyEventManager =
            keyEventManager ?? ServicesBinding.instance.keyEventManager,
        _duration = eventDuration ?? _defaultDuration {
    _keyEventManager.keyMessageHandler = _handle;
  }

  /// Publisher that notify about reading info by scanner
  Stream<String> get scanned => _controller.stream;

  @mustCallSuper
  void dispose() {
    _keyEventManager.keyMessageHandler = null;
    _timer?.cancel();
    _timer = null;
    _controller.close();
  }

  bool _handle(KeyMessage event) {
    final rawEvent = event.rawEvent;
    if (rawEvent is RawKeyEvent) {
      final data = rawEvent.data;
      if (data is RawKeyEventDataAndroid) {
        if (targetSources.contains(data.eventSource)) {
          if (rawEvent is RawKeyDownEvent) {
            _events.add(rawEvent);
            _timer?.cancel();
            _timer = Timer(_duration, _notifyNewInput);
          }
          return true;
        }
      }
    }
    return false;
  }

  void _notifyNewInput() {
    _timer = null;
    final newValue = _events
        .map((e) => e.character)
        .where((e) => e != null && !_controlCharacters.contains(e))
        .join();
    _controller.add(newValue);
    _events.clear();
  }
}
