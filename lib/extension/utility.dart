import 'package:flutter/material.dart';

class Utility {
  static String getPokedexNo(int speciesId) {
    String pokemonNo = speciesId.toString();
    if (speciesId >= 10 && speciesId < 100) {
      pokemonNo = "0" + pokemonNo;
    } else if (speciesId < 10) {
      pokemonNo = "00" + pokemonNo;
    }
    return "#" + pokemonNo;
  }

  static int getPkmIdFromUrl(String url) {
    var re = RegExp(r'(?<=pokemon/)(.*)(?=/)');
    var match = re.firstMatch(url);
    return int.parse(match.group(0));
  }

  static int getPkmSpecIdFromUrl(String url) {
    var re = RegExp(r'(?<=pokemon-species/)(.*)(?=/)');
    var match = re.firstMatch(url);
    return int.parse(match.group(0));
  }

  static int getEvoChainIdFromUrl(String url) {
    var re = RegExp(r'(?<=evolution-chain/)(.*)(?=/)');
    var match = re.firstMatch(url);
    return int.parse(match.group(0));
  }

  // ranges from 0.0 to 1.0
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
