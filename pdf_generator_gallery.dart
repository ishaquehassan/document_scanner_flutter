import 'dart:io';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/screens/photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

/// @nodoc
typedef Future<File?>? ScannerFilePicker();

/// @nodoc
class PdfGeneratotGallery extends StatefulWidget {
  final ScannerFilePicker filePicker;
  final Map<dynamic, String> labelsConfig;

  const PdfGeneratotGallery(this.filePicker, this.labelsConfig);

  @override
  _PdfGeneratotGalleryState createState() => _PdfGeneratotGalleryState();
}

class _PdfGeneratotGalleryState extends State<PdfGeneratotGallery> {
  List<File> files = [];

  addImage() async {
    var file = await widget.filePicker();
    if (file != null) {
      setState(() {
        files.add(file);
      });
    }
  }

  onDone() async {
    final pdf = pw.Document();
    for (var file in files) {
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(
            pw.MemoryImage(
              file.readAsBytesSync(),
            ),
          ),
        ); // Center
      }));
    }
    Directory tempDir = await getTemporaryDirectory();
    try {
      tempDir.createSync();
      final file =
      File("${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());
      Navigator.of(context).pop(file);
    } catch (e) {
      String message = "Unkown Error";
      if (e is FileSystemException) {
        message = e.osError?.message ?? 'File System Error';
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
    }
  }

  openViewer(File currentItem) {
    int index = files.map((e) => e.path).toList().indexOf(currentItem.path);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                PhotoViewer(galleryItems: files, selectedItemIndex: index)));
  }

  _removeFile(index) {
    if (index <= files.length - 1) {
      setState(() {
        files.removeAt(index);
      });
    }
  }

  String get itemsTitle {
    late String finalTitle;
    final String countHolder = "{PAGES_COUNT}";
    var singleTitle = widget.labelsConfig[
    ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_SINGLE] ??
        '$countHolder Page';
    var multiTitle = widget.labelsConfig[
    ScannerLabelsConfig.PDF_GALLERY_FILLED_TITLE_MULTIPLE] ??
        '$countHolder Pages';
    finalTitle = multiTitle;
    if (files.length == 1) {
      finalTitle = singleTitle;
    }
    if (!finalTitle.contains(countHolder) && files.length > 1) {
      finalTitle = "${files.length} $finalTitle";
    }
    return finalTitle.replaceAll(countHolder, "${files.length}");
  }

  Widget _mainControl(BuildContext context,
      {required String title,
        required Function onTap,
        required Color color,
        IconData? icon,
        Color textColor = Colors.black,
        required BorderRadius radius}) =>
      GestureDetector(
        onTap: () => onTap(),
        child: Container(
            decoration: BoxDecoration(borderRadius: radius, color: color),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(icon, size: 20, color: textColor),
                  ),
                Text(title, style: TextStyle(color: textColor))
              ],
            ),
            alignment: Alignment.center),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          (files.isEmpty)
              ? Center(
            child: Text(widget.labelsConfig[
            ScannerLabelsConfig.PDF_GALLERY_EMPTY_MESSAGE] ??
                "Aucun fichier numérisé n'est encore disponible !"),
          )
              : Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CustomScrollView(
              primary: false,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(3.0),
                  sliver: SliverGrid.count(
                      childAspectRatio: 10.0 / 9.0,
                      mainAxisSpacing: 1, //horizontal space
                      crossAxisSpacing: 1, //vertical space
                      crossAxisCount: 3, //number of images for a row
                      children: files
                          .map((image) => Hero(
                        tag: image.path,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => openViewer(image),
                              child: Image.file(
                                image,
                                height: 150,
                                width: MediaQuery.of(context)
                                    .size
                                    .width /
                                    3,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                                right: 5,
                                top: 5,
                                child: GestureDetector(
                                  onTap: () => _removeFile(files
                                      .map((e) => e.path)
                                      .toList()
                                      .indexOf(image.path)),
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey),
                                        borderRadius:
                                        BorderRadius.circular(
                                            15)),
                                    child: Icon(Icons.delete,
                                        size: 20,
                                        color: Colors.red),
                                  ),
                                ))
                          ],
                        ),
                      ))
                          .toList()),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10 + MediaQuery.of(context).padding.bottom,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.2),
                    spreadRadius: 1,
                    blurRadius: 10)
              ], borderRadius: BorderRadius.circular(25)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (files.isNotEmpty)
                    Expanded(
                        child: _mainControl(context,
                            color: Colors.blue,
                            icon: Icons.check,
                            title: widget.labelsConfig[ScannerLabelsConfig
                                .PDF_GALLERY_DONE_LABEL] ??
                                "Terminé",
                            textColor: Colors.white,
                            onTap: onDone,
                            radius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25)))),
                  Expanded(
                      child: _mainControl(context,
                          color:
                          files.isEmpty ? Colors.blue : Colors.cyanAccent,
                          icon: Icons.add_a_photo,
                          textColor:
                          files.isEmpty ? Colors.white : Colors.black,
                          title: widget.labelsConfig[ScannerLabelsConfig
                              .PDF_GALLERY_ADD_IMAGE_LABEL] ??
                              "Ajout de l'image",
                          onTap: addImage,
                          radius: files.isEmpty
                              ? BorderRadius.circular(25)
                              : BorderRadius.only(
                              topRight: Radius.circular(25),
                              bottomRight: Radius.circular(25)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}