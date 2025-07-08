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
              "This app allows you to create PDF files by capturing photos of documents. All generated PDFs are saved in the Download/sdc folder.",
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
