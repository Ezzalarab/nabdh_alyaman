import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_manageer.dart';
import 'font_manager.dart';
import 'style_manager.dart';
import 'values_manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    // main colors
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.lightPrimary,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: ColorManager.grey1,
    splashColor: ColorManager.lightPrimary,

    //
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: ColorManager.secondary),

    // cardview theme
    cardTheme: const CardTheme(
      color: ColorManager.white,
      shadowColor: ColorManager.grey,
      elevation: AppSize.s4,
    ),

    // app bar theme
    appBarTheme: AppBarTheme(
      foregroundColor: ColorManager.darkGrey,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: ColorManager.white,

          // statusBarBrightness: Brightness.light,
          // systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark),
      // color: ColorManager.white,
      backgroundColor: ColorManager.white,
      centerTitle: true,
      // elevation: AppSize.s4,
      // shadowColor: ColorManager.lightPrimary,
      titleTextStyle: getBoldStyle(
        fontSize: FontSize.s16,
        color: ColorManager.darkGrey,
      ),
    ),

    // button theme
    buttonTheme: const ButtonThemeData(
      shape: StadiumBorder(),
      disabledColor: ColorManager.grey1,
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.lightPrimary,
    ),

    // elevated button theme

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          textStyle: getRegularStyle(
              color: ColorManager.white, fontSize: FontSize.s17),
          backgroundColor: ColorManager.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSize.s12))),
    ),
    // text theme
    textTheme: TextTheme(
      displayLarge: getSemiBoldStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s30,
      ),
      displaySmall: getRegularStyle(
        color: ColorManager.black,
        fontSize: FontSize.s22,
      ),
      headlineLarge: getSemiBoldStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s16,
      ),
      titleLarge: getSemiBoldStyle(
        color: ColorManager.white,
        fontSize: FontSize.s16,
      ),
      titleMedium: getRegularStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s14,
      ),
      headlineMedium: getSemiBoldStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s14,
      ),
      labelMedium: getRegularStyle(
        color: ColorManager.link,
        fontSize: FontSize.s14,
      ),
      bodyLarge: getBoldStyle(
        color: ColorManager.grey,
        fontSize: FontSize.s18,
      ),
      bodyMedium: getRegularStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s16,
      ),
      bodySmall: getRegularStyle(color: ColorManager.grey),
    ),

    // input decorarion theme(text form field)

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(AppPadding.p8),
      // hintstyle
      hintStyle:
          getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s20),
      // label style
      labelStyle:
          getMediumStyle(color: ColorManager.grey, fontSize: FontSize.s14),
      //erore style
      errorStyle: getRegularStyle(color: ColorManager.error),
      // enable border style
      enabledBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
          borderRadius: BorderRadius.all(Radius.circular(AppSize.s10))),
      // focused border style
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorManager.grey,
            width: AppSize.s1_5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
      // error border style
      errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorManager.error,
            width: AppSize.s1_5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
      // focusedError Border style
      focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorManager.primary,
            width: AppSize.s1_5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(AppSize.s8))),
    ),
  );
}
