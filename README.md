# document_scanner_flutter [![pub package](https://img.shields.io/pub/v/document_scanner_flutter.svg)](https://pub.dev/packages/document_scanner_flutter)

A document scanner + PDF generator plugin for flutter

## Getting Started
#### Installing

```yaml
document_scanner_flutter: ^0.2.0
```

#### Basic Usage

```dart
try {
    File scannedDoc = await DocumentScannerFlutter.launch();
    // `scannedDoc` will be the image file scanned from scanner
} on PlatformException {
    // 'Failed to get document path or operation cancelled!';
}
```

#### Or With Specific Source (Gallery / Camera)

```dart
try {
    File scannedDoc = await DocumentScannerFlutter.launch(source: ScannerFileSource.CAMERA); // Or ScannerFileSource.GALLERY
    // `scannedDoc` will be the image file scanned from scanner
} on PlatformException {
    // 'Failed to get document path or operation cancelled!';
}
```


## New Features! 🎊🥳😎
#### PDF generation of scanned images
``` dart
try {
    File scannedDoc = await DocumentScannerFlutter.launchForPdf(source: ScannerFileSource.CAMERA); // Or ScannerFileSource.GALLERY
    // `scannedDoc` will be the PDF file generated from scanner
} on PlatformException {
    // 'Failed to get document path or operation cancelled!';
}
```

#### Android Scanner labels customization
```dart
try {
    // Other Android Scanner labels customization 
    var androidLabelsConfigs = {
        ScannerConfigsAndroid.ANDROID_NEXT_BUTTON_TITLE : "Next Step",
        ScannerConfigsAndroid.ANDROID_SAVE_BUTTON_TITLE: "Save It",
        ScannerConfigsAndroid.ANDROID_ROTATE_LEFT_TITLE: "Turn it left",
        ScannerConfigsAndroid.ANDROID_ROTATE_RIGHT_TITLE: "Turn it right",
        ScannerConfigsAndroid.ANDROID_ORIGINAL_TITLE: "Original",
        ScannerConfigsAndroid.ANDROID_BMW_TITLE: "B & W"
    } 

    File scannedDoc = await DocumentScannerFlutter.launchForPdf(source: ScannerFileSource.CAMERA,androidConfigs: androidLabelsConfigs); 
    // `scannedDoc` will be the PDF file generated from scanner
} on PlatformException {
    // 'Failed to get document path or operation cancelled!';
}
```

