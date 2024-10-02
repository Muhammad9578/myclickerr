import 'package:flutter/material.dart';
import 'package:photo_lab/src/modules/chat/constants/app_constants.dart';
import 'package:photo_lab/src/modules/chat/constants/color_constants.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;

  const FullPhotoPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.fullPhotoTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: InteractiveViewer(
        child: Image.network(url),
        // imageProvider: NetworkImage(url),
      ),
    );
  }
}
