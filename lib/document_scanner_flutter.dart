
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class DocumentScannerFlutter {
  static MethodChannel get _channel => const MethodChannel('document_scanner_flutter');

  static Future<File> scanDocument() async {
    final String path = await _channel.invokeMethod('scan');
    if(path == null){
      return null;
    }else{
      return File(path);
    }
  }
}
