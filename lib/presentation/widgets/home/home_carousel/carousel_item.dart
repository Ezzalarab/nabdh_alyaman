import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/global_cubit/global_cubit.dart';
import '../../../resources/color_manageer.dart';
import '../../common/loading_widget.dart';

class CarouselItem extends StatelessWidget {
  const CarouselItem({
    required this.item,
    super.key,
  });
  final String item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      // padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
              color: ColorManager.grey2.withOpacity(0.3),
              blurRadius: 10.0,
              offset: const Offset(2, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Stack(
          children: <Widget>[
            BlocBuilder<GlobalCubit, GlobalState>(
              builder: (context, state) {
                if (state is GlobalStateSuccess) {
                  return CachedNetworkImage(
                    imageUrl: item,
                    fit: BoxFit.fill,
                    width: 900.0,
                    progressIndicatorBuilder: (context, url, progress) =>
                        const Center(
                      child: LoadingWidget(),
                    ),
                  );
                } else {
                  return Image.asset(item, fit: BoxFit.fill, width: 900.0);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
