import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    if (this.id != 0) {
      if (SharedPrefs.instance
          .getFavoritesPokemon()
          .contains(jsonEncode(this.toJson()))) {
        isLiked.value = true;
      } else {
        isLiked.value = false;
      }
    }
  }

  MyPokemon.fromJson(Map<String, dynamic> json)
      : id = json["id"] as int,
        name = json["name"] as String,
        speciesId = json["speciesId"] as int;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "speciesId": speciesId,
      };

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

  void like() {
    var favorites = SharedPrefs.instance.getFavoritesPokemon();
    if (!favorites.contains(jsonEncode(this.toJson()))) {
      favorites.add(jsonEncode(this.toJson()));
      SharedPrefs.instance
          .setFavoritesPokemon(favorites)
          .then((value) => isLiked.value = true);
    }
  }

  void unlike() {
    var favorites = SharedPrefs.instance.getFavoritesPokemon();
    if (favorites.contains(jsonEncode(this.toJson()))) {
      favorites.remove(jsonEncode(this.toJson()));
      SharedPrefs.instance
          .setFavoritesPokemon(favorites)
          .then((value) => isLiked.value = false);
    }
  }
}
