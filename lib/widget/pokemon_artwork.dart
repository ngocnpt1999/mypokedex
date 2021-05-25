import 'package:flutter/foundation.dart';
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
    var img = FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      image: this.image,
      imageCacheWidth: this.imageCacheWidth,
      imageCacheHeight: this.imageCacheHeight,
      width: this.width,
      height: this.height,
      fit: BoxFit.contain,
    );
    if (kIsWeb) {
      return img;
    } else {
      if (isHideArtwork) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Color(0xFFD3D3D3), Color(0xFFD3D3D3)],
            ).createShader(bounds);
          },
          child: img,
        );
      } else {
        return img;
      }
    }
  }
}
