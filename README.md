# document_scanner_flutter [![pub package](https://img.shields.io/pub/v/document_scanner_flutter.svg)](https://pub.dev/packages/document_scanner_flutter)

A document scanner + PDF generator plugin for flutter

<img src="https://user-images.githubusercontent.com/5463915/126216398-a49a9178-e483-4244-859f-7974ce249a02.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216417-5a09dd28-6e8e-435e-83f0-703716dfe108.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216432-8e140a70-e471-4ae3-8da0-a105e15109aa.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216440-51c7102b-f3fa-495f-b8d8-3da14e1fde0f.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216449-6633a45b-7171-4cfe-b37f-48fc5e48e5f0.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216454-13be78c8-510f-4181-818c-7ebdbaef67b9.png" width="150" />


## Getting Started
#### Installing

```yaml
document_scanner_flutter: ^0.2.3
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

