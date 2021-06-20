dartdoc --exclude "package:document_scanner_flutter/screens/pdf_generator_gallery.dart,package:document_scanner_flutter/screens/photo_viewer.dart"
dartfmt -w .
open doc/api/index.html
pub publish --dry-run