import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/content/slide_image_resolver.dart';
import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import '../../../domain/entities/event_card_data.dart';
import '../common/loading_widget.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.eventData});

  final EventCardData eventData;

  static const _resolver = SlideImageResolver();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final link = eventData.link.trim();
        if (link.isEmpty) return;
        final url = Uri.parse(link);
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 7,
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: _buildImage(),
                ),
                Positioned(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0),
                          Colors.black.withOpacity(.8),
                        ],
                        stops: const [0.3, 1],
                      ),
                    ),
                    height: 230,
                    alignment: Alignment.bottomRight,
                  ),
                ),
                const Positioned(
                  top: 7,
                  left: 7,
                  child: Text(
                    'لمعرفة المزيد',
                    style: TextStyle(color: ColorManager.white),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        eventData.title,
                        style: const TextStyle(
                          color: ColorManager.white,
                          fontSize: AppSize.s30,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      eventData.desc,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          eventData.date,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          eventData.place,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final image = eventData.image;
    if (image.isEmpty) {
      return const SizedBox(height: 200, width: double.infinity);
    }
    if (_resolver.isNetworkUrl(image)) {
      return CachedNetworkImage(
        imageUrl: image,
        progressIndicatorBuilder: (context, url, progress) =>
            const Center(child: LoadingWidget()),
        height: 200,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      image,
      height: 200,
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox(height: 200),
    );
  }
}
