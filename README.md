# document_scanner_flutter [![pub package](https://img.shields.io/pub/v/document_scanner_flutter.svg)](https://pub.dev/packages/document_scanner_flutter)

A document scanner + PDF generator plugin for Flutter. Supports Android and iOS with auto edge detection, cropping, B&W filter, and PDF generation.

<img src="https://user-images.githubusercontent.com/5463915/126216398-a49a9178-e483-4244-859f-7974ce249a02.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216417-5a09dd28-6e8e-435e-83f0-703716dfe108.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216432-8e140a70-e471-4ae3-8da0-a105e15109aa.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216440-51c7102b-f3fa-495f-b8d8-3da14e1fde0f.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216449-6633a45b-7171-4cfe-b37f-48fc5e48e5f0.png" width="150" /> <img src="https://user-images.githubusercontent.com/5463915/126216454-13be78c8-510f-4181-818c-7ebdbaef67b9.png" width="150" />

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| Android  | API 21 (Android 5.0) |
| iOS      | iOS 12.0 |
| Flutter  | 3.0.0 |
| Dart     | 2.17.0 |

## Getting Started

#### Installing

```yaml
document_scanner_flutter: ^0.4.0
```

## Usage

#### Basic — Camera or Gallery picker

```dart
final File? scannedDoc = await DocumentScannerFlutter.launch(context);
// returns null if user cancels
```

#### Specific source

```dart
final File? scannedDoc = await DocumentScannerFlutter.launch(
  context,
  source: ScannerFileSource.CAMERA, // or ScannerFileSource.GALLERY
);
```

#### Re-edit an existing image (v0.4.0+)

```dart
final Uint8List imageBytes = await myFile.readAsBytes();

final File? rescanned = await DocumentScannerFlutter.launch(
  context,
  source: ScannerFileSource.CAMERA,
  initialImage: imageBytes,
  canBackToInitial: true,
);
```

#### Recover last scan after crash (v0.4.0+)

```dart
// Call this on app startup to recover image lost due to process death
final File? recovered = await DocumentScannerFlutter.retrieveLostData();
if (recovered != null) {
  // use recovered image
}
```

#### PDF generation from multiple scans

```dart
final File? pdfFile = await DocumentScannerFlutter.launchForPdf(
  context,
  source: ScannerFileSource.CAMERA,
);
// returns a PDF File or null if cancelled
```

#### Labels customization

```dart
final File? scannedDoc = await DocumentScannerFlutter.launch(
  context,
  source: ScannerFileSource.CAMERA,
  labelsConfig: {
    ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: 'Next',
    ScannerLabelsConfig.ANDROID_SAVE_BUTTON_LABEL: 'Save',
    ScannerLabelsConfig.ANDROID_ROTATE_LEFT_LABEL: 'Rotate Left',
    ScannerLabelsConfig.ANDROID_ROTATE_RIGHT_LABEL: 'Rotate Right',
    ScannerLabelsConfig.ANDROID_ORIGINAL_LABEL: 'Original',
    ScannerLabelsConfig.ANDROID_BMW_LABEL: 'B & W',
    ScannerLabelsConfig.PICKER_CAMERA_LABEL: 'Camera',
    ScannerLabelsConfig.PICKER_GALLERY_LABEL: 'Gallery',
    ScannerLabelsConfig.PICKER_CANCEL_LABEL: 'Cancel',
    ScannerLabelsConfig.ANDROID_INITIAL_IMAGE_LOADING_MESSAGE: 'Loading image...',
  },
);
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for full release history.
