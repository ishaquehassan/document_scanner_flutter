# document_scanner_flutter

A document scanner plugin for flutter

## Getting Started

```dart
try {
    File scannedDoc = await DocumentScannerFlutter.launch();
} on PlatformException {
    // 'Failed to get document path or operation cancelled!';
}
```

## Or With Specific Option

```dart
try {
    File scannedDoc = await DocumentScannerFlutter.launch(ScannerFileSource.CAMERA); // Or ScannerFileSource.GALLERY
} on PlatformException {
    // 'Failed to get document path or operation cancelled!';
}
```
