import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_document_scanner/constants/tabs.dart';
import 'package:simple_document_scanner/providers/tab_provider.dart';
import 'package:simple_document_scanner/screens/about.dart';
import 'package:simple_document_scanner/screens/home.dart';
import 'package:simple_document_scanner/screens/scanner.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (_) => TabProvider(),
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Builder(builder: (context) {
                if (!Platform.isAndroid)
                  return AlertDialog(
                    title: Text('Not support'),
                    content: Text("This app isn't supported this platform"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close app'),
                        onPressed: () {
                          exit(0);
                        },
                      ),
                    ],
                  );

                if (context.watch<TabProvider>().tab == MyTab.home)
                  return HomeScreen();
                if (context.watch<TabProvider>().tab == MyTab.about)
                  return AboutScreen();
                throw Exception("Tab not found");
              }),
            ),
          ),
          bottomNavigationBar: Builder(builder: (context) {
            return BottomNavigationBar(
              items: <BottomNavigationBarItem>[
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
              duration: Duration(milliseconds: 100),
              child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ScannerScreen()));
                  },
                  child: Icon(Icons.scanner)),
            ),
          ),
        ),
      ),
    );
  }
}
