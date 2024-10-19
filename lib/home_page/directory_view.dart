import 'dart:io';
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/utils.dart';
import 'fixed_size_delegate_grid.dart';

class DirectoryDetailsPage extends StatefulWidget {
  final String directoryPath;

  const DirectoryDetailsPage({super.key, required this.directoryPath});

  @override
  State<DirectoryDetailsPage> createState() => _DirectoryDetailsPageState();
}

class _DirectoryDetailsPageState extends State<DirectoryDetailsPage> {
  final _selectedItems = <String>{};
  bool _isLongPressed = false;
  List<String> directoryList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homePageProvider = Provider.of<HomePageProvider>(context);
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        if (_isLongPressed || _selectedItems.isNotEmpty) {
          setState(() {
            _isLongPressed = false;
            _selectedItems.clear();
          });
          return false;
        } else if (!_isLongPressed && _selectedItems.isEmpty) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.directoryPath.split('/').last,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: homePageProvider.isCreatingPDF
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: homePageProvider.getFileList(widget.directoryPath),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.none) {
                      return Text(
                        translation(context).somethingWentWrong,
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasData) {
                        List<String> fileList = snapshot.data!;
                        directoryList = fileList.where((path) {
                          return Directory(path).existsSync();
                        }).toList();

                        return GridView.builder(
                          itemCount: fileList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                            crossAxisCount: size.width >= 600 ? 4 : 3,
                            height: size.width >= 600 ? 110 : 100,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            String filePath = fileList[index];
                            final isSelected =
                                _selectedItems.contains(filePath);
                            if (Directory(filePath).existsSync()) {
                              return GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    _isLongPressed = !_isLongPressed;
                                  });
                                },
                                onTap: () {
                                  if (_isLongPressed) {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedItems.remove(filePath);
                                      } else {
                                        _selectedItems.add(filePath);
                                      }
                                    });
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DirectoryDetailsPage(
                                        directoryPath: filePath,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.folder,
                                            color: AppColor.primaryColor,
                                            size: 40,
                                          ),
                                          Text(
                                            filePath.split('/').last,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    _isLongPressed
                                        ? Positioned(
                                            child: Checkbox(
                                              shape: const CircleBorder(),
                                              activeColor: Colors.black,
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedItems
                                                        .add(filePath);
                                                  } else {
                                                    _selectedItems
                                                        .remove(filePath);
                                                  }
                                                });
                                              },
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              );
                            } else if (filePath
                                    .toLowerCase()
                                    .endsWith('.jpg') ||
                                filePath.toLowerCase().endsWith('.jpeg') ||
                                filePath.toLowerCase().endsWith('.png')) {
                              return GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    _isLongPressed = !_isLongPressed;
                                  });
                                },
                                onTap: () async {
                                  await showGeneralDialog(
                                    context: context,
                                    barrierColor:
                                        Colors.black12.withOpacity(0.6),
                                    barrierDismissible: false,
                                    barrierLabel: 'Dialog',
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                    pageBuilder: (context, __, ___) {
                                      return Image.file(File(filePath));
                                    },
                                  );
                                  if (_isLongPressed) {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedItems.remove(filePath);
                                      } else {
                                        _selectedItems.add(filePath);
                                      }
                                    });
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.file(
                                            File(
                                              filePath,
                                            ),
                                            width: 100,
                                            height: 60,
                                          ),
                                          Text(
                                            filePath.split('/').last,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ),
                                    ),
                                    _isLongPressed
                                        ? Positioned(
                                            child: Checkbox(
                                              shape: const CircleBorder(),
                                              activeColor: Colors.black,
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedItems
                                                        .add(filePath);
                                                  } else {
                                                    _selectedItems
                                                        .remove(filePath);
                                                  }
                                                });
                                              },
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              );
                            } else if (filePath
                                .toLowerCase()
                                .endsWith('.txt')) {
                              return FutureBuilder(
                                  future:
                                      homePageProvider.readTxtFile(filePath),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else if (snapshot.hasData) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            setState(() {
                                              _isLongPressed = !_isLongPressed;
                                            });
                                          },
                                          onTap: () {
                                            showQrAndBarCodeViewDialogue(
                                                context: context,
                                                text: snapshot.data.toString());
                                          },
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  snapshot.data.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              _isLongPressed
                                                  ? Positioned(
                                                      child: Checkbox(
                                                        shape:
                                                            const CircleBorder(),
                                                        activeColor:
                                                            Colors.black,
                                                        value: isSelected,
                                                        onChanged:
                                                            (bool? value) {
                                                          setState(() {
                                                            if (value == true) {
                                                              _selectedItems
                                                                  .add(
                                                                      filePath);
                                                            } else {
                                                              _selectedItems
                                                                  .remove(
                                                                      filePath);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  : const SizedBox.shrink()
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                    return Text(File(filePath)
                                        .readAsString()
                                        .toString());
                                  });
                            } else if (filePath
                                .toLowerCase()
                                .endsWith('.pdf')) {
                              return GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    _isLongPressed = !_isLongPressed;
                                  });
                                },
                                onTap: () async {
                                  await OpenFilex.open(filePath);
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            AppAssets.pdf,
                                            width: 100,
                                            height: 60,
                                          ),
                                          Text(
                                            filePath.split('/').last,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ),
                                    ),
                                    _isLongPressed
                                        ? Positioned(
                                            child: Checkbox(
                                              shape: const CircleBorder(),
                                              activeColor: Colors.black,
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedItems
                                                        .add(filePath);
                                                  } else {
                                                    _selectedItems
                                                        .remove(filePath);
                                                  }
                                                });
                                              },
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              );
                            } else {
                              return Text(
                                translation(context).somethingWentWrong,
                              );
                            }
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          translation(context).noDataFound,
                        );
                      }
                    } else {
                      return Text(
                        translation(context).somethingWentWrong,
                      );
                    }
                  },
                ),
              ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_selectedItems.isEmpty) {
                    } else if (_selectedItems.any((element) =>
                            element.toLowerCase().endsWith('.jpg') ||
                            element.toLowerCase().endsWith('.pdf') ||
                            element.toLowerCase().endsWith('.jpeg') ||
                            element.toLowerCase().endsWith('.txt') ||
                            element.toLowerCase().endsWith('.png')) &&
                        _selectedItems.every((element) =>
                            element.toLowerCase().endsWith('.jpg') ||
                            element.toLowerCase().endsWith('.txt') ||
                            element.toLowerCase().endsWith('.pdf') ||
                            element.toLowerCase().endsWith('.jpeg') ||
                            element.toLowerCase().endsWith('.png'))) {
                      await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: directoryList.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10),
                                    child: ListView(
                                      scrollDirection: Axis.vertical,
                                      children: List.generate(
                                          directoryList.length, (index) {
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.folder,
                                            color: AppColor.primaryColor,
                                            size: 40,
                                          ),
                                          title: Text(directoryList[index]
                                              .split('/')
                                              .last),
                                          onTap: () async {
                                            homePageProvider
                                                .moveFilesToDirectory(
                                              directoryPath:
                                                  directoryList[index],
                                              filePaths:
                                                  _selectedItems.toList(),
                                            );
                                            setState(() {
                                              _selectedItems.clear();
                                              _isLongPressed = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      }),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      translation(context).noDirectoryFound,
                                    ),
                                  ),
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            translation(context).pleaseSelectOneTextOnly,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.move,
                        height: 20,
                        width: 20,
                        fit: BoxFit.fill,
                        color: _selectedItems.isNotEmpty
                            ? AppColor.primaryColor
                            : Colors.grey,
                      ),
                      Text(
                        translation(context).move,
                        style: TextStyle(
                            color: _selectedItems.isNotEmpty
                                ? AppColor.primaryColor
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (_selectedItems.isNotEmpty) {
                      if (_selectedItems.any((element) =>
                              element.toLowerCase().endsWith('.jpg') ||
                              element.toLowerCase().endsWith('.pdf') ||
                              element.toLowerCase().endsWith('.jpeg') ||
                              element.toLowerCase().endsWith('.png')) &&
                          _selectedItems.every((element) =>
                              element.toLowerCase().endsWith('.jpg') ||
                              element.toLowerCase().endsWith('.pdf') ||
                              element.toLowerCase().endsWith('.jpeg') ||
                              element.toLowerCase().endsWith('.png'))) {
                        await Share.shareXFiles(
                          _selectedItems.map((e) => XFile(e)).toList(),
                        );
                      } else if (_selectedItems.any((element) =>
                              element.toLowerCase().endsWith('.txt')) &&
                          _selectedItems.every((element) =>
                              element.toLowerCase().endsWith('.txt')) &&
                          _selectedItems.length == 1) {
                        String text =
                            await File(_selectedItems.first).readAsString();
                        await Share.share(text);
                      } else if (_selectedItems.any((element) =>
                              element.toLowerCase().endsWith('.txt')) &&
                          _selectedItems.every((element) =>
                              element.toLowerCase().endsWith('.txt')) &&
                          _selectedItems.length > 1) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please select one text file only",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              translation(context).pleaseSelectFileOnly,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.share,
                        height: 20,
                        width: 20,
                        fit: BoxFit.fill,
                        color: _selectedItems.isNotEmpty
                            ? AppColor.primaryColor
                            : Colors.grey,
                      ),
                      Text(
                        translation(context).share,
                        style: TextStyle(
                            color: _selectedItems.isNotEmpty
                                ? AppColor.primaryColor
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                widget.directoryPath.endsWith("QR Code") ||
                        widget.directoryPath.endsWith("Bar Code")
                    ? GestureDetector(
                        onTap: () async {
                          if (_selectedItems.isNotEmpty) {
                            if (_selectedItems.length == 1) {
                              String text = await File(_selectedItems.first)
                                  .readAsString();
                              Clipboard.setData(ClipboardData(text: text))
                                  .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      translation(context).textCopied,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    translation(context)
                                        .pleaseSelectOneTextOnly,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copy,
                              size: 20,
                              color: _selectedItems.length == 1
                                  ? AppColor.primaryColor
                                  : Colors.grey,
                            ),
                            Text(
                              translation(context).copy,
                              style: TextStyle(
                                  color: _selectedItems.length == 1
                                      ? AppColor.primaryColor
                                      : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          if (_selectedItems.isNotEmpty) {
                            if (_selectedItems.length >= 2) {
                              if (_selectedItems.any((element) =>
                                      element.toLowerCase().endsWith('.jpg') ||
                                      element.toLowerCase().endsWith('.jpeg') ||
                                      element.toLowerCase().endsWith('.png')) &&
                                  _selectedItems.every((element) =>
                                      element.toLowerCase().endsWith('.jpg') ||
                                      element.toLowerCase().endsWith('.jpeg') ||
                                      element.toLowerCase().endsWith('.png'))) {
                                showNormalAlertDialogue(
                                  context: context,
                                  title: translation(context).alert,
                                  content: translation(context).doYouWantToMakePdf,
                                  onOkText: translation(context).cancel,
                                  onCancelText: translation(context).ok,
                                  onOk: () async {
                                    Navigator.pop(context);
                                    homePageProvider
                                        .createPDFFromImages(
                                      images: _selectedItems
                                          .map((e) => File(e))
                                          .toList(),
                                      directoryPath:
                                      widget.directoryPath,
                                      context: context,
                                    )
                                        .then((value) {
                                      if (value != null &&
                                          widget.directoryPath
                                              .split("/")
                                              .last ==
                                              "ID Card") {
                                        homePageProvider
                                            .addIdCardImage(value);
                                      } else if (value != null &&
                                          widget.directoryPath
                                              .split("/")
                                              .last ==
                                              "Document") {
                                        homePageProvider
                                            .addDocumentImage(
                                            value);
                                      }
                                      setState(() {
                                        _selectedItems.clear();
                                        _isLongPressed = false;
                                      });
                                    });

                                  },
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      translation(context)
                                          .pleaseSelectImagesOnly,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppAssets.merge,
                              height: 20,
                              width: 20,
                              fit: BoxFit.fill,
                              color: _selectedItems.length >= 2
                                  ? AppColor.primaryColor
                                  : Colors.grey,
                            ),
                            Text(
                              translation(context).merge,
                              style: TextStyle(
                                  color: _selectedItems.length >= 2
                                      ? AppColor.primaryColor
                                      : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                GestureDetector(
                  onTap: () async {
                    if (_selectedItems.isNotEmpty) {
                      showNormalAlertDialogue(
                        context: context,
                        title: translation(context).alert,
                        content: translation(context)
                            .areYouSureYouWantToDeleteTheSelectedItems,
                        onOkText: translation(context).ok,
                        onCancelText: translation(context).cancel,
                        onOk: () async {
                          for (int i = 0; i < _selectedItems.length; i++) {
                            var item = _selectedItems.elementAt(i);
                            var fileSystemEntity =
                                FileSystemEntity.typeSync(item);
                            if (fileSystemEntity == FileSystemEntityType.file) {
                              File file = File(item);
                              if (item.split("/").last.startsWith("Bar")) {
                                await homePageProvider
                                    .readTxtFile(item)
                                    .then((value) {
                                  homePageProvider.removeBarCode(value);
                                });
                              } else if (item
                                  .split("/")
                                  .last
                                  .startsWith("QrCode")) {
                                await homePageProvider
                                    .readTxtFile(item)
                                    .then((value) {
                                  homePageProvider.removeQrCode(value);
                                });
                              } else if (item
                                  .split("/")
                                  .last
                                  .startsWith("Doc")) {
                                homePageProvider.removeDocumentImage(item);
                              } else if (item
                                  .split("/")
                                  .last
                                  .startsWith("IDCard")) {
                                homePageProvider.removeIdCarImage(item);
                              } else if (item
                                  .split("/")
                                  .last
                                  .startsWith("PDF")) {
                                if (item.split("/").contains("ID Card")) {
                                  homePageProvider.removeIdCarImage(item);
                                } else if (item
                                    .split("/")
                                    .contains("Document")) {
                                  homePageProvider.removeDocumentImage(item);
                                }
                              }

                              file.deleteSync();
                            } else if (fileSystemEntity ==
                                FileSystemEntityType.directory) {
                              Directory directory = Directory(item);
                              directory.deleteSync(recursive: true);
                            }
                          }
                          _selectedItems.clear();
                          setState(() {
                            _isLongPressed = false;
                          });
                          Navigator.pop(context);
                        },
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        size: 20,
                        color: _selectedItems.isNotEmpty
                            ? AppColor.primaryColor
                            : Colors.grey,
                      ),
                      Text(
                        translation(context).delete,
                        style: TextStyle(
                            color: _selectedItems.isNotEmpty
                                ? AppColor.primaryColor
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
