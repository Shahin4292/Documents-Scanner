import 'dart:typed_data';
import 'package:doc_scanner/image_edit/text_recognition_screen.dart';
import 'package:doc_scanner/image_edit/widget/image_edit_button.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:doc_scanner/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../bottom_bar/bottom_bar.dart';
import '../camera_screen/camera_screen.dart';
import '../camera_screen/model/image_model.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import '../utils/helper.dart';
import 'add_sgnature_screen.dart';
import 'image_edit_screen.dart';

class EditImagePreview extends StatefulWidget {
  const EditImagePreview({super.key});

  @override
  State<EditImagePreview> createState() => _EditImagePreviewState();
}

class _EditImagePreviewState extends State<EditImagePreview> {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  TextEditingController _renameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: cameraProvider.imageList.isEmpty
            ? Text(translation(context).pleaseTakePhoto,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ))
            : Text(cameraProvider.imageList[_currentIndex].name,
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
            onPressed: () async {
              if (cameraProvider.imageList.isNotEmpty) {
                await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Colors.white),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(''),
                                Text(
                                  translation(context).documentFiles,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF4F4F4),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(Icons.close_rounded),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                _renameController.text = cameraProvider
                                    .imageList[_currentIndex].name;
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          Text(translation(context).renameFile),
                                      content: Form(
                                        key: _formKey,
                                        child: TextFormField(
                                          controller: _renameController,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.done,
                                          autofocus: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return translation(context)
                                                  .pleaseEnterFileName;
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: translation(context)
                                                .enterFileName,
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                                translation(context).cancel)),
                                        TextButton(
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                cameraProvider.updateImage(
                                                  index: _currentIndex,
                                                  image: ImageModel(
                                                    imageByte: cameraProvider
                                                        .imageList[
                                                            _currentIndex]
                                                        .imageByte,
                                                    name:
                                                        _renameController.text,
                                                    docType: cameraProvider
                                                        .imageList[
                                                            _currentIndex]
                                                        .docType,
                                                  ),
                                                );

                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text(
                                                translation(context).save)),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      translation(context).renameFile,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                            indent: MediaQuery.sizeOf(context).width * 0.15,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                showNormalAlertDialogue(
                                  context: context,
                                  title: translation(context).saveImages,
                                  content:  translation(context).doYouWantSaveAllImages,
                                  onOkText: translation(context).save,
                                  onCancelText:    translation(context).cancel,
                                  onOk: () async{
                                    await cameraProvider
                                        .exportAllImages()
                                        .then((value) {
                                      cameraProvider
                                          .clearImageList();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                          content: Text(
                                            translation(context)
                                                .allImagesSavedSuccessfully,
                                          )));
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const BottomBar();
                                            },
                                          ), (route) => false);
                                    });

                                  },
                                  onCancel: ()=>Navigator.pop(context),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.ios_share_outlined,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      translation(context).exportFiles,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                            indent: MediaQuery.sizeOf(context).width * 0.15,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                showNormalAlertDialogue(
                                  context: context,
                                  title: translation(context).deleteImage,
                                  content:  translation(context).doYouWantToDeleteThisImage,
                                  onOkText: translation(context).delete,
                                  onCancelText:    translation(context).cancel,
                                  onOk: () {
                                    cameraProvider.deleteImage(_currentIndex);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  onCancel: ()=>Navigator.pop(context),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      translation(context).delete,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            child:  Text(
              translation(context).option ,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          cameraProvider.imageList.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(
                      translation(context).noImageFound,
                    ),
                  ),
                )
              : Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: cameraProvider.imageList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3),
            child: Text(
              '${_currentIndex + 1}/${cameraProvider.imageList.length}',
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
              title: translation(context).share,
              onTap: () async {
                await AppHelper()
                    .convertUint8ListToFile(
                        data: cameraProvider.imageList[_currentIndex].imageByte,
                        extension: 'jpg')
                    .then((value) async {
                  await Share.shareXFiles([XFile(value.path)]);
                });
              },
              iconPath: AppAssets.share,
            ),
            ImageEditButton(
              title: translation(context).edit,
              onTap: () {
                if (cameraProvider.imageList.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageEditScreen(
                        imageIndex: _currentIndex,
                        image: cameraProvider.imageList[_currentIndex],
                      ),
                    ),
                  );
                }
              },
              iconPath: AppAssets.edit,
            ),
            Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                builder: (context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CameraScreen(
                                    isComeFromAdd: true,
                                  ),
                                ));
                          },
                          child: Container(
                            height: 100,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColor.primaryColor,
                                ),
                                Text(
                                  translation(context).camera,
                                  style:
                                  TextStyle(color: AppColor.primaryColor),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(context);

                            final ImagePicker _picker = ImagePicker();
                            final List<XFile?> image = await _picker
                                .pickMultiImage(limit: 5, imageQuality: 50);
                            if (image.isNotEmpty) {
                              for (int i = 0; i < image.length; i++) {
                                String documentName =
                                DateFormat('yyyyMMdd_SSSS')
                                    .format(DateTime.now());
                                if (image[i] != null) {
                                  cameraProvider.addImage(
                                    ImageModel(
                                      imageByte:
                                      await image[i]!.readAsBytes(),
                                      name: 'Doc-$documentName',
                                      docType: 'Document',
                                    ),
                                  );
                                }
                              }
                              Navigator.of(context);
                            }
                          },
                          child: Container(
                            height: 100,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_outlined,
                                  color: AppColor.primaryColor,
                                ),
                                Text(
                                  translation(context).gallery,
                                  style:
                                  TextStyle(color: AppColor.primaryColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.addPage,
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    translation(context).addPage,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
            ImageEditButton(
              title: translation(context).convert,
              onTap: () async {
                final Uint8List textRecognitionImage =
                    cameraProvider.imageList[_currentIndex].imageByte;
                await AppHelper()
                    .convertUint8ListToFile(data: textRecognitionImage)
                    .then((value) async {
                  final inputImage = InputImage.fromFile(value);
                  final textRecognizer =
                      TextRecognizer(script: TextRecognitionScript.latin);
                  await textRecognizer
                      .processImage(inputImage)
                      .then((recognizedText) {
                    String text = recognizedText.text;
                    if (text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                        translation(context).noTextFound,
                      )));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TextRecognitionScreen(recognisedText: text),
                        ),
                      );
                    }
                  });
                });
              },
              iconPath: AppAssets.ocr,
            ),
            ImageEditButton(
              title: translation(context).sign,
              onTap: () {
                if (cameraProvider.imageList.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSignature(
                        imageModel: cameraProvider.imageList[_currentIndex],
                        imageIndex: _currentIndex,
                      ),
                    ),
                  );
                }
              },
              iconPath: AppAssets.sign,
            ),
          ],
        ),
      ),
    );
  }
}
