# QR HID Reader

[![Pub Version](https://img.shields.io/pub/v/qr_hid_reader?logo=dart&logoColor=white)](https://pub.dev/packages/qr_hid_reader)
[![Pub Likes](https://badgen.net/pub/likes/qr_hid_reader)](https://pub.dev/packages/qr_hid_reader)
[![Pub popularity](https://badgen.net/pub/popularity/qr_hid_reader)](https://pub.dev/packages/qr_hid_reader/score)
![Flutter Platform](https://badgen.net/pub/flutter-platform/qr_hid_reader)

## About

Implementation of the QR scanner listener that handles output as keyboard events.

This package allows working easily with any scanners that support the [HID](https://www.usb.org/hid) mode.
In this mode, scanners work like a keyboard that provides a sequence of keypress events.

_This also means that you can use a hardware keyboard with emulators to mock the behavior of the scanner for the test._

## Description

To get scanned info you need to create one of available [ScannerManager](lib/src/scanner_manager.dart).
It has a property `scanned` that is a publisher of any info which read by scanner.

Now available few types of the ScannerManager.

### CommonScannerManager
Simplest manager that just informs about information was scanned. 
Doesn't stop propagation of the scanned information.

### ScannerManagerWithDelegate
The manager with agile customization.
Passed delegate is used to determine should the read keyboard event be used or ignored.
Also, propagation behavior can be set by the `stopWhenCatch` parameter.

### AndroidScannerManager
Useful implementation to work with scanners that connected to the Android (**only**) system device.
Android provides more information about a keyboard event, including ID of the source.
You can setup your own target list of IDs.

Check [specification](https://developer.android.com/reference/android/view/InputDevice#SOURCE_KEYBOARD).

#### Notice
_Language-specific keyboards can have strange IDs out of specification list.
For example, the Cyrillic keyboard on Macbook Pro M1 has ID `769`._  

## Example

First step create a manager.

```dart
final manager = AndroidScannerManager();
```

And then just subscribe to publisher any way that you need. For example:

```dart
StreamBuilder<String>(
  stream: manager.scanned,
  builder: (_, value) {
    return Text('Raw data: ${value.data}');
  },
),
```

## Installation

Add `qr_hid_reader` to your `pubspec.yaml` file:

```yaml
dependencies:
  qr_hid_reader: $currentVersion$
```

<p>At this moment, the current version of <code>qr_hid_reader</code> is <a href="https://pub.dev/packages/qr_hid_reader"><img style="vertical-align:middle;" src="https://img.shields.io/pub/v/qr_hid_reader.svg" alt="qr_reader version"></a>.</p>

## Changelog

All notable changes are mentioned in [this file](./CHANGELOG.md).

## Issues

To report your issues, submit them directly in the [Issues](https://github.com/BakerSoftTeam/qr_hid_reader/issues) section.