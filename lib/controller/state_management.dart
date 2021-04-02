import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/utility.dart';
import 'package:mypokedex/list_favorite_pokemon.dart';
import 'package:mypokedex/list_pokemon.dart';
import 'package:mypokedex/model/actions.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/pokemon_generation.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  HomeController();

  // ignore: unused_field
  var _pokemonDetailController = Get.put(PokemonDetailController());

  var pages = <Widget>[
    ListPokemonPage(),
    ListFavoritePokemonPage(),
  ];

  var selectedIndex = 0.obs;

  var selectedGen = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
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

  void changeGen(int gene) {
    selectedGen.value = gene;
    ListPokemonController listPkmController = Get.find();
    ListFavoritePokemonController listFrvPkmController = Get.find();
    listPkmController.changeGen(ListPokemonFilter.generations[gene]);
    listFrvPkmController.changeGen(ListPokemonFilter.generations[gene]);
  }

  void changeFilter(String filter) {
    ListPokemonController listPkmController = Get.find();
    ListFavoritePokemonController listFrvPkmController = Get.find();
    listPkmController.changeFilter(filter);
    listFrvPkmController.changeFilter(filter);
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
      int totalPkm =
          SharedPrefs.instance.getPokedex(generation: _generation).length;
      if (pkmTileControllers.length < totalPkm) {
        double maxPosition = scrollController.position.maxScrollExtent;
        double currentPosition = scrollController.position.pixels;
        if (maxPosition - currentPosition <= Get.height / 3) {
          loadMore();
        }
      }
    });
  }

  var _api = PokeApi();

  var scrollController = ScrollController();

  var pkmTileControllers = <PokemonTileController>[].obs;

  bool _isHideAllArtwork = false;

  String _generation = PokemonGeneration.allGen;

  String _filter = ListPokemonFilter.ascendingID;

  int _limit = 15;

  bool _isLoading = false;

  void loadMore() async {
    if (_isLoading == false) {
      _isLoading = true;
      int totalPkm =
          SharedPrefs.instance.getPokedex(generation: _generation).length;
      var jsonPkms = pkmTileControllers.length + _limit >= totalPkm
          ? SharedPrefs.instance
              .getPokedex(generation: _generation, filter: _filter)
              .sublist(pkmTileControllers.length)
          : SharedPrefs.instance
              .getPokedex(generation: _generation, filter: _filter)
              .sublist(pkmTileControllers.length,
                  pkmTileControllers.length + _limit);
      if (jsonPkms.length == 0) {
        _isLoading = false;
        return;
      }
      var tempControllers = <PokemonTileController>[];
      jsonPkms.forEach((element) {
        var value = jsonDecode(element) as Map<String, dynamic>;
        _api.pokemon.get(id: value["id"] as int).then((pkm) {
          tempControllers.add(PokemonTileController(
            pokemon: MyPokemon(
              id: pkm.id,
              name: pkm.name,
              speciesId: pkm.id,
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

  void changeGen(String generation) {
    if (generation != _generation) {
      _generation = generation;
      refresh();
    }
  }

  void changeFilter(String filter) {
    if (filter != _filter) {
      _filter = filter;
      refresh();
    }
  }

  bool endOfData() {
    int totalPkm =
        SharedPrefs.instance.getPokedex(generation: _generation).length;
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
              .getFavoritesPokemon(generation: _generation)
              .length) {
        double maxPosition = scrollController.position.maxScrollExtent;
        double currentPosition = scrollController.position.pixels;
        if (maxPosition - currentPosition <= Get.height / 3) {
          loadMore();
        }
      }
    });
  }

  var _api = PokeApi();

  var scrollController = ScrollController();

  var pkmTileControllers = <PokemonTileController>[].obs;

  var hasFavorites = false.obs;

  bool _isHideAllArtwork = false;

  String _generation = PokemonGeneration.allGen;

  String _filter = ListPokemonFilter.ascendingID;

  int _limit = 15;

  bool _isLoading = false;

  void loadMore() async {
    if (SharedPrefs.instance.getFavoritesPokemon().length == 0) {
      return;
    }
    if (_isLoading == false) {
      _isLoading = true;
      int totalPkm = SharedPrefs.instance
          .getFavoritesPokemon(generation: _generation)
          .length;
      if (totalPkm == 0) {
        hasFavorites.value = false;
        return;
      }
      hasFavorites.value = true;
      var jsonPkms = pkmTileControllers.length + _limit >= totalPkm
          ? SharedPrefs.instance
              .getFavoritesPokemon(generation: _generation, filter: _filter)
              .sublist(pkmTileControllers.length)
          : SharedPrefs.instance
              .getFavoritesPokemon(generation: _generation, filter: _filter)
              .sublist(pkmTileControllers.length,
                  pkmTileControllers.length + _limit);
      if (jsonPkms.length == 0) {
        _isLoading = false;
        return;
      }
      var tempControllers = <PokemonTileController>[];
      jsonPkms.forEach((element) {
        var value = jsonDecode(element) as Map<String, dynamic>;
        _api.pokemon.get(id: value["id"] as int).then((pkm) {
          tempControllers.add(PokemonTileController(
            pokemon: MyPokemon(
              id: pkm.id,
              name: pkm.name,
              speciesId: value["speciesId"] as int,
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

  void changeGen(String generation) {
    if (generation != _generation) {
      _generation = generation;
      refresh();
    }
  }

  void changeFilter(String filter) {
    if (filter != _filter) {
      _filter = filter;
      refresh();
    }
  }

  bool endOfData() {
    if (pkmTileControllers.length ==
        SharedPrefs.instance
            .getFavoritesPokemon(generation: _generation)
            .length) {
      return true;
    }
    return false;
  }
}

class PokemonDetailController extends GetxController {
  PokemonDetailController();

  var _api = PokeApi();

  var isHideArtwork = false.obs;

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;

  var evolutions = <MyPokemon>[].obs;

  var alternativeForms = <MyPokemon>[].obs;

  void init({int id, String name}) {
    pokemon.value = MyPokemon(id: 0, name: "", speciesId: 0);
    evolutions.clear();
    alternativeForms.clear();
    //
    _api.pokemon.get(id: id, name: name).then((pkm) {
      _api.pokemonSpecies.get(name: pkm.species.name).then((pkmSpec) {
        var info =
            pkmSpec.flavorTextEntries.lastWhere((e) => e.language.name == "en");
        var category =
            pkmSpec.genera.firstWhere((e) => e.language.name == "en");
        pokemon.value = MyPokemon(
          id: pkm.id,
          name: pkm.name,
          speciesId: pkmSpec.id,
          genus: category.genus,
          artwork: pkm.sprites.other.officialArtwork.frontDefault,
          entry: info.flavorText,
          height: pkm.height,
          weight: pkm.weight,
          types: pkm.types,
          abilities: pkm.abilities,
          genderRate: pkmSpec.genderRate,
        );
        _getEvolutionData(pkmSpec);
        _getAlternativeForms(pkmSpec);
      });
    });
  }

  void _getEvolutionData(PokemonSpecies pkmSpec) async {
    var response = await http.get(pkmSpec.evolutionChain.url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      EvolutionChain evoChain = EvolutionChain.fromJson(jsonData);
      var evo = evoChain.chain;
      int evoNo = 1;
      do {
        int numOfEvo = evo.evolvesTo.length;
        int tempEvoNo = evoNo;
        _api.pokemon
            .get(id: Utility.getPkmSpecIdFromUrl(evo.species.url))
            .then((pkm) {
          evolutions.add(MyPokemon(
            id: pkm.id,
            name: pkm.name,
            speciesId: pkm.id,
            artwork: pkm.sprites.other.officialArtwork.frontDefault,
            types: pkm.types,
            evolutionNo: tempEvoNo,
          ));
          evolutions.sort((a, b) => a.id.compareTo(b.id));
        });
        evoNo++;
        if (numOfEvo > 1) {
          for (int i = 1; i < numOfEvo; i++) {
            int _tempEvoNo = evoNo;
            _api.pokemon
                .get(
                    id: Utility.getPkmSpecIdFromUrl(
                        evo.evolvesTo[i].species.url))
                .then((pkm) {
              evolutions.add(MyPokemon(
                id: pkm.id,
                name: pkm.name,
                speciesId: pkm.id,
                artwork: pkm.sprites.other.officialArtwork.frontDefault,
                types: pkm.types,
                evolutionNo: _tempEvoNo,
              ));
              evolutions.sort((a, b) => a.id.compareTo(b.id));
            });
          }
        }
        evo = numOfEvo > 0 ? evo.evolvesTo[0] : null;
      } while (evo != null);
    } else {
      print("Can't get evolution chain");
      throw Exception("Failed!!!");
    }
  }

  void _getAlternativeForms(PokemonSpecies pkmSpec) {
    pkmSpec.varieties.forEach((element) {
      _api.pokemon.get(name: element.pokemon.name).then((pkm) {
        String art = pkm.sprites.other.officialArtwork.frontDefault;
        if (!art.isBlank && art.isNotEmpty) {
          alternativeForms.add(MyPokemon(
            id: pkm.id,
            name: pkm.name,
            speciesId: pkmSpec.id,
            artwork: art,
            types: pkm.types,
          ));
          alternativeForms.sort((a, b) => a.id.compareTo(b.id));
        }
      });
    });
  }
}
