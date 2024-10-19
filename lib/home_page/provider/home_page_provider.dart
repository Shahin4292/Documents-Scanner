import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class HomePageProvider extends ChangeNotifier {
  List<Directory> _directories = [];

  List<Directory> get directories => _directories;

  Future<void> getDirectoriesForCreate() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final Directory pdfConverterDirectory =
        Directory('${appDirectory.path}/Doc Scanner');
    _directories =
        pdfConverterDirectory.listSync().whereType<Directory>().toList();
    directories.sort((a, b) {
      Map<String, int> order = {
        'D': 0,
        'I': 1,
        'Q': 2,
        'B': 3,
      };
      String aFirstLetter = a.path.split('/').last[0];
      String bFirstLetter = b.path.split('/').last[0];
      int aOrder = order.containsKey(aFirstLetter) ? order[aFirstLetter]! : 4;
      int bOrder = order.containsKey(bFirstLetter) ? order[bFirstLetter]! : 4;
      return aOrder.compareTo(bOrder);
    });
    notifyListeners();
  }

  Future<void> createDirectory({
    required Directory directory,
    required String directoryName,
  }) async {
    final Directory newDirectory =
        Directory('${directory.path}/$directoryName');
    if (!await newDirectory.exists()) {
      await newDirectory.create(recursive: true);
    }
  }

  List<File> _documentImageFiles = [];

  List<File> get documentImageFiles => _documentImageFiles.reversed.toList();

  List<File> _idCardImageFiles = [];

  List<File> get idCardImageFiles => _idCardImageFiles.reversed.toList();

  List<String> _qrCodeFiles = [];

  List<String> get qrCodeFiles => _qrCodeFiles.reversed.toList();

  List<String> _barCodeFiles = [];

  List<String> get barCodeFiles => _barCodeFiles.reversed.toList();



  void addDocumentImage(File file) {
    _documentImageFiles.add(file);
    notifyListeners();
  }

  void addIdCardImage(File file) {
    _idCardImageFiles.add(file);
    notifyListeners();
  }

  void removeDocumentImage(String imagePath) {
    int index = _documentImageFiles.indexWhere((file) => file.path.split("/").last == imagePath.split("/").last);
    _documentImageFiles.removeAt(index);
    notifyListeners();
  }
  void removeIdCarImage(String imagePath) {
    int index = _idCardImageFiles.indexWhere((file) =>  file.path.split("/").last == imagePath.split("/").last);
    _idCardImageFiles.removeAt(index);
    notifyListeners();
  }



  void removeBarCode(String barCode) {
    int index= _barCodeFiles.indexOf(barCode);
    _barCodeFiles.removeAt(index);
      notifyListeners();
  }

  void removeQrCode(String qrCode) {
    int index= _qrCodeFiles.indexOf(qrCode);
    _qrCodeFiles.removeAt(index);
    notifyListeners();
  }

  void addQrCodeFile(String qrCode) {
    _qrCodeFiles.add(qrCode);
    notifyListeners();
  }

  void addBarCodeFile(String qrCode) {
    _barCodeFiles.add(qrCode);
    notifyListeners();
  }

  void clearDocumentImageFiles() {
    _documentImageFiles.clear();
    notifyListeners();
  }

  void clearIdCardImageFiles() {
    _idCardImageFiles.clear();
    notifyListeners();
  }

  void clearQRCodeFiles() {
    _qrCodeFiles.clear();
    notifyListeners();
  }

  void clearBarCodeFiles() {
    _barCodeFiles.clear();
    notifyListeners();
  }

  Future<void> loadDocumentImage() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory documentDirectory =
          Directory('${appDir.path}/Doc Scanner/Document');
      await for (FileSystemEntity entity in documentDirectory.list()) {
        if (entity is Directory) {
          await for (FileSystemEntity subEntity in entity.list()) {
            if (subEntity is File) {
              String filePath = subEntity.path;
              if (filePath.toLowerCase().endsWith('.jpg') ||
                  filePath.toLowerCase().endsWith('.jpeg') ||
                  filePath.toLowerCase().endsWith('.pdf') ||
                  filePath.toLowerCase().endsWith('.png')) {
                _documentImageFiles.add(File(filePath));
              }
            }
          }
        } else if (entity is File) {
          String filePath = entity.path;
          if (filePath.toLowerCase().endsWith('.jpg') ||
              filePath.toLowerCase().endsWith('.jpeg') ||
              filePath.toLowerCase().endsWith('.pdf') ||
              filePath.toLowerCase().endsWith('.png')) {
            _documentImageFiles.add(File(filePath));
          }
        }
      }
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> loadIdCardImage() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory documentDirectory =
          Directory('${appDir.path}/Doc Scanner/ID Card');
      await for (FileSystemEntity entity in documentDirectory.list()) {
        if (entity is Directory) {
          await for (FileSystemEntity subEntity in entity.list()) {
            if (subEntity is File) {
              String filePath = subEntity.path;
              if (filePath.toLowerCase().endsWith('.jpg') ||
                  filePath.toLowerCase().endsWith('.jpeg') ||
                  filePath.toLowerCase().endsWith('.pdf') ||
                  filePath.toLowerCase().endsWith('.png')) {
                _idCardImageFiles.add(File(filePath));
              }
            }
          }
        } else if (entity is File) {
          String filePath = entity.path;
          if (filePath.toLowerCase().endsWith('.jpg') ||
              filePath.toLowerCase().endsWith('.jpeg') ||
              filePath.toLowerCase().endsWith('.pdf') ||
              filePath.toLowerCase().endsWith('.png')) {
            _idCardImageFiles.add(File(filePath));
          }
        }
      }

      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadQRCode() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory textFilesDir = Directory('${appDir.path}/Doc Scanner/QR Code');
      List<FileSystemEntity> files = textFilesDir.listSync();
      List<File> textFiles = files
          .where((file) {
            return file.path.toLowerCase().endsWith('.txt');
          })
          .map((file) => File(file.path))
          .toList();
      for (File file in textFiles) {
        String content = await file.readAsString();
        _qrCodeFiles.add(content);
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadBarCode() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory textFilesDir = Directory('${appDir.path}/Doc Scanner/Bar Code');
      List<File> textFiles = [];
      await for (FileSystemEntity entity in textFilesDir.list()) {
        if (entity is Directory) {
          await for (FileSystemEntity subEntity in entity.list()) {
            if (subEntity is File) {
              String filePath = subEntity.path;
              if (filePath.toLowerCase().endsWith('.txt')) {
                textFiles.add(File(filePath));
              }
            }
          }
        } else if (entity is File) {
          String filePath = entity.path;
          if (filePath.toLowerCase().endsWith('.txt')) {
            textFiles.add(File(filePath));
          }
        }
      }
      for (File file in textFiles) {
        String content = await file.readAsString();
        _barCodeFiles.add(content);
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<String>> getFileList(String directoryPath) async {
    List<String> subdirectoryPaths = [];
    List<String> imageAndPdfPaths = [];

    Future<void> traverseDirectory(Directory directory) async {
      await for (FileSystemEntity entity in directory.list()) {
        if (entity is Directory) {
          // await traverseDirectory(entity);
          subdirectoryPaths.add(entity.path);
        } else if (entity is File) {
          String filePath = entity.path;
          if (filePath.toLowerCase().endsWith('.jpg') ||
              filePath.toLowerCase().endsWith('.jpeg') ||
              filePath.toLowerCase().endsWith('.png') ||
              filePath.toLowerCase().endsWith('.pdf') ||
              filePath.toLowerCase().endsWith('.txt')) {
            imageAndPdfPaths.add(filePath);
          }
        }
      }
    }
    Directory directory = Directory(directoryPath);
    if (await directory.exists()) {
      await traverseDirectory(directory);
    } else {
      throw ArgumentError('Directory does not exist: $directoryPath');
    }
    List<String> fileList = [];
    fileList.addAll(subdirectoryPaths);
    fileList.addAll(imageAndPdfPaths);

    return fileList;
  }

  bool _isCreatingPDF = false;
  bool get isCreatingPDF => _isCreatingPDF;

  Future<File?> createPDFFromImages({
    required List<File> images,
    required String directoryPath,
    required BuildContext context,
  }) async {
    try {
      _isCreatingPDF = true;
      notifyListeners();
      final pdf = pw.Document();
      for (var image in images) {
        final resizedImage = await FlutterImageCompress.compressWithFile(
          image.path,
          minHeight: 600,
          minWidth: 600,
          quality: 50,
        );
        var pdfImage = pw.MemoryImage(resizedImage!);
        pdf.addPage(
          pw.Page(
            clip: false,
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(0),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  pdfImage,
                  fit: pw.BoxFit.fill,
                ),
              );
            },
          ),
        );
      }
      final fileName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
      final File file = File('$directoryPath/PDF-$fileName.pdf');
      final bytes = await pdf.save();
      File pdfFile=  await file.writeAsBytes(bytes, flush: true);
      _isCreatingPDF = false;
      notifyListeners();
      return pdfFile;
    } catch (e) {
      _isCreatingPDF = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error creating PDF'),
        ),
      );

      return null;
    }
  }

  Future<String> readTxtFile(String filePath) async {
    try {
      File file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      log(e.toString());
      return "Error reading file";
    }
  }

  void moveFilesToDirectory({
    required String directoryPath,
    required List<String> filePaths,
  }) {
    Directory destinationDirectory = Directory(directoryPath);
    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }
    for (String filePath in filePaths) {
      File file = File(filePath);
      if (file.existsSync()) {
        String fileName = file.path.split('/').last; // Extract file name
        String destinationFilePath = '$directoryPath/$fileName';
        if (!File(destinationFilePath).existsSync()) {
          file.renameSync(destinationFilePath);
          notifyListeners();
          print('Moved $filePath to $destinationFilePath');
        } else {
          print('File $fileName already exists in the destination directory');
        }
      } else {
        print('File $filePath does not exist');
      }
    }
  }



  List<String> _allFiles = [];
  List<String> get allFiles => _allFiles;

  bool _allFileLoading = false;
  bool get allFileLoading => _allFileLoading;

  Future<void> getAllFileList() async {
    _allFileLoading = true;
    notifyListeners();
    Directory appDirectory= await getApplicationDocumentsDirectory();
    String directoryPath = '${appDirectory.path}/Doc Scanner';
    List<String> subdirectoryPaths = [];
    List<String> imageAndPdfPaths = [];
    Future<void> traverseDirectory(Directory directory) async {
      await for (FileSystemEntity entity in directory.list()) {
        if (entity is Directory) {
          await traverseDirectory(entity);
          subdirectoryPaths.add(entity.path);
        } else if (entity is File) {
          String filePath = entity.path;
          if (filePath.toLowerCase().endsWith('.jpg') ||
              filePath.toLowerCase().endsWith('.jpeg') ||
              filePath.toLowerCase().endsWith('.png') ||
              filePath.toLowerCase().endsWith('.pdf') ||
              filePath.toLowerCase().endsWith('.txt')) {
            imageAndPdfPaths.add(filePath);
          }
        }
      }
    }

    Directory directory = Directory(directoryPath);
    if (await directory.exists()) {
      await traverseDirectory(directory);
    } else {
      throw ArgumentError('Directory does not exist: $directoryPath');
    }
    List<String> fileList = [];
    fileList.addAll(subdirectoryPaths);
    fileList.addAll(imageAndPdfPaths);
    _allFiles = fileList;
    _allFileLoading = false;
    notifyListeners();
  }




  List<String> searchPaths(String searchTerm)  {
    List<String> searchResults = [];
    for (String path in _allFiles) {
      List<String> segments = path.split('/');
      String lastSegment = segments.last;
      if (lastSegment.toLowerCase().contains(searchTerm.toLowerCase())) {
        searchResults.add(path);
      }
    }

    return searchResults;
  }




}
