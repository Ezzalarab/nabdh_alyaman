import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../../presentation/resources/font_manager.dart';
import '../../../presentation/widgets/common/dialog_lottie.dart';
import '../../../domain/entities/page_view_model_data.dart';

PageViewModel myPageViewModel(PageViewModelData pageViewModelData) {
  return PageViewModel(
    // titleWidget: Text("data"),
    // body:
    //     'Body of 1st Page With that out of the way let’s create our introduction screen. First, let’s create ourselves an',
    bodyWidget: SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: MyLottie(lottie: pageViewModelData.lottei),
            // Image.asset(
            //   pageViewModelData.image ?? 'assets/images/4.jpg',
            //   scale: 1.3,
            // ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            pageViewModelData.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              pageViewModelData.description,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontFamily: FontConstants.fontFamily, fontSize: 22),
            ),
          )
        ],
      ),
    ),
    // titleWidget: Text('Title of 1st Page'),
    title: '',
    // image: Center(
    //   child: Image.asset('assets/images/4.jpg'),
    // ),
    decoration: const PageDecoration(
        // contentMargin: EdgeInsets.all(10),
        // imagePadding: EdgeInsets.only(top: 40),
        // titlePadding: EdgeInsets.symmetric(vertical: 20),
        ),
  );
}
