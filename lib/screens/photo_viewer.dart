import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// @nodoc
class PhotoViewer extends StatelessWidget {
  final List<File> galleryItems;
  final int selectedItemIndex;

  PhotoViewer({required this.galleryItems, this.selectedItemIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
          child: PhotoViewGallery.builder(
              pageController: PageController(initialPage: selectedItemIndex),
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(galleryItems[index]),
                  initialScale: PhotoViewComputedScale.contained * 1,
                  heroAttributes:
                      PhotoViewHeroAttributes(tag: galleryItems[index].path),
                );
              },
              itemCount: galleryItems.length,
              loadingBuilder: (context, event) => Center(
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                (event.expectedTotalBytes ?? 0),
                      ),
                    ),
                  ))),
    );
  }
}
