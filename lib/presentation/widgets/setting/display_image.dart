import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../resources/assets_manager.dart';
import '../../resources/style.dart';

class DisplayImage extends StatelessWidget {
  const DisplayImage({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onPressed,
  });

  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 75,
            backgroundColor: ePrimColor,
            child: CircleAvatar(
              radius: 70,
              backgroundImage: _imageProvider(),
              child: _imageProvider() == null
                  ? const Icon(Icons.person, size: 64, color: Colors.white70)
                  : null,
            ),
          ),
          Positioned(
            right: 4,
            top: 10,
            child: GestureDetector(
              onTap: onPressed,
              child: ClipOval(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Icon(Icons.edit, color: ePrimColor, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _imageProvider() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImageProvider(url);
    }
    return const AssetImage(ImageAssets.profileImage);
  }
}
