import 'dart:io';
import 'package:collection/collection.dart';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:simple_document_scanner/screens/photo_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<String> _imagePaths = [];

  Future<void> getImage() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      return;
    }

    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    try {
      bool success = await EdgeDetection.detectEdge(imagePath,
          canUseGallery: true,
          androidCropTitle: "Crop",
          androidScanTitle: "Scanning",
          androidCropBlackWhiteTitle: "BW Image",
          androidCropReset: "Reset Crop");
    } catch (e) {
      print(e);
    }

    if (!mounted) return;

    if (!(await File(imagePath).exists())) return;

    setState(() {
      _imagePaths.add(imagePath);
    });
  }

  void makePdf() async {
    final pdf = pw.Document();

    _imagePaths.forEach((element) {
      final image = pw.MemoryImage(
        File(element).readAsBytesSync(),
      );

      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image),
        );
      }));
    });

    String path = join((await getExternalStorageDirectory())!.path,
        "scanner-${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.pdf");
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: _imagePaths.length > 0,
        child: FloatingActionButton(
          onPressed: () {
            makePdf();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('File created!')));
          },
          child: Text('Make pdf'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ReorderableGridView.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: (_imagePaths.mapIndexed((index, e) => InkWell(
                key: ObjectKey(e),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPhotoView(imagePath: e),
                      ));
                },
                child: Card(
                  child: Stack(
                    alignment: Alignment.center,
                    key: ObjectKey(e),
                    children: [
                      Image.file(File(e)),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            _imagePaths.removeAt(index);
                          },
                          child: Container(
                              margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.red)),
                              padding: EdgeInsets.all(2.0),
                              child: Icon(color: Colors.red, Icons.close)),
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.white),
                              (index + 1).toString()))
                    ],
                  ),
                )))).toList(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final element = _imagePaths.removeAt(oldIndex);
                _imagePaths.insert(newIndex, element);
              });
            },
            footer: [
              InkWell(
                onTap: getImage,
                child: Card(
                  child: Center(
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
