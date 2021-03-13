import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

class MyPokemon {
  int id;
  String name;
  int speciesId;
  String genus;
  String entry;
  String artwork;
  int height;
  int weight;
  List<PokemonType> types;
  List<PokemonAbility> abilities;
  int genderRate; //The chance of this Pokémon being female, in eighths; or -1 for genderless
  int evolutionNo;
  //
  var isLiked = false.obs;

  MyPokemon({
    @required this.id,
    @required this.name,
    @required this.speciesId,
    this.genus,
    this.entry,
    this.artwork,
    this.height,
    this.weight,
    this.types,
    this.abilities,
    this.genderRate,
    this.evolutionNo,
  }) {
    if (this.id != null) {
      if (SharedPrefs.instance
          .getFavoritesPokemon()
          .contains(speciesId.toString())) {
        isLiked.value = true;
      } else {
        isLiked.value = false;
      }
    }
  }

  //Can't use for alternative forms
  String getPokedexNo() {
    String pokemonNo = speciesId.toString();
    if (speciesId >= 10 && speciesId < 100) {
      pokemonNo = "0" + pokemonNo;
    } else if (speciesId < 10) {
      pokemonNo = "00" + pokemonNo;
    }
    return "#" + pokemonNo;
  }

  Widget getGenderWidget() {
    double txtSize = 15.0;
    double iconSize = 16.0;
    if (genderRate == -1) {
      return Text(
        "Unknown",
        style: TextStyle(fontSize: txtSize),
      );
    } else if (genderRate == 0) {
      return Icon(
        MdiIcons.genderMale,
        size: iconSize,
      );
    } else if (genderRate == 8) {
      return Icon(
        MdiIcons.genderFemale,
        size: iconSize,
      );
    } else {
      return Row(
        children: <Widget>[
          Icon(
            MdiIcons.genderMale,
            size: iconSize,
          ),
          Icon(
            MdiIcons.genderFemale,
            size: iconSize,
          ),
        ],
      );
    }
  }

  void like() {
    var favorites = SharedPrefs.instance.getFavoritesPokemon();
    if (!favorites.contains(speciesId.toString())) {
      favorites.add(speciesId.toString());
      SharedPrefs.instance
          .setFavoritesPokemon(favorites)
          .then((e) => isLiked.value = true);
    }
  }

  void unlike() {
    var favorites = SharedPrefs.instance.getFavoritesPokemon();
    if (favorites.contains(speciesId.toString())) {
      favorites.remove(speciesId.toString());
      SharedPrefs.instance
          .setFavoritesPokemon(favorites)
          .then((e) => isLiked.value = false);
    }
  }
}
