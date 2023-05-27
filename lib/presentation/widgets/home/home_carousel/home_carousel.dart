import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nabdh_alyaman/presentation/cubit/global_cubit/global_cubit.dart';

import '../../../resources/assets_manager.dart';
import 'carousel_item.dart';

class HomeCarousel extends StatefulWidget {
  const HomeCarousel({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  final CarouselController _controller = CarouselController();

  List<String> imgList = [
    ImageAssets.bloodHeart,
    ImageAssets.bloodDonationBagHeart,
    ImageAssets.handsDonate,
  ];

  int _current = 0;

  List<Widget> getImageSliders(List<String> imgList) {
    return imgList
        .map((item) => CarouselItem(
              item: item,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            BlocBuilder<GlobalCubit, GlobalState>(
              builder: (context, state) {
                if (state is GlobalStateSuccess) {
                  imgList = state.appData.homeSlides;
                }
                return CarouselSlider(
                  items: getImageSliders(imgList),
                  options: CarouselOptions(
                    viewportFraction: 0.9,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 10),
                    enlargeCenterPage: true,
                    height: 200,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  carouselController: _controller,
                );
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: _current == entry.key ? 30 : 12.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(_current == entry.key ? 0.8 : 0.3)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
