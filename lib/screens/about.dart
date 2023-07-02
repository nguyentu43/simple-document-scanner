import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: Text(
                "About",
                style: TextStyle(fontSize: 35.0),
              ),
            ),
            const Text(
              "This app allow to make pdf from capture photo of documents. All pdf files located Download/sdc.",
            ),
            ElevatedButton(
                onPressed: () {
                  launchUrlString(
                      'mailto:nguyentu43.dev@gmail.com?subject=About Simple Document Scanner App');
                },
                child: const Text("Click here to email me!"))
          ],
        ),
      ),
    );
  }
}
