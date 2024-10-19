import 'dart:io';
import 'dart:typed_data';

import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../model/image_model.dart';

class CameraProvider extends ChangeNotifier{

  final List<String> _documentType = ['Documents', 'ID Card', 'QR Code', 'Bar Code'];
  List<String> get documentTypes => _documentType;


  List<ImageModel> _imageList= [];
  List<ImageModel> get imageList => _imageList;


  void addImage(ImageModel image){
    _imageList.add(image);
    notifyListeners();
  }


  void updateImage({required int index, required ImageModel image}){
    _imageList[index] = image;
    notifyListeners();
  }


  void deleteImage(int index){
    _imageList.removeAt(index);
    notifyListeners();
  }


  void clearImageList(){
    _imageList.clear();
    notifyListeners();
  }



  List<String> _idCardImages = [];
  List<String> get idCardImages => _idCardImages;

  void addIdCardImage(String imagePath){
    _idCardImages.add(imagePath);
    notifyListeners();
  }



  void reverseIdCardImages(){
    _idCardImages = _idCardImages.reversed.toList();
    notifyListeners();
  }

  void clearIdCardImages(){
    _idCardImages.clear();
    notifyListeners();
  }

  void replaceIdCardImage({required int index, required String imagePath}){
    _idCardImages[index] = imagePath;
    notifyListeners();
  }

  Future<void> exportAllImages()async{
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String documentDirectoryPath = '${appDirectory.path}/Doc Scanner/Document';
    final String idCardDirectoryPath = '${appDirectory.path}/Doc Scanner/ID Card';
    for(int i=0; i<_imageList.length; i++){
      final Uint8List bytes = _imageList[i].imageByte;
      if(_imageList[i].docType == 'ID Card'){
        final String imagePath = '$idCardDirectoryPath/${_imageList[i].name}.jpg';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(bytes);
      }else{
        final String imagePath = '$documentDirectoryPath/${_imageList[i].name}.jpg';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(bytes);
      }
    }
  }

  Future<void> saveQRCodeText(String text, BuildContext context) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    final fileName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
    String filePath = '${appDir.path}/Doc Scanner/QR Code/QrCode-$fileName.txt';
    File file = File(filePath);
    await file.writeAsString(text);
    context.read<HomePageProvider>().addQrCodeFile(text);
  }
  Future<void> saveBarCodeText(String text,BuildContext context) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    final fileName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
    String filePath = '${appDir.path}/Doc Scanner/Bar Code/BarCode$fileName.txt';
    File file = File(filePath);
    await file.writeAsString(text);
    context.read<HomePageProvider>().addBarCodeFile(text);
  }

}