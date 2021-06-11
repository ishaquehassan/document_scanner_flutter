import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _scannedDocument;
  
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    File scannedDoc;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      scannedDoc = await DocumentScannerFlutter.scanDocument();
    } on PlatformException {
      //scannedDoc = 'Failed to get document path.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scannedDocument = scannedDoc;
    });
  }

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
              if(_scannedDocument != null)
              Image.file(_scannedDocument,width: 200),
              ElevatedButton(onPressed: initPlatformState,child: Text("Scan"))
            ],
          ),
        ),
      ),
    );
  }
}
