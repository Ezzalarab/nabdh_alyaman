import 'package:flutter/material.dart';

import '../../resources/style.dart';

// ignore: must_be_immutable
class DisplayImage extends StatefulWidget {
  dynamic imagePath;
  final VoidCallback onPressed;

  // Constructor
  DisplayImage({
    Key? key,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(children: [
      buildImage(ePrimColor),
      Positioned(
        right: 4,
        top: 10,
        child: buildEditIcon(ePrimColor),
      )
    ]));
  }

  // Builds Profile Image
  Widget buildImage(Color color) {
    return CircleAvatar(
      radius: 75,
      backgroundColor: color,
      child: (widget.imagePath is String)
          ? const CircleAvatar(
              backgroundImage: AssetImage("assets/images/boy.png"),
              radius: 70,
            )
          : CircleAvatar(
              backgroundImage: FileImage(widget.imagePath),
              radius: 70,
            ),
    );
  }

  // Builds Edit Icon on Profile Picture
  Widget buildEditIcon(Color color) => buildCircle(
      all: 8,
      child: Icon(
        Icons.edit,
        color: color,
        size: 20,
      ));

  // Builds/Makes Circle for Edit Icon on Profile Picture
  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
          child: Container(
        padding: EdgeInsets.all(all),
        color: Colors.white,
        child: child,
      ));
}
