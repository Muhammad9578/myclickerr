import 'package:flutter/material.dart';
import 'package:photo_lab/src/helpers/helpers.dart';

class CircleProfile extends StatelessWidget {
  final Image image;
  final double radius;

  const CircleProfile({required this.radius, required this.image, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey,
      child: ClipOval(
        child: AspectRatio(aspectRatio: 1, child: image),
      ),
    );*/

    return CircleAvatar(
      radius: radius,
      child: ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: const AssetImage(ImageAsset.PlaceholderImg),
            image: image.image,
            imageErrorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Error'));
            },
          ),
        ),
      ),
    );
  }
}
