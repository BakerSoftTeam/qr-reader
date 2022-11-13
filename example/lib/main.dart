import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_hid_reader/qr_hid_reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const KeyboardPage(),
    );
  }
}

class KeyboardPage extends StatefulWidget {
  const KeyboardPage({Key? key}) : super(key: key);

  @override
  State<KeyboardPage> createState() => _KeyboardPageState();
}

class _KeyboardPageState extends State<KeyboardPage> {
  late final ScannerManager _detector;

  @override
  void initState() {
    super.initState();

    _detector = Platform.isAndroid
        ? AndroidScannerManager(
            targetSources: [257, 769],
          )
        : CommonScannerManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<String>(
            stream: _detector.scanned,
            builder: (_, value) {
              return Text('Raw data: ${value.data}');
            },
          ),
          const TextField(),
        ],
      ),
    );
  }
}
