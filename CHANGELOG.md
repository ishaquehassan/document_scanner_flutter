## 0.3.0

* **Breaking**: Minimum iOS deployment target bumped to 12.0
* **Breaking**: Minimum Flutter SDK bumped to 3.0.0, Dart SDK to 2.17.0
* Fixed Dart 3 incompatibility — SDK constraint updated to `<4.0.0`
* Fixed Flutter 3 incompatibility — `photo_view` updated to `^0.14.0`
* Fixed deprecated `describeEnum()` usage — replaced with `.name` enum property
* Fixed iOS path parsing bug — now uses `Uri.parse().toFilePath()` instead of fragile string split
* Fixed iOS scanner cancel and error not propagating back to Flutter (hanging Future bug)
* Fixed iOS `rootViewController` initialization for modern scene-based apps
* Fixed Android 13+ (API 33+) blank screen — `MediaStore.Images.Media.DATA` replaced with `ContentResolver.openInputStream()`
* Fixed Android null pointer crash on `onActivityResult` extras
* Fixed `abiFilters` to include `arm64-v8a` and `x86_64` — fixes release build crash on 64-bit devices
* Fixed missing back button in PDF gallery screen
* Fixed bottom sheet being non-dismissible with no cancel option — added Cancel tile
* Fixed PDF generation blocking UI thread — `readAsBytesSync()` replaced with async `readAsBytes()`
* Fixed `indexOf` usage for file removal and viewer opening — now uses direct index
* Removed dead Support Library dependency (`com.android.support:appcompat-v7`)
* Replaced sunset `jcenter()` with `mavenCentral()`
* Updated Android compile/target SDK to 34 (required for Google Play Store)
* Updated AGP to 7.4.2, Kotlin to 1.8.22
* Updated AndroidX dependencies to latest stable versions
* Pinned WeScan to `~> 2.1.0` — fixes Xcode 15+ Swift compiler error
* Reduced iOS JPEG compression from 100% to 80% for smaller file sizes
* Added `PICKER_CANCEL_LABEL` to `ScannerLabelsConfig` for cancel button customization

## 0.0.1

* Implemented Android Document Scanner Libarary

## 0.1.1

* Implemented iOS Document Scanner Libarary
* Migrated to null-safety
* Implemented Manual Source Selection

## 0.1.2

* Added doc
* Improved description
* Updated README
## 0.2.0

* Added PDF Generator Feature
* Fixed Android Scanner bugs
* Implemented Android scanner labels customization feature
## 0.2.1

* Fixed iOS compilation issue
## 0.2.2

* Fixed Android compilation issue for file provider
* Fixed Delete button on scanned images gird
## 0.2.3

* Added more labels to android scanner
* Removed unwanted action bar from android scanner
* Removed unwanted low memory warning from android scanner
* PDF Mode can now enforce source selection for scanning
  
## 0.2.4

* Fixed PDF gallery rendering issue on release build

## 0.2.5

* Safe area UI fixes