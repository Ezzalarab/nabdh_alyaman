import 'package:flutter/material.dart';

import '../../resources/color_manageer.dart';
import '../../resources/values_manager.dart';

class HomeSearchEntry extends StatelessWidget {
  const HomeSearchEntry({
    super.key,
    required this.onTap,
    this.hint = 'البحث عن متبرع',
  });

  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hint,
      child: Material(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.r14),
          child: Container(
            width: double.infinity,
            height: AppSize.s60,
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r14),
              border: Border.all(color: ColorManager.lightGrey),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppPadding.p16),
                Expanded(
                  child: Text(
                    hint,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ColorManager.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
