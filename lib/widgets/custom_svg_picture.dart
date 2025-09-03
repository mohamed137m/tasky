import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgPicture extends StatelessWidget {
  const CustomSvgPicture({
    super.key,
    required this.urlImage,
    this.withoutColor = true,
  });
  final String urlImage;
  final bool withoutColor;

  const CustomSvgPicture.withOutColor({super.key, required this.urlImage})
    : withoutColor = false;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      urlImage,
      colorFilter: withoutColor
          ? ColorFilter.mode(
              Theme.of(context).colorScheme.secondary,
              BlendMode.srcIn,
            )
          : null,
    );
  }
}
