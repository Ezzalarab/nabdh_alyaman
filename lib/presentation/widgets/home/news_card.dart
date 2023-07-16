import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';
import '../../../domain/entities/news_card_data.dart';
import '../common/loading_widget.dart';

class NewsCard extends StatelessWidget {
  final NewsCardData newsData;
  const NewsCard({Key? key, required this.newsData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Uri url = Uri.parse(newsData.link);
        if (await canLaunchUrl(url)) {
          launchUrl(url);
        } else {
          Fluttertoast.showToast(
            msg: 'لا يمكن فتح الرابط',
            backgroundColor: ColorManager.black.withOpacity(0.5),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                  child: CachedNetworkImage(
                    imageUrl: newsData.image,
                    progressIndicatorBuilder: (context, url, progress) =>
                        const Center(child: LoadingWidget()),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
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
                Positioned(
                  top: 7,
                  left: 7,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'لمعرفة المزيد',
                      style: TextStyle(
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            newsData.title,
                            style: const TextStyle(
                              color: ColorManager.white,
                              fontSize: AppSize.s30,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        newsData.desc,
                        style: const TextStyle(fontSize: 18),
                      )),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined),
                      const SizedBox(width: 10),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(newsData.date),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined),
                      const SizedBox(width: 10),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(newsData.place),
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
}
