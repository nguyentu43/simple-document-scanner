import 'dart:io';

import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:path/path.dart';

import '../constants/app.dart';

Future<String> getAppDirectory() async {
  return join((await DownloadsPath.downloadsDirectory())!.path, sAppName);
}

Future<void> makeAppFolder() async {
  Directory(await getAppDirectory()).createSync();
}
