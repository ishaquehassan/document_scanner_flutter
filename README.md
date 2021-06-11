# document_scanner_flutter

A document scanner plugin for flutter

## Getting Started

```dart
try {
    File scannedDoc = await DocumentScannerFlutter.scanDocument();
} on PlatformException {
    // 'Failed to get document path or operation cancelled!';
}
```
