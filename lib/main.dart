import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:simple_document_scanner/components/prevent_back_press.dart';
import 'package:simple_document_scanner/constants/tabs.dart';
import 'package:simple_document_scanner/providers/tab_provider.dart';
import 'package:simple_document_scanner/screens/about.dart';
import 'package:simple_document_scanner/screens/home.dart';
import 'package:simple_document_scanner/screens/scanner.dart';
import 'package:simple_document_scanner/theme.dart';
import 'package:simple_document_scanner/utils/app.dart';

void main() {
  if (!Platform.isAndroid) {
    exit(0);
  }

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  void _dialogPermission(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => PreventBackPress(
              child: AlertDialog(
                title: const Text('Storage permission denied!'),
                content: const Text("This app need storage permission to run."),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close app'),
                    onPressed: () {
                      exit(0);
                    },
                  ),
                ],
              ),
            ));
  }

  Future<bool> _initApp(BuildContext context) async {
    bool isPermissionGranted;

    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      isPermissionGranted = await Permission.photos.request().isGranted;
    } else {
      isPermissionGranted = await Permission.storage.request().isGranted;
    }

    if (isPermissionGranted) {
      await makeAppFolder();
    } else {
      // ignore: use_build_context_synchronously
      _dialogPermission(context);
    }

    return isPermissionGranted;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (_) => TabProvider(),
        child: Scaffold(
          body: SafeArea(
            child: Builder(builder: (context) {
              return FutureBuilder(
                future: _initApp(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data!) {
                      if (context.watch<TabProvider>().tab == MyTab.home) {
                        return const HomeScreen();
                      }
                      if (context.watch<TabProvider>().tab == MyTab.about) {
                        return const AboutScreen();
                      }
                      throw Exception("Tab not found");
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }),
          ),
          bottomNavigationBar: Builder(builder: (context) {
            return BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
              ],
              currentIndex: context.watch<TabProvider>().tab.index,
              onTap: (value) {
                context.read<TabProvider>().changeTab(MyTab.values[value]);
              },
            );
          }),
          floatingActionButton: Consumer<TabProvider>(
            builder: (context, provider, __) => AnimatedOpacity(
              opacity: provider.tab == MyTab.home ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: FloatingActionButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ScannerScreen()));
                  },
                  child: const Icon(color: Colors.white, Icons.scanner)),
            ),
          ),
        ),
      ),
    );
  }
}
