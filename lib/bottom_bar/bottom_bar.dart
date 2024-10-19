import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:doc_scanner/home_page/home_page.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/settings_page/settings_page.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../camera_screen/camera_screen.dart';
import '../camera_screen/model/image_model.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../image_edit/image_preview.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;
  List<Widget> pages = [const HomePage(), const SettingsPage()];

  void updatePage(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  late PermissionStatus storageStatus;
  late PermissionStatus storageStatus1;
  late PermissionStatus storage;

  Future<bool> checkPermission() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if(Platform.isAndroid){

      if(build.version.sdkInt<=32){
        storage= await Permission.storage.status;
      }else{
       storage = await Permission.photos.status;
      }

        if (storage.isDenied) {
          return false;
        } else if (storage.isPermanentlyDenied) {
          return false;
        } else if (storage.isGranted) {
          return true;
        } else {
          return false;
        }

    }else{
      // this for ios implementation
      // for avoiding return type error i used by default false
      return false;
    }

  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    final size =MediaQuery.sizeOf(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:  Text(translation(context).alert),
              content:  Text(translation(context).areYouSureYouWantToExitApp),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text(translation(context).no),
                ),
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child:  Text(translation(context).yes),
                )
              ],
            );
          },
        );
        false;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        floatingActionButton: CircleAvatar(
          radius: size.width >= 600? 40:30,
          backgroundColor: AppColor.primaryColor,
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CameraScreen(),
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
                                const Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColor.primaryColor,
                                ),
                                Text(
                                  translation(context).camera,
                                  style: const TextStyle(
                                      color: AppColor.primaryColor),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await checkPermission().then((value) async {
                              if (value) {
                                final ImagePicker _picker = ImagePicker();
                                final List<XFile?> image = await _picker.pickMultiImage(limit: 5, imageQuality: 50);
                                if (image.isNotEmpty) {
                                  for (int i = 0; i < image.length; i++) {
                                    String documentName =
                                        DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
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
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ImagePreviewScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                              else {
                                Navigator.pop(context);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  isDismissible: false,
                                  builder: (context) {
                                    return Container(
                                      height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
                                              if(Platform.isAndroid ){

                                                if(build.version.sdkInt<=32){
                                                   storageStatus = await Permission.storage.request();
                                                }else{
                                                   storageStatus = await Permission.photos.request();
                                                }
                                                if ( storageStatus.isGranted) {
                                                  final ImagePicker _picker = ImagePicker();
                                                  final List<XFile?> image = await _picker.pickMultiImage(imageQuality: 50);
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
                                                    Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                        const ImagePreviewScreen(),
                                                      ),
                                                          (route) => false,
                                                    );
                                                  }
                                                }


                                                else if (storageStatus.isPermanentlyDenied) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            translation(context)
                                                                .permissionDenied),
                                                        content: Text(translation(
                                                            context)
                                                            .pleaseAllowStoragePermissionToAccessGallery),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                                translation(context)
                                                                    .cancel),
                                                          ),
                                                          TextButton(
                                                            onPressed: () async {
                                                              Navigator.pop(
                                                                  context);
                                                              await openAppSettings();
                                                            },
                                                            child: Text(
                                                                translation(context)
                                                                    .openSettings),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {

                                                  if(build.version.sdkInt<=32){
                                                    storageStatus1 = await Permission.storage.request();
                                                  }else{
                                                    storageStatus1 = await Permission.photos.request();
                                                  }
                                                  if (storageStatus1.isGranted) {
                                                    Navigator.pop(context);
                                                    final ImagePicker _picker = ImagePicker();
                                                    final List<XFile?> image = await _picker.pickMultiImage(limit: 5, imageQuality: 50);
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
                                                      Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                          const ImagePreviewScreen(),
                                                        ),
                                                            (route) => false,
                                                      );
                                                    }

                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(translation(
                                                              context)
                                                              .permissionDenied),
                                                          content: Text(translation(
                                                              context)
                                                              .pleaseAllowStoragePermissionToAccessGallery),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  translation(
                                                                      context)
                                                                      .cancel),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                await openAppSettings();
                                                              },
                                                              child: Text(
                                                                  translation(
                                                                      context)
                                                                      .openSettings),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              }else{
                                                // this for ios implementation
                                              }

                                            },
                                            child: Text(translation(context)
                                                .allowStoragePermission),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            });
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
                                const Icon(
                                  Icons.photo_outlined,
                                  color: AppColor.primaryColor,
                                ),
                                Text(
                                  translation(context).gallery,
                                  style: const TextStyle(
                                      color: AppColor.primaryColor),
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
            backgroundColor: AppColor.primaryColor,
            shape: const CircleBorder(),

            child: SvgPicture.asset(AppAssets.floatingCamera,
              width: size.width >= 600? 40 :30,height: size.width >= 600? 38 :28
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: Colors.grey,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          clipBehavior: Clip.antiAlias,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            child: NavigationBar(
              surfaceTintColor: Colors.grey,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              elevation: 5,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedIndex: _currentIndex,
              destinations: [
                NavigationDestination(
                  icon: SvgPicture.asset(AppAssets.homeOutline, width: size.width >= 600? 30 :20,height: size.width >= 600? 30 :20),
                  selectedIcon: SvgPicture.asset(AppAssets.homeFill,width: size.width >= 600? 30 :20,height: size.width >= 600? 30 :20),
                  label: translation(context).home,
                ),
                NavigationDestination(
                  icon: SvgPicture.asset(AppAssets.settingOutline,width: size.width >= 600? 30 :20,height: size.width >= 600? 30 :20),
                  selectedIcon: SvgPicture.asset(AppAssets.settingFill,width: size.width >= 600? 30 :20,height: size.width >= 600? 30 :20),
                  label: translation(context).settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
