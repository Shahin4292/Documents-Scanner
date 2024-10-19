import 'dart:io';

import 'package:doc_scanner/main.dart';
import 'package:doc_scanner/settings_page/web_view_page.dart';
import 'package:doc_scanner/settings_page/widgets/switch_item.dart';
import 'package:doc_scanner/utils/app_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/local_storage.dart';
import '../localaization/language.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import 'dart:developer' as developer;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool vibration = false;
  bool beep = false;
  Language _selectedLanguage = Language(1, 'English', 'en');

  @override
  void initState() {
    vibration = LocalStorage().getBool(AppConstant.VIBRATION_KEY);
    beep = LocalStorage().getBool(AppConstant.BEEP_KEY);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Locale _locale = await getLocale();
      _selectedLanguage = Language.languageList().firstWhere(
          (element) => element.languageCode == _locale.languageCode);
      setState(() {});
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translation(context).settings,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 12.0),
        child: Column(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AppAssets.languageIcon),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      translation(context).language,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<Language>(
                      underline: const SizedBox.shrink(),
                      alignment: AlignmentDirectional.centerEnd,
                      isExpanded: true,
                      isDense: true,
                      icon: const SizedBox.shrink(),
                      value: _selectedLanguage,
                      onChanged: (Language? newValue) async {
                        setState(() {
                          _selectedLanguage = newValue!;
                        });
                        Locale _locale =
                            await setLocale(newValue!.languageCode);
                        MyApp.setLocale(context, _locale);
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return Language.languageList()
                            .map<Widget>((Language language) {
                          return Text(
                            _selectedLanguage.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          );
                        }).toList();
                      },
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                              (Language language) {
                        return DropdownMenuItem<Language>(
                          value: language,
                          child: Text(language.name),
                        );
                      }).toList(),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_outlined)
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.015,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SwitchItem(
                      iconPath: AppAssets.vibration,
                      title: translation(context).vibration,
                      onChanged: (value) {
                        setState(() {
                          vibration = value;
                        });
                        LocalStorage()
                            .setBool(AppConstant.VIBRATION_KEY, value);
                      },
                      value: vibration),
                  SwitchItem(
                      iconPath: AppAssets.beep,
                      title: translation(context).beep,
                      onChanged: (value) {
                        setState(() {
                          beep = value;
                        });
                        LocalStorage().setBool(AppConstant.BEEP_KEY, value);
                      },
                      value: beep),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.015,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        Share.shareUri(
                          Uri.parse('https://play.google.com/store/apps/details?id=com.qr_code_reader_qr_scanner'),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppAssets.shareWithFriend),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.015,
                            ),
                            Text(
                              translation(context).shareWithFriend,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () async {
                        try {
                          if (Platform.isAndroid || Platform.isIOS) {
                            final appId = Platform.isAndroid ? 'com.qr_code_reader_qr_scanner' : '';
                            final url = Uri.parse(
                              Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId",
                            );
                            await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (e) {
                          developer.log(e.toString());
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppAssets.rateUs),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.015,
                            ),
                            Text(
                              translation(context).rateUs,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.015,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>  WebViewPage(
                                appBarTitleName: translation(context).privacyPolicy,
                                url: "https://sites.google.com/view/docu-scanner/home",
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppAssets.privacyPolicy),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.015,
                            ),
                            Text(
                              translation(context).privacyPolicy,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>  WebViewPage(
                                appBarTitleName:  translation(context).termsAndConditions,
                                url: "https://sites.google.com/view/docum-scanner/home",
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppAssets.termsCondition),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.015,
                            ),
                            Text(
                              translation(context).termsAndConditions,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
