import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class PokemonArtwork extends StatelessWidget {
  PokemonArtwork({
    @required this.image,
    this.width = 150.0,
    this.height = 150.0,
    this.imageCacheWidth,
    this.imageCacheHeight,
    this.isHideArtwork = false,
  });

  final String image;
  final double width;
  final double height;
  final int imageCacheWidth;
  final int imageCacheHeight;
  final bool isHideArtwork;

  @override
  Widget build(BuildContext context) {
    if (isHideArtwork) {
      return ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [Color(0xffd3d3d3), Color(0xffd3d3d3)],
          ).createShader(bounds);
        },
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: this.image,
          imageCacheWidth: this.imageCacheWidth,
          imageCacheHeight: this.imageCacheHeight,
          width: this.width,
          height: this.height,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: this.image,
        imageCacheWidth: this.imageCacheWidth,
        imageCacheHeight: this.imageCacheHeight,
        width: this.width,
        height: this.height,
        fit: BoxFit.contain,
      );
    }
  }
}
