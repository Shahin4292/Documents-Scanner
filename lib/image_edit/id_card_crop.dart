import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_crop_plus/image_crop_plus.dart';
import 'package:provider/provider.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';




class ImageCropping extends StatefulWidget {
  final int index;
  final File imageFile;

  const ImageCropping({super.key, required this.imageFile, required this.index});

  @override
  State<ImageCropping> createState() => _ImageCroppingState();
}

class _ImageCroppingState extends State<ImageCropping> {
  final cropKey = GlobalKey<CropState>();
  File? file, sample, lastCropped;

  @override
  Widget build(BuildContext context) {

    final cameraPageProvider = context.watch<CameraProvider>();
    return Scaffold(
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.07,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        translation(context).cancel,
                        style: const TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
              const VerticalDivider(thickness: 2),
              Expanded(
                flex: 1,
                child: CupertinoButton(
                  onPressed: () async {
                    final scale = cropKey.currentState!.scale;
                    final area = cropKey.currentState!.area;
                    final sample = await ImageCrop.sampleImage(
                      file: widget.imageFile,
                      preferredSize: (2000 / scale).round(),
                    );
                    final file = await ImageCrop.cropImage(file: sample, area: area!);
                    sample.delete(recursive: true);
                    cameraPageProvider.replaceIdCardImage(index: widget.index, imagePath: file.path);
                    Navigator.pop(context);
                  },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        translation(context).done,
                        style: const TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Crop.file(
            widget.imageFile,
            key: cropKey,
          ),
        ));
  }
}
