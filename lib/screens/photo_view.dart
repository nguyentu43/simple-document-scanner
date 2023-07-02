import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MyPhotoView extends StatelessWidget {
  final _imagePath;
  const MyPhotoView({super.key, required imagePath}) : _imagePath = imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PhotoView(imageProvider: Image.file(File(_imagePath)).image));
  }
}
