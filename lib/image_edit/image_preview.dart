import 'dart:typed_data';
import 'package:doc_scanner/bottom_bar/bottom_bar.dart';
import 'package:doc_scanner/camera_screen/camera_screen.dart';
import 'package:doc_scanner/image_edit/crop_screen.dart';
import 'package:doc_scanner/image_edit/text_recognition_screen.dart';
import 'package:doc_scanner/image_edit/widget/image_edit_button.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:doc_scanner/utils/helper.dart';
import 'package:doc_scanner/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import 'package:image/image.dart' as img;
import 'add_sgnature_screen.dart';
import 'image_edit_preview.dart';
import 'image_rotation.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showNormalAlertDialogue(
          context: context,
          title: translation(context).discardDocument,
          content: translation(context).ifYouLeaveYourProgressWillBeLost,
          onOkText: translation(context).discard,
          onCancelText: translation(context).keepEditing,
          onOk: () {
            cameraProvider.clearImageList();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomBar(),
                ),
                    (route) => false);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: cameraProvider.imageList.isEmpty
              ? Text(translation(context).pleaseTakePhoto,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ))
              : Text(cameraProvider.imageList[currentIndex].name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  )),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) {
                    return const EditImagePreview();
                  },
                ), (route) => true);
              },
              child: Text(
                translation(context).next,
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cameraProvider.imageList.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(translation(context).noImageFound),
                    ),
                  )
                : Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: cameraProvider.imageList.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.memory(
                          cameraProvider.imageList[index].imageByte,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3),
              child: Text(
                cameraProvider.imageList.isEmpty
                    ? '$currentIndex/${cameraProvider.imageList.length}'
                    : '${currentIndex + 1}/${cameraProvider.imageList.length}',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageEditButton(
                title: translation(context).retake,
                onTap: () {
                  if (cameraProvider.imageList.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          initialPage:
                              cameraProvider.imageList[currentIndex].docType ==
                                      "Document"
                                  ? 0
                                  : 1,
                          isComeFromRetake: true,
                          imageIndex: currentIndex,
                          imageModel: cameraProvider.imageList[currentIndex],
                        ),
                      ),
                    );
                  }
                },
                iconPath: AppAssets.retake,
              ),
              ImageEditButton(
                title: translation(context).rotate,
                onTap: () async {
                  if (cameraProvider.imageList.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageRotation(
                          imageModel: cameraProvider.imageList[currentIndex],
                          index: currentIndex,
                        ),
                      ),
                    );
                  }
                },
                iconPath: AppAssets.rotate,
              ),
              ImageEditButton(
                title: translation(context).reframe,
                onTap: () async {
                  if (cameraProvider.imageList.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CropScreen(
                          imageModel: cameraProvider.imageList[currentIndex],
                          index: currentIndex,
                        ),
                      ),
                    );
                  }
                },
                iconPath: AppAssets.reFrame,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
