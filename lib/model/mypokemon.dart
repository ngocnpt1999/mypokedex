import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/pokeapi_http.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

class MyPokemon {
  var id = 0.obs;
  var name = "".obs;
  var speciesId = 0.obs;
  //
  var artwork = "".obs;
  var height = 0.obs;
  var weight = 0.obs;
  var types = <PokemonType>[].obs;
  var abilities = <PokemonAbility>[].obs;
  //Base Stats
  var baseHP = 0.obs;
  var baseAtk = 0.obs;
  var baseDef = 0.obs;
  var baseSpAtk = 0.obs;
  var baseSpDef = 0.obs;
  var baseSpeed = 0.obs;
  //
  var genus = "".obs;
  var entry = "".obs;
  //The chance of this Pokémon being female, in eighths or -1 for genderless
  var genderRate = 100.obs;
  //
  var isFavorite = false.obs;
  int evolutionNo;
  bool allowStats;

  bool get hasStats {
    if (this.artwork.value == "" ||
        this.height.value == 0 ||
        this.weight.value == 0 ||
        this.types.length == 0 ||
        this.abilities.length == 0 ||
        this.baseAtk.value == 0 ||
        this.baseDef.value == 0 ||
        this.baseHP.value == 0 ||
        this.baseSpAtk.value == 0 ||
        this.baseSpDef.value == 0 ||
        this.baseSpeed.value == 0 ||
        this.genus.value == "" ||
        this.entry.value == "" ||
        this.genderRate.value == 100) {
      return false;
    } else {
      return true;
    }
  }

  MyPokemon(
      {@required int id,
      @required String name,
      @required int speciesId,
      this.evolutionNo,
      this.allowStats = false}) {
    this.id.value = id;
    this.name.value = name;
    this.speciesId.value = speciesId;
    if (allowStats) {
      _initStats();
    }
    if (this.id.value > 0) {
      if (SharedPrefs.instance
          .getFavoritesPokemon()
          .contains(jsonEncode(this.toJson()))) {
        this.isFavorite.value = true;
      } else {
        this.isFavorite.value = false;
      }
    }
  }

  void _initStats() async {
    var pkm =
        await MyPokeApi.getPokemon(id: this.id.value, name: this.name.value);
    var pkmSpec = await MyPokeApi.getPokemonSpecies(id: this.speciesId.value);
    var entries = pkmSpec.flavorTextEntries
        .lastWhere((element) => element.language.name == "en");
    var category =
        pkmSpec.genera.firstWhere((element) => element.language.name == "en");
    this.artwork.value = pkm.sprites.other.officialArtwork.frontDefault;
    this.height.value = pkm.height;
    this.weight.value = pkm.weight;
    this.types.addAll(pkm.types);
    this.abilities.addAll(pkm.abilities);
    this.baseHP.value = pkm.stats[0].baseStat;
    this.baseAtk.value = pkm.stats[1].baseStat;
    this.baseDef.value = pkm.stats[2].baseStat;
    this.baseSpAtk.value = pkm.stats[3].baseStat;
    this.baseSpDef.value = pkm.stats[4].baseStat;
    this.baseSpeed.value = pkm.stats[5].baseStat;
    //
    this.genus.value = category.genus;
    this.entry.value = entries.flavorText;
    this.genderRate.value = pkmSpec.genderRate;
  }

  factory MyPokemon.fromJson(Map<String, dynamic> json, bool allowStats) {
    return MyPokemon(
      id: json["id"] as int,
      name: json["name"] as String,
      speciesId: json["speciesId"] as int,
      allowStats: allowStats,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": this.id.value,
        "name": this.name.value,
        "speciesId": this.speciesId.value,
      };

  void like() {
    var favorites = SharedPrefs.instance.getFavoritesPokemon();
    if (!favorites.contains(jsonEncode(this.toJson()))) {
      favorites.add(jsonEncode(this.toJson()));
      SharedPrefs.instance
          .setFavoritesPokemon(favorites)
          .then((value) => isFavorite.value = true);
    }
  }

  void dislike() {
    var favorites = SharedPrefs.instance.getFavoritesPokemon();
    if (favorites.contains(jsonEncode(this.toJson()))) {
      favorites.remove(jsonEncode(this.toJson()));
      SharedPrefs.instance
          .setFavoritesPokemon(favorites)
          .then((value) => isFavorite.value = false);
    }
  }
}
