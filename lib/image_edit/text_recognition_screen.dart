import 'dart:io';

import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../localaization/language_constant.dart';

class TextRecognitionScreen extends StatefulWidget {

  final String recognisedText;
  const TextRecognitionScreen({super.key, required this.recognisedText});

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  TextEditingController textEditingController = TextEditingController();


  @override
  void initState() {
    textEditingController.text = widget.recognisedText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text( translation(context).recognizeText,
          style: const TextStyle(fontSize: 18),),
        actions: [
          TextButton(
            onPressed: () async{
              final pdf = pw.Document();
              pdf.addPage(
                pw.Page(
                  build: (pw.Context context) =>
                      pw.Center(
                        child: pw.Text(textEditingController.text),
                      ),
                ),
              );
              final applicationDirectory = await getApplicationDocumentsDirectory();
              final fileName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
              final savePath = '${applicationDirectory.path}/Doc Scanner/Document/$fileName.pdf';
              final file = File(savePath);
              await file.writeAsBytes(await pdf.save(), flush: true).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text( translation(context).pdfFileSavedAtDocumentDirectory,
                        style: TextStyle(color: Colors.white)),
                    duration: Duration(seconds: 2),
                  ),
                );
                OpenFilex.open(value.path);
              });
            },
            child:  Text(
                translation(context).save,
              style: const TextStyle(
                fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: textEditingController,
          maxLines: null,
          decoration: const InputDecoration(
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
