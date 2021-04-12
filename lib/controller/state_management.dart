import 'dart:async';
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

  void loadMore() async {
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
      var addPokemon = (Pokemon pkm) {
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
        if (tempControllers.length == jsonPkms.length) {
          ListPokemonFilter.sortPkmTile(tempControllers, _filter);
          pkmTileControllers.addAll(tempControllers);
          _isLoading = false;
        }
      };
      jsonPkms.forEach((element) {
        var value = jsonDecode(element) as Map<String, dynamic>;
        MyPokeApi.getPokemon(id: value["id"] as int).then((pkm) {
          addPokemon(pkm);
        });
      });
      //Loading... countdown
      int start = 10;
      Duration oneSec = Duration(seconds: 1);
      Timer countdown;
      countdown = Timer.periodic(oneSec, (timer) {
        if (tempControllers.length == jsonPkms.length) {
          timer.cancel();
          countdown.cancel();
        } else if (start == 0) {
          _isLoading = false;
          timer.cancel();
          countdown.cancel();
        } else {
          start--;
        }
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

  void loadMore() async {
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
      var addFavoritePkm = (Pokemon pkm) {
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
        if (tempControllers.length == jsonPkms.length) {
          ListPokemonFilter.sortPkmTile(tempControllers, _filter);
          pkmTileControllers.addAll(tempControllers);
          _isLoading = false;
        }
      };
      jsonPkms.forEach((element) {
        var value = jsonDecode(element) as Map<String, dynamic>;
        MyPokeApi.getPokemon(id: value["id"] as int).then((pkm) {
          addFavoritePkm(pkm);
        });
      });
      //Loading... countdown
      int start = 10;
      Duration oneSec = Duration(seconds: 1);
      Timer countdown;
      countdown = Timer.periodic(oneSec, (timer) {
        if (tempControllers.length == jsonPkms.length) {
          timer.cancel();
          countdown.cancel();
        } else if (start == 0) {
          _isLoading = false;
          timer.cancel();
          countdown.cancel();
        } else {
          start--;
        }
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

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;

  var weakness = <String, double>{}.obs;

  var evolutions = <MyPokemon>[].obs;

  var alternativeForms = <MyPokemon>[].obs;

  void init({int id, String name}) {
    pokemon.value = MyPokemon(id: 0, name: "", speciesId: 0);
    weakness.clear();
    evolutions.clear();
    alternativeForms.clear();
    //
    var initPokemon = (Pokemon pkm) {
      MyPokeApi.getPokemonSpecies(name: pkm.species.name).then((pkmSpec) {
        var entries = pkmSpec.flavorTextEntries
            .lastWhere((element) => element.language.name == "en");
        var category = pkmSpec.genera
            .firstWhere((element) => element.language.name == "en");
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
        );
        _getTypeWeakness(pkm.types);
        _getEvolutionData(pkmSpec);
        _getAlternativeForms(pkmSpec);
      });
    };
    MyPokeApi.getPokemon(id: id, name: name).then((pkm) {
      initPokemon(pkm);
    });
  }

  void _getTypeWeakness(List<PokemonType> types) {
    types.forEach((type) {
      MyPokeApi.getPokemonType(name: type.type.name).then((value) {
        value.damageRelations.doubleDamageFrom.forEach((element) {
          if (weakness.containsKey(element.name)) {
            weakness[element.name] = weakness[element.name] * 2.0;
          } else {
            weakness[element.name] = 2.0;
          }
        });
        value.damageRelations.halfDamageFrom.forEach((element) {
          if (weakness.containsKey(element.name)) {
            weakness[element.name] = weakness[element.name] * 0.5;
          } else {
            weakness[element.name] = 0.5;
          }
        });
        value.damageRelations.noDamageFrom.forEach((element) {
          if (weakness.containsKey(element.name)) {
            weakness[element.name] = weakness[element.name] * 0;
          } else {
            weakness[element.name] = 0;
          }
        });
      });
    });
  }

  void _getEvolutionData(PokemonSpecies pkmSpec) {
    var handleEvo = (EvolutionChain evoChain) {
      var evo = evoChain.chain;
      int evoNo = 1;
      var addEvolution = (Pokemon pkm, int no) {
        evolutions.add(MyPokemon(
          id: pkm.id,
          name: pkm.name,
          speciesId: pkm.id,
          artwork: pkm.sprites.other.officialArtwork.frontDefault,
          types: pkm.types,
          evolutionNo: no,
        ));
        evolutions.sort((a, b) => a.id.compareTo(b.id));
      };
      do {
        int numOfEvo = evo.evolvesTo.length;
        int tempEvoNo = evoNo;
        int id = Utility.getPkmSpecIdFromUrl(evo.species.url);
        MyPokeApi.getPokemon(id: id).then((pkm) {
          addEvolution(pkm, tempEvoNo);
        });
        evoNo++;
        if (numOfEvo > 1) {
          for (int i = 1; i < numOfEvo; i++) {
            int _tempEvoNo = evoNo;
            int _id = Utility.getPkmSpecIdFromUrl(evo.evolvesTo[i].species.url);
            MyPokeApi.getPokemon(id: _id).then((pkm) {
              addEvolution(pkm, _tempEvoNo);
            });
          }
        }
        evo = numOfEvo > 0 ? evo.evolvesTo[0] : null;
      } while (evo != null);
    };
    MyPokeApi.getEvolutionChain(
            id: Utility.getEvoChainIdFromUrl(pkmSpec.evolutionChain.url))
        .then((evoChain) {
      handleEvo(evoChain);
    });
  }

  void _getAlternativeForms(PokemonSpecies pkmSpec) {
    var addForm = (Pokemon pkm) {
      String art = pkm.sprites.other.officialArtwork.frontDefault;
      if (art.isNotEmpty) {
        alternativeForms.add(MyPokemon(
          id: pkm.id,
          name: pkm.name,
          speciesId: pkmSpec.id,
          artwork: art,
          types: pkm.types,
        ));
        alternativeForms.sort((a, b) => a.id.compareTo(b.id));
      }
    };
    pkmSpec.varieties.forEach((element) {
      MyPokeApi.getPokemon(id: Utility.getPkmIdFromUrl(element.pokemon.url))
          .then((pkm) {
        addForm(pkm);
      });
    });
  }
}
