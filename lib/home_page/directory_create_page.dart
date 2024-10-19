import 'dart:io';
import 'dart:ui';
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class DirectoryCreatePage extends StatefulWidget {
  const DirectoryCreatePage({super.key});

  @override
  State<DirectoryCreatePage> createState() => _DirectoryCreatePageState();
}

class _DirectoryCreatePageState extends State<DirectoryCreatePage> {
  @override
  void initState() {
    super.initState();
  }

  Directory? selectedDirectory;

  TextEditingController _directoryNameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final homePageProvider = context.watch<HomePageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translation(context).createDirectory,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
              fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: selectedDirectory,
                items: homePageProvider.directories
                    .map((e) => DropdownMenuItem<Directory>(
                        value: e, child: Text(e.path.split("/").last)))
                    .toList(),
                onChanged: (Directory? value) {
                  setState(() {
                    selectedDirectory = value;
                  });
                },
                hint: Text(translation(context).selectDirectory),
                validator: (value) {
                  if (value == null) {
                    return translation(context).pleaseSelectADirectory;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _directoryNameController,
                decoration: InputDecoration(
                  hintText: translation(context).enterDirectoryName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return translation(context).pleaseEnterADirectoryName;
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  fixedSize: Size(MediaQuery.sizeOf(context).width, 50),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (_directoryNameController.text.trim().isNotEmpty) {
                      homePageProvider
                          .createDirectory(
                              directory: selectedDirectory!,
                              directoryName: _directoryNameController.text)
                          .then((value) => Navigator.pop(context));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            translation(context).pleaseEnterADirectoryName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  translation(context).createDirectory,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
