import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:simple_document_scanner/utils/app.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<File> _pdfFiles = [];
  late StreamSubscription<FileSystemEvent> _watchDirectorySubscription;

  @override
  void initState() {
    super.initState();
    _getFiles();
    _watchDirectory();
  }

  Future<void> _watchDirectory() async {
    _watchDirectorySubscription = Directory(await getAppDirectory())
        .watch(events: FileSystemEvent.create)
        .listen((event) {
      _getFiles();
    });
  }

  Future<void> _getFiles() async {
    setState(() {
      _loading = true;
    });

    var files = (await Directory(await getAppDirectory())
            .list()
            .where((e) => e is File && e.path.endsWith('.pdf'))
            .cast<File>()
            .toList())
        .reversed
        .toList();
    setState(() {
      _loading = false;
      _pdfFiles = files;
    });
  }

  @override
  void dispose() {
    _watchDirectorySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text(
            "Home",
            style: TextStyle(fontSize: 35.0),
          ),
        ),
        Builder(
          builder: (context) {
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_pdfFiles.isNotEmpty) {
              return Column(
                children: _pdfFiles
                    .map((File e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  OpenFile.open(e.path);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.picture_as_pdf),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                          style:
                                              const TextStyle(fontSize: 24.0),
                                          DateFormat('dd/MM/yyyy HH:mm:ss')
                                              .format(e.lastModifiedSync()))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete this file'),
                                      content: const Text(
                                          'Do you want to delete this file?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            e.deleteSync();
                                            _getFiles();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Icon(Icons.close),
                                ))
                          ],
                        ))
                    .toList(),
              );
            }
            return const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    Text('No scanner document. Press below button to scan.'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ));
  }
}
