import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/pokeapi_http.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/utility.dart';
import 'package:mypokedex/list_favorite_pokemon.dart';
import 'package:mypokedex/list_pokemon.dart';
import 'package:mypokedex/controller/actions.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/pokemon_generation.dart';
import 'package:mypokedex/model/pokemon_type.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

class HomeController extends GetxController {
  HomeController();

  // ignore: unused_field
  var _pokemonDetailController = Get.put(PokemonDetailController());

  var pages = <Widget>[
    ListPokemonPage(),
    ListFavoritePokemonPage(),
  ];

  var selectedTabIndex = 0.obs;

  var selectedGeneration = PokemonGeneration.allGen.obs;

  var selectedType = MyPokemonType.allType.obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void hideAllArtwork() {
    ListPokemonController listPkmController = Get.find();
    ListFavoritePokemonController listFrvPkmController = Get.find();
    listPkmController.hideAllArtwork();
    listFrvPkmController.hideAllArtwork();
  }

  void revealAllArtwork() {
    ListPokemonController listPkmController = Get.find();
    ListFavoritePokemonController listFrvPkmController = Get.find();
    listPkmController.revealAllArtwork();
    listFrvPkmController.revealAllArtwork();
  }

  void changeFilter({String generation, String filter, String typeName}) {
    if (generation != null) {
      selectedGeneration.value = generation;
    }
    if (typeName != null) {
      selectedType.value = typeName;
    }
    ListPokemonController listPkmController = Get.find();
    ListFavoritePokemonController listFrvPkmController = Get.find();
    listPkmController.changeFilter(
        generation: generation, filter: filter, typeName: typeName);
    listFrvPkmController.changeFilter(
        generation: generation, filter: filter, typeName: typeName);
  }
}

class PokemonTileController extends GetxController {
  PokemonTileController({MyPokemon pokemon, bool isHideArtwork = false}) {
    this.pokemon.value = pokemon;
    this.isHideArtwork.value = isHideArtwork;
  }

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;

  var isHideArtwork = false.obs;
}

class ListPokemonController extends GetxController {
  ListPokemonController() {
    scrollController.addListener(() {
      int totalPkm = SharedPrefs.instance
          .getPokedex(generation: _generation, typeName: _typeName)
          .length;
      if (pkmTileControllers.length < totalPkm) {
        double maxPosition = scrollController.position.maxScrollExtent;
        double currentPosition = scrollController.position.pixels;
        if (maxPosition - currentPosition <= Get.height / 3) {
          loadMore();
        }
      }
    });
  }

  var isRun = false;

  var scrollController = ScrollController();

  var pkmTileControllers = <PokemonTileController>[].obs;

  bool _isHideAllArtwork = false;

  String _generation = PokemonGeneration.allGen;

  String _typeName = MyPokemonType.allType;

  String _filter = ListPokemonFilter.ascendingID;

  int _limit = 15;

  bool _isLoading = false;

  void loadMore() {
    if (_isLoading == false) {
      _isLoading = true;
      int totalPkm = SharedPrefs.instance
          .getPokedex(generation: _generation, typeName: _typeName)
          .length;
      var jsonPkms = pkmTileControllers.length + _limit >= totalPkm
          ? SharedPrefs.instance
              .getPokedex(
                  generation: _generation, filter: _filter, typeName: _typeName)
              .sublist(pkmTileControllers.length)
          : SharedPrefs.instance
              .getPokedex(
                  generation: _generation, filter: _filter, typeName: _typeName)
              .sublist(pkmTileControllers.length,
                  pkmTileControllers.length + _limit);
      if (jsonPkms.length == 0) {
        _isLoading = false;
        return;
      }
      var tempControllers = <PokemonTileController>[];
      var futures = <Future<Pokemon>>[];
      jsonPkms.forEach((element) {
        var value = jsonDecode(element) as Map<String, dynamic>;
        futures.add(MyPokeApi.getPokemon(id: value["id"] as int));
      });
      Future.wait(futures).then((pokemons) {
        pokemons.forEach((pkm) {
          if (pkm != null) {
            tempControllers.add(PokemonTileController(
              pokemon: MyPokemon(
                id: pkm.id,
                name: pkm.name,
                speciesId: Utility.getPkmSpecIdFromUrl(pkm.species.url),
                artwork: pkm.sprites.other.officialArtwork.frontDefault,
                types: pkm.types,
              ),
              isHideArtwork: _isHideAllArtwork,
            ));
          }
        });
        ListPokemonFilter.sortPkmTile(tempControllers, _filter);
        pkmTileControllers.addAll(tempControllers);
        _isLoading = false;
      });
    }
  }

  void hideAllArtwork() {
    if (!_isHideAllArtwork) {
      _isHideAllArtwork = true;
      pkmTileControllers.forEach((element) {
        element.isHideArtwork.value = _isHideAllArtwork;
      });
    }
  }

  void revealAllArtwork() {
    if (_isHideAllArtwork) {
      _isHideAllArtwork = false;
      pkmTileControllers.forEach((element) {
        element.isHideArtwork.value = _isHideAllArtwork;
      });
    }
  }

  void refresh() {
    pkmTileControllers.clear();
    loadMore();
  }

  void changeFilter({String generation, String filter, String typeName}) {
    if (generation != null) {
      _generation = generation;
    }
    if (filter != null) {
      _filter = filter;
    }
    if (typeName != null) {
      _typeName = typeName;
    }
    refresh();
  }

  bool endOfData() {
    int totalPkm = SharedPrefs.instance
        .getPokedex(generation: _generation, typeName: _typeName)
        .length;
    if (pkmTileControllers.length == totalPkm) {
      return true;
    }
    return false;
  }
}

class ListFavoritePokemonController extends GetxController {
  ListFavoritePokemonController() {
    scrollController.addListener(() {
      if (pkmTileControllers.length <
          SharedPrefs.instance
              .getFavoritesPokemon(generation: _generation, typeName: _typeName)
              .length) {
        double maxPosition = scrollController.position.maxScrollExtent;
        double currentPosition = scrollController.position.pixels;
        if (maxPosition - currentPosition <= Get.height / 3) {
          loadMore();
        }
      }
    });
  }

  var isRun = false;

  var scrollController = ScrollController();

  var pkmTileControllers = <PokemonTileController>[].obs;

  var hasFavorites = false.obs;

  bool _isHideAllArtwork = false;

  String _generation = PokemonGeneration.allGen;

  String _typeName = MyPokemonType.allType;

  String _filter = ListPokemonFilter.ascendingID;

  int _limit = 15;

  bool _isLoading = false;

  void loadMore() {
    if (_isLoading == false) {
      _isLoading = true;
      int totalPkm = SharedPrefs.instance
          .getFavoritesPokemon(generation: _generation, typeName: _typeName)
          .length;
      if (totalPkm == 0) {
        hasFavorites.value = false;
        _isLoading = false;
        return;
      }
      hasFavorites.value = true;
      var jsonPkms = pkmTileControllers.length + _limit >= totalPkm
          ? SharedPrefs.instance
              .getFavoritesPokemon(
                  generation: _generation, filter: _filter, typeName: _typeName)
              .sublist(pkmTileControllers.length)
          : SharedPrefs.instance
              .getFavoritesPokemon(
                  generation: _generation, filter: _filter, typeName: _typeName)
              .sublist(pkmTileControllers.length,
                  pkmTileControllers.length + _limit);
      if (jsonPkms.length == 0) {
        _isLoading = false;
        return;
      }
      var tempControllers = <PokemonTileController>[];
      var futures = <Future<Pokemon>>[];
      jsonPkms.forEach((element) {
        var value = jsonDecode(element) as Map<String, dynamic>;
        futures.add(MyPokeApi.getPokemon(id: value["id"] as int));
      });
      Future.wait(futures).then((pokemons) {
        pokemons.forEach((pkm) {
          if (pkm != null) {
            tempControllers.add(PokemonTileController(
              pokemon: MyPokemon(
                id: pkm.id,
                name: pkm.name,
                speciesId: Utility.getPkmSpecIdFromUrl(pkm.species.url),
                artwork: pkm.sprites.other.officialArtwork.frontDefault,
                types: pkm.types,
              ),
              isHideArtwork: _isHideAllArtwork,
            ));
          }
        });
        ListPokemonFilter.sortPkmTile(tempControllers, _filter);
        pkmTileControllers.addAll(tempControllers);
        _isLoading = false;
      });
    }
  }

  void hideAllArtwork() {
    if (!_isHideAllArtwork) {
      _isHideAllArtwork = true;
      pkmTileControllers.forEach((element) {
        element.isHideArtwork.value = _isHideAllArtwork;
      });
    }
  }

  void revealAllArtwork() {
    if (_isHideAllArtwork) {
      _isHideAllArtwork = false;
      pkmTileControllers.forEach((element) {
        element.isHideArtwork.value = _isHideAllArtwork;
      });
    }
  }

  void refresh() {
    pkmTileControllers.clear();
    loadMore();
  }

  void changeFilter({String generation, String filter, String typeName}) {
    if (generation != null) {
      _generation = generation;
    }
    if (filter != null) {
      _filter = filter;
    }
    if (typeName != null) {
      _typeName = typeName;
    }
    refresh();
  }

  bool endOfData() {
    if (pkmTileControllers.length ==
        SharedPrefs.instance
            .getFavoritesPokemon(generation: _generation, typeName: _typeName)
            .length) {
      return true;
    }
    return false;
  }
}

class PokemonDetailController extends GetxController {
  PokemonDetailController();

  var isHideArtwork = false.obs;

  var activeBaseStat = true.obs;
  var activeMinStat = false.obs;
  var activeMaxStat = false.obs;

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;

  var weakness = <String, double>{}.obs;

  var evolutions = <MyPokemon>[].obs;

  var alternativeForms = <MyPokemon>[].obs;

  void init({int id, String name}) async {
    pokemon.value = MyPokemon(id: 0, name: "", speciesId: 0);
    weakness.clear();
    evolutions.clear();
    alternativeForms.clear();
    activeBaseStat.value = true;
    activeMinStat.value = false;
    activeMaxStat.value = false;
    //
    var pkm = await MyPokeApi.getPokemon(id: id, name: name);
    var pkmSpec = await MyPokeApi.getPokemonSpecies(name: pkm.species.name);
    var entries = pkmSpec.flavorTextEntries
        .lastWhere((element) => element.language.name == "en");
    var category =
        pkmSpec.genera.firstWhere((element) => element.language.name == "en");
    pokemon.value = MyPokemon(
      id: pkm.id,
      name: pkm.name,
      speciesId: pkmSpec.id,
      genus: category.genus,
      artwork: pkm.sprites.other.officialArtwork.frontDefault,
      entry: entries.flavorText,
      height: pkm.height,
      weight: pkm.weight,
      types: pkm.types,
      abilities: pkm.abilities,
      genderRate: pkmSpec.genderRate,
      baseHP: pkm.stats[0].baseStat,
      baseAtk: pkm.stats[1].baseStat,
      baseDef: pkm.stats[2].baseStat,
      baseSpAtk: pkm.stats[3].baseStat,
      baseSpDef: pkm.stats[4].baseStat,
      baseSpeed: pkm.stats[5].baseStat,
    );
    weakness.addAll(await _getTypeWeakness(pkm.types));
    evolutions.addAll(await _getEvolutions(pkmSpec));
    alternativeForms.addAll(await _getAlternativeForms(pkmSpec));
  }

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
    var addEvolution = (Pokemon pkm, int no) {
      tempEvolutions.add(MyPokemon(
        id: pkm.id,
        name: pkm.name,
        speciesId: pkm.id,
        artwork: pkm.sprites.other.officialArtwork.frontDefault,
        types: pkm.types,
        evolutionNo: no,
      ));
      tempEvolutions.sort((a, b) => a.id.compareTo(b.id));
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
      if (art.isNotEmpty) {
        forms.add(MyPokemon(
          id: pkm.id,
          name: pkm.name,
          speciesId: pkmSpec.id,
          artwork: art,
          types: pkm.types,
        ));
        forms.sort((a, b) => a.id.compareTo(b.id));
      }
    }
    return forms;
  }
}
