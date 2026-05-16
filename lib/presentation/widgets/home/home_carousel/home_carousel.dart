import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/app_config/app_config_bloc.dart';
import '../../../resources/assets_manager.dart';
import 'carousel_item.dart';

class HomeCarousel extends StatefulWidget {
  const HomeCarousel({super.key});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();

  List<String> imgList = [
    ImageAssets.bloodHeart,
    ImageAssets.bloodDonationBagHeart,
    ImageAssets.handsDonate,
  ];

  int _current = 0;

  List<Widget> getImageSliders(List<String> list) =>
      list.map((item) => CarouselItem(item: item)).toList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppConfigBloc, AppConfigState>(
      builder: (context, state) {
        final slides = switch (state) {
          AppConfigLoaded(:final data) => data.homeSlides,
          AppUpdateRequired(:final data) => data.homeSlides,
          AppConfigFailure(:final data) => data.homeSlides,
          _ => context.read<AppConfigBloc>().data.homeSlides,
        };
        if (slides.isNotEmpty) imgList = slides;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CarouselSlider(
              items: getImageSliders(imgList),
              options: CarouselOptions(
                viewportFraction: 0.9,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 10),
                enlargeCenterPage: true,
                height: 200,
                onPageChanged: (index, reason) {
                  setState(() => _current = index);
                },
              ),
              carouselController: _controller,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: _current == entry.key ? 30 : 12,
                    height: 8,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(_current == entry.key ? 0.8 : 0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
