import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/pokeapi_http.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/extension/utility.dart';
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
  var genderRate = 0.obs;
  var weakness = <String, double>{}.obs;
  var evolutions = <MyPokemon>[].obs;
  var alternativeForms = <MyPokemon>[].obs;
  //
  var isFavorite = false.obs;
  int evolutionNo;
  bool isStatsProcessing = false;
  bool isExpansionProcessing = false;

  bool get hasSimpleData {
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
        this.baseSpeed.value == 0) {
      return false;
    } else {
      return true;
    }
  }

  bool get hasExpansionData {
    if (this.genus.value == "" ||
        this.entry.value == "" ||
        this.genderRate.value == 0 ||
        weakness.length == 0 ||
        evolutions.length == 0 ||
        alternativeForms.length == 0) {
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
      bool allowStats = false,
      bool allowExpansion = false}) {
    this.id.value = id;
    this.name.value = name;
    this.speciesId.value = speciesId;
    if (allowStats) {
      if (!isStatsProcessing) {
        isStatsProcessing = true;
        _initStats().then((value) => isStatsProcessing = false);
      }
    }
    if (allowExpansion) {
      if (!isExpansionProcessing) {
        isExpansionProcessing = true;
        _initExpansion().then((value) => isExpansionProcessing = false);
      }
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

  void initAll() {
    if (!hasSimpleData) {
      if (!isStatsProcessing) {
        isStatsProcessing = true;
        _initStats().then((value) => isStatsProcessing = false);
      }
    }
    if (!hasExpansionData) {
      if (!isExpansionProcessing) {
        isExpansionProcessing = true;
        _initExpansion().then((value) => isExpansionProcessing = false);
      }
    }
  }

  Future<void> _initStats() async {
    var pkm =
        await MyPokeApi.getPokemon(id: this.id.value, name: this.name.value);
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
  }

  Future<void> _initExpansion() async {
    var pkm =
        await MyPokeApi.getPokemon(id: this.id.value, name: this.name.value);
    var pkmSpec = await MyPokeApi.getPokemonSpecies(id: this.speciesId.value);
    var entries = pkmSpec.flavorTextEntries
        .lastWhere((element) => element.language.name == "en");
    var category =
        pkmSpec.genera.firstWhere((element) => element.language.name == "en");
    this.genus.value = category.genus;
    this.entry.value = entries.flavorText;
    this.genderRate.value = pkmSpec.genderRate;
    this.weakness.addAll(await _getTypeWeakness(pkm.types));
    this.evolutions.addAll(await _getEvolutions(pkmSpec));
    this.alternativeForms.addAll(await _getAlternativeForms(pkmSpec));
  }

  factory MyPokemon.fromJson(Map<String, dynamic> json) {
    return MyPokemon(
        id: json["id"] as int,
        name: json["name"] as String,
        speciesId: json["speciesId"] as int);
  }

  Map<String, dynamic> toJson() => {
        "id": this.id.value,
        "name": this.name.value,
        "speciesId": this.speciesId.value,
      };

  Future<Map<String, double>> _getTypeWeakness(List<PokemonType> types) async {
    var tempWeakness = <String, double>{};
    for (int i = 0; i < types.length; i++) {
      var type = await MyPokeApi.getPokemonType(name: types[i].type.name);
      type.damageRelations.doubleDamageFrom.forEach((element) {
        if (tempWeakness.containsKey(element.name)) {
          tempWeakness[element.name] = tempWeakness[element.name] * 2.0;
        } else {
          tempWeakness[element.name] = 2.0;
        }
      });
      type.damageRelations.halfDamageFrom.forEach((element) {
        if (tempWeakness.containsKey(element.name)) {
          tempWeakness[element.name] = tempWeakness[element.name] * 0.5;
        } else {
          tempWeakness[element.name] = 0.5;
        }
      });
      type.damageRelations.noDamageFrom.forEach((element) {
        if (tempWeakness.containsKey(element.name)) {
          tempWeakness[element.name] = tempWeakness[element.name] * 0;
        } else {
          tempWeakness[element.name] = 0;
        }
      });
    }
    var entries = tempWeakness.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    tempWeakness = Map.fromEntries(entries);
    return tempWeakness;
  }

  Future<List<MyPokemon>> _getEvolutions(PokemonSpecies pkmSpec) async {
    var evoChain = await MyPokeApi.getEvolutionChain(
        id: Utility.getEvoChainIdFromUrl(pkmSpec.evolutionChain.url));
    var tempEvolutions = <MyPokemon>[];
    var addEvolution = (Pokemon pkm, int index) {
      tempEvolutions.add(MyPokemon(
        id: pkm.id,
        name: pkm.name,
        speciesId: pkm.id,
        evolutionNo: index,
        allowStats: true,
      ));
      tempEvolutions.sort((a, b) => a.id.value.compareTo(b.id.value));
    };
    var evo = evoChain.chain;
    int evoNo = 1;
    do {
      int numOfEvo = evo.evolvesTo.length;
      int tempEvoNo = evoNo;
      int id = Utility.getPkmSpecIdFromUrl(evo.species.url);
      var pkm = await MyPokeApi.getPokemon(id: id);
      addEvolution(pkm, tempEvoNo);
      evoNo++;
      if (numOfEvo > 1) {
        for (int i = 1; i < numOfEvo; i++) {
          int _tempEvoNo = evoNo;
          int _id = Utility.getPkmSpecIdFromUrl(evo.evolvesTo[i].species.url);
          var _pkm = await MyPokeApi.getPokemon(id: _id);
          addEvolution(_pkm, _tempEvoNo);
        }
      }
      evo = numOfEvo > 0 ? evo.evolvesTo[0] : null;
    } while (evo != null);
    return tempEvolutions;
  }

  Future<List<MyPokemon>> _getAlternativeForms(PokemonSpecies pkmSpec) async {
    var forms = <MyPokemon>[];
    for (int i = 0; i < pkmSpec.varieties.length; i++) {
      var pkm = await MyPokeApi.getPokemon(
          id: Utility.getPkmIdFromUrl(pkmSpec.varieties[i].pokemon.url));
      String art = pkm.sprites.other.officialArtwork.frontDefault;
      if (art != null && art.isNotEmpty) {
        forms.add(MyPokemon(
          id: pkm.id,
          name: pkm.name,
          speciesId: pkmSpec.id,
          allowStats: true,
        ));
        forms.sort((a, b) => a.id.value.compareTo(b.id.value));
      }
    }
    return forms;
  }

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
