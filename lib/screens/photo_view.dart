import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:photo_view/photo_view.dart';

class MyPhotoView extends StatelessWidget {
  MyPhotoView({super.key, required imagePath}) : _imagePath = imagePath;
  String _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PhotoView(imageProvider: Image.file(File(_imagePath)).image));
  }
}
