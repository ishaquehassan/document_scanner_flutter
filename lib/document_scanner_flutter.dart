import 'dart:async';
import 'dart:io';

import 'package:document_scanner_flutter/screens/pdf_generator_gallery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configs/configs.dart';

class DocumentScannerFlutter {
  static MethodChannel get _channel =>
      const MethodChannel('document_scanner_flutter');

  static Future<File?> _scanDocument(
      ScannerFileSource source, Map<dynamic, String> androidConfigs) async {
    Map<String, String?> finalAndroidArgs = {};
    for (var entry in androidConfigs.entries) {
      finalAndroidArgs[describeEnum(entry.key)] = entry.value;
    }

    String? path = await _channel.invokeMethod(
        describeEnum(source).toLowerCase(), finalAndroidArgs);
    if (path == null) {
      return null;
    } else {
      if (Platform.isIOS) {
        path = path.split('file://')[1];
      }
      return File(path);
    }
  }

  static Future<File?> launchForPdf(BuildContext context,
      {Map<dynamic, String> androidConfigs = const {}}) async {
    Future<File?>? launchWrapper() {
      return launch(context, androidConfigs: androidConfigs);
    }

    return await Navigator.push<File>(context,
        MaterialPageRoute(builder: (_) => PdfGeneratotGallery(launchWrapper)));
  }

  static Future<File?>? launch(BuildContext context,
      {ScannerFileSource? source,
      Map<dynamic, String> androidConfigs = const {}}) {
    if (source != null) {
      return _scanDocument(source, androidConfigs);
    }
    return showModalBottomSheet<File>(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('Camera'),
                    onTap: () async {
                      Navigator.pop(
                          context,
                          await _scanDocument(
                              ScannerFileSource.CAMERA, androidConfigs));
                    }),
                new ListTile(
                  leading: new Icon(Icons.image_search),
                  title: new Text('Photo Library'),
                  onTap: () async {
                    Navigator.pop(
                        context,
                        await _scanDocument(
                            ScannerFileSource.GALLERY, androidConfigs));
                  },
                ),
              ],
            ),
          );
        });
  }
}
