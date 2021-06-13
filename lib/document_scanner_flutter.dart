import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ScannerFileSource{
  CAMERA,GALLERY
}

class DocumentScannerFlutter {
  static MethodChannel get _channel =>
      const MethodChannel('document_scanner_flutter');

  static Future<File?> _scanDocument(ScannerFileSource source) async {
    String? path = await _channel.invokeMethod(describeEnum(source).toLowerCase());
    if (path == null) {
      return null;
    } else {
      if(Platform.isIOS){
        path = path.split('file://')[1];
      }
      return File(path);
    }
  }

  static Future<File?>? launch(BuildContext context,{ScannerFileSource? source}){
    if(source != null){
      return _scanDocument(source);
    }
    return showModalBottomSheet<File>(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('Camera'),
                    onTap: () async {
                      Navigator.pop(context,await _scanDocument(ScannerFileSource.CAMERA));
                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.image_search),
                  title: new Text('Photo Library'),
                  onTap: () async {
                    Navigator.pop(context,await _scanDocument(ScannerFileSource.GALLERY));
                  },
                ),
              ],
            ),
          );
        }
    );
  }
}
