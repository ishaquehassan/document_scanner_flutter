import 'dart:io';

import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _scannedDocument;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_scannedDocument != null) ...[
                Image.file(_scannedDocument!, width: 200),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_scannedDocument!.path),
                ),
              ],
              Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () async {
                      var doc = await DocumentScannerFlutter.launch(context);
                      if (doc != null) {
                        _scannedDocument = doc;
                        setState(() {});
                      }
                    },
                    child: Text("Scan"));
              })
            ],
          ),
        ),
      ),
    );
  }
}
