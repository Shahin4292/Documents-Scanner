import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:doc_scanner/camera_screen/model/image_model.dart';
import 'package:doc_scanner/image_edit/widget/image_edit_button.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:interactive_box/interactive_box.dart';
import 'package:provider/provider.dart';

import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import 'drawing.dart';

class AddSignature extends StatefulWidget {
  final ImageModel imageModel;
  final int imageIndex;

  const AddSignature(
      {super.key, required this.imageModel, required this.imageIndex});

  @override
  State<AddSignature> createState() => _AddSignatureState();
}

class _AddSignatureState extends State<AddSignature> {
  String? signaturePath;

  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    return Scaffold(
      appBar: AppBar(
        title:  Text( translation(context).addSignature,style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              var image = await captureImage();

              if (image != null) {
                cameraProvider.updateImage(
                    image: ImageModel(
                        imageByte: image,
                        name: widget.imageModel.name,
                        docType: widget.imageModel.docType),
                    index: widget.imageIndex);
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.done,
              color: AppColor.primaryColor,size: 30,
            ),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.memory(
                widget.imageModel.imageByte,
                fit: BoxFit.cover,
              ),
            ),
            if (signaturePath != null)
              InteractiveBox(
                includedScaleDirections: const [
                  ScaleDirection.topRight,
                  ScaleDirection.bottomRight,
                  ScaleDirection.bottomLeft,
                  ScaleDirection.topLeft,
                ],
                initialSize: const Size(250, 150),
                includedActions: const [
                  ControlActionType.move,
                  ControlActionType.scale,
                  ControlActionType.rotate,
                  ControlActionType.delete,
                ],
                onActionSelected: (ControlActionType controlActionType,
                    InteractiveBoxInfo interactiveBoxInfo) {
                  if (controlActionType == ControlActionType.delete) {
                    setState(() {
                      signaturePath = null;
                    });
                  }
                },
                initialShowActionIcons: true,
                rotateIndicatorSpacing: 10,
                child: SvgPicture.string(signaturePath!, fit: BoxFit.cover),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ImageEditButton(
        title:  translation(context).draw,
        onTap: () async {
          var signature = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DrawingScreen(),
            ),
          );
          if (signature != null) {
            setState(() {
              signaturePath = signature;
            });
          }
        },
        iconPath: AppAssets.sign,
      ),
      ),
    );
  }

  Future<Uint8List?> captureImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}
