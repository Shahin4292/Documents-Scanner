import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageEditButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final String iconPath;

  const ImageEditButton(
      {super.key,
      required this.title,
      required this.onTap,
      required this.iconPath});

  @override
  State<ImageEditButton> createState() => _ImageEditButtonState();
}

class _ImageEditButtonState extends State<ImageEditButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                  widget.iconPath,
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                color: Colors.black,
                ),
              const SizedBox(height: 5),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
