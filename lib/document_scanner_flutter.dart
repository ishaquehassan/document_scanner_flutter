import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:document_scanner_flutter/screens/pdf_generator_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configs/configs.dart';

/// Dcoument Scanner Class
class DocumentScannerFlutter {
  static MethodChannel get _channel =>
      const MethodChannel('document_scanner_flutter');

  static Future<File?> _scanDocument(
    ScannerFileSource source,
    Map<dynamic, String> androidConfigs, {
    Uint8List? initialImage,
    bool canBackToInitial = true,
  }) async {
    Map<String, dynamic> finalAndroidArgs = {};
    for (var entry in androidConfigs.entries) {
      finalAndroidArgs[entry.key.name] = entry.value;
    }
    if (initialImage != null) {
      finalAndroidArgs['INITIAL_IMAGE'] = initialImage;
      finalAndroidArgs['CAN_BACK_TO_INITIAL'] = canBackToInitial;
    }

    String? path = await _channel.invokeMethod(
        source.name.toLowerCase(), finalAndroidArgs);
    if (path == null) {
      return null;
    } else {
      if (Platform.isIOS) {
        path = Uri.parse(path).toFilePath();
      }
      return File(path);
    }
  }

  /// Scanner to generate PDF file from scanned images
  ///
  /// `context` : BuildContext to attach PDF generation widgets
  /// `androidConfigs` : Android scanner labels configuration
  static Future<File?> launchForPdf(BuildContext context,
      {ScannerFileSource? source,
      Map<dynamic, String> labelsConfig = const {}}) async {
    Future<File?>? launchWrapper() {
      return launch(context, labelsConfig: labelsConfig, source: source);
    }

    return await Navigator.push<File>(
        context,
        MaterialPageRoute(
            builder: (_) => PdfGeneratotGallery(launchWrapper, labelsConfig)));
  }

  /// Scanner to get single scanned image
  ///
  /// `context` : BuildContext to attach source selection
  /// `source` : Either ScannerFileSource.CAMERA or ScannerFileSource.GALLERY
  /// `androidConfigs` : Android scanner labels configuration
  static Future<File?>? launch(
    BuildContext context, {
    ScannerFileSource? source,
    Map<dynamic, String> labelsConfig = const {},
    Uint8List? initialImage,
    bool canBackToInitial = true,
  }) {
    if (source != null) {
      return _scanDocument(source, labelsConfig,
          initialImage: initialImage, canBackToInitial: canBackToInitial);
    }
    return showModalBottomSheet<File>(
        context: context,
        isDismissible: true,
        builder: (BuildContext bc) {
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text(
                      labelsConfig[ScannerLabelsConfig.PICKER_CAMERA_LABEL] ??
                          'Camera'),
                  onTap: () async {
                    Navigator.pop(
                        context,
                        await _scanDocument(
                            ScannerFileSource.CAMERA, labelsConfig));
                  }),
              ListTile(
                leading: Icon(Icons.image_search),
                title: Text(
                    labelsConfig[ScannerLabelsConfig.PICKER_GALLERY_LABEL] ??
                        'Photo Library'),
                onTap: () async {
                  Navigator.pop(
                      context,
                      await _scanDocument(
                          ScannerFileSource.GALLERY, labelsConfig));
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text(
                    labelsConfig[ScannerLabelsConfig.PICKER_CANCEL_LABEL] ??
                        'Cancel'),
                onTap: () => Navigator.pop(context, null),
              ),
            ],
          );
        });
  }

  /// Retrieves lost scan data after an app crash or process death (Android only).
  ///
  /// Returns the last scanned image [File] if available, or `null`.
  static Future<File?> retrieveLostData() async {
    if (!Platform.isAndroid) return null;
    final String? path = await _channel.invokeMethod('retrieveLostData');
    if (path == null) return null;
    return File(path);
  }
}
