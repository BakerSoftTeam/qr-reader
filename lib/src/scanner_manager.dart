import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manager of information read by the scanner and sent as keyboard events.
///
/// Attention: This manager uses KeyEventManager.keyMessageHandler which
/// can be set only in a single copy. This means the default behavior
/// of the FocusManager will be replaced. Also should take into account that
/// any other replacement of KeyEventManager.keyMessageHandler will
/// break ScannerManager.
abstract class ScannerManager {
  /// Due to information coming as events, we wait for the next event for some time.
  /// This value is the default duration between events in the data sequence read once.
  static const Duration _defaultDuration = Duration(milliseconds: 300);

  /// A list of characters that should be filtered out from the scanned text.
  ///
  /// https://en.wikipedia.org/wiki/Unicode_control_characters
  static const List<String> _controlCharacters = ['\u0000'];

  final KeyEventManager _manager;
  final _controller = StreamController<String>.broadcast();
  final List<RawKeyEvent> _events = [];
  final Duration _duration;
  Timer? _timer;

  ScannerManager({
    KeyEventManager? keyEventManager,
    Duration? eventDuration,
  })  : _manager = keyEventManager ?? ServicesBinding.instance.keyEventManager,
        _duration = eventDuration ?? _defaultDuration {
    _manager.keyMessageHandler = _handle;
  }

  /// Publisher that notifies about reading info by scanner.
  Stream<String> get scanned => _controller.stream;

  @mustCallSuper
  void dispose() {
    _manager.keyMessageHandler = null;
    _timer?.cancel();
    _timer = null;
    _controller.close();
  }

  bool _handle(KeyMessage event) {
    final rawEvent = event.rawEvent;
    if (rawEvent != null) {
      if (_checkIsTargetEvent(rawEvent)) {
        _maybeNewInfo(rawEvent);
        return true;
      }
    }

    return false;
  }

  bool _checkIsTargetEvent(RawKeyEvent event);

  void _maybeNewInfo(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _events.add(event);
      _timer?.cancel();
      _timer = Timer(_duration, _notifyNewInput);
    }
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

/// Implementation of [ScannerManager] that catch every event.
class CommonScannerManager extends ScannerManager {
  CommonScannerManager({
    super.keyEventManager,
    super.eventDuration,
  });

  @override
  bool _checkIsTargetEvent(RawKeyEvent event) => true;
}

/// Implementation of [ScannerManager] that uses delegate to determine
/// if the event should be handled.
class ScannerManagerWithDelegate extends ScannerManager {
  final bool Function(RawKeyEvent) delegate;

  ScannerManagerWithDelegate({
    super.keyEventManager,
    super.eventDuration,
    required this.delegate,
  });

  @override
  bool _checkIsTargetEvent(RawKeyEvent event) => delegate(event);
}

/// Implementation of [ScannerManager] for the Android platform.
///
/// For the Android platform, we have info about the source of the event.
/// This makes available catch only specific target events.
class AndroidScannerManager extends ScannerManager {
  /// The event source for devices that work as a hardware keyboard.
  ///
  /// See https://developer.android.com/reference/android/view/InputDevice#SOURCE_KEYBOARD
  static const int _hardwareKeyboardSourceEvent = 257;

  /// List of default target event sources, if special doesn't set
  static const List<int> _defaultTargetEventSources = [
    _hardwareKeyboardSourceEvent,
  ];

  /// Contains all event sources which should be detected as scanner input
  final List<int> targetSources;

  AndroidScannerManager({
    super.keyEventManager,
    super.eventDuration,
    this.targetSources = _defaultTargetEventSources,
  });

  @override
  bool _checkIsTargetEvent(RawKeyEvent event) {
    if (!Platform.isAndroid) {
      throw UnsupportedError('This manager can be used only on Android.');
    }

    final data = event.data;
    if (data is RawKeyEventDataAndroid) {
      if (targetSources.contains(data.eventSource)) {
        return true;
      }
    }

    return false;
  }
}
