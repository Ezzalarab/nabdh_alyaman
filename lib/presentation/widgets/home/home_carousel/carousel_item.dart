import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/content/slide_image_resolver.dart';
import '../../../resources/color_manageer.dart';
import '../../common/loading_widget.dart';

class CarouselItem extends StatelessWidget {
  const CarouselItem({
    required this.item,
    super.key,
  });

  final String item;

  static const _resolver = SlideImageResolver();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.grey2.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: _resolver.isNetworkUrl(item)
            ? CachedNetworkImage(
                imageUrl: item,
                fit: BoxFit.fill,
                width: 900,
                progressIndicatorBuilder: (context, url, progress) =>
                    const Center(child: LoadingWidget()),
              )
            : Image.asset(
                item,
                fit: BoxFit.fill,
                width: 900,
                errorBuilder: (_, __, ___) => Image.asset(
                  SlideImageResolver.knownAssets['blood_heart.png']!,
                  fit: BoxFit.fill,
                  width: 900,
                ),
              ),
      ),
    );
  }
}
