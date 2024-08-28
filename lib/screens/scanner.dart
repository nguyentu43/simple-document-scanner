import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:simple_document_scanner/components/prevent_back_press.dart';
import 'package:simple_document_scanner/constants/app.dart';
import 'package:simple_document_scanner/screens/photo_view.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<String> _imagePaths = [];

  Future<void> getImage() async {
    final imagesPath = await CunningDocumentScanner.getPictures(true);

    if (imagesPath!.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(imagesPath);
      });
    }
  }

  Future<void> makePdf(BuildContext context) async {
    final pdf = pw.Document();

    for (var element in _imagePaths) {
      final image = pw.MemoryImage(
        File(element).readAsBytesSync(),
      );

      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image),
        );
      }));
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PreventBackPress(
            child: const AlertDialog(
              title: Text('Making PDF File...'),
              content: SizedBox(
                  height: 90,
                  child: Center(child: CircularProgressIndicator())),
            ),
          );
        });

    String path = join(
        (await DownloadsPath.downloadsDirectory())!.path,
        sAppName,
        "scanner-${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.pdf");
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(showCloseIcon: true, content: Text('File created!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
          visible: _imagePaths.isNotEmpty,
          child: FloatingActionButton.extended(
              onPressed: () {
                makePdf(context);
              },
              label: const Row(
                children: [
                  Icon(color: Colors.white, Icons.picture_as_pdf),
                  Text(style: TextStyle(color: Colors.white), 'Make PDF'),
                ],
              ))),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
              child: Text(
                "Tap + button to add some pictures",
                style: TextStyle(fontSize: 35.0),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ReorderableGridView.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      final element = _imagePaths.removeAt(oldIndex);
                      _imagePaths.insert(newIndex, element);
                    });
                  },
                  footer: [
                    InkWell(
                      onTap: getImage,
                      child: const Card(
                        child: Center(
                          child: Icon(size: 60, Icons.add_a_photo),
                        ),
                      ),
                    ),
                  ],
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete this photo'),
                                      content: const Text(
                                          'Do you want to delete this photo?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _imagePaths.removeAt(index);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5.0, bottom: 5.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: const Icon(Icons.close)),
                              ),
                            ),
                            Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                    style: const TextStyle(
                                        fontSize: 24.0, color: Colors.white),
                                    (index + 1).toString()))
                          ],
                        ),
                      )))).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
