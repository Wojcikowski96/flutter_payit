import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatelessWidget {
  final String path;
  PdfView(this.path);
  @override
  Widget build(BuildContext context) {

    File file = new File(path);

    return Scaffold(
        body: Container(
            child: SfPdfViewer.file(file)));
  }
}




