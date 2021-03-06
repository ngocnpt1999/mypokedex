import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/list_favorite_pokemon.dart';
import 'package:mypokedex/list_pokemon.dart';
import 'package:mypokedex/model/mypokemon.dart';
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
}

class PokemonTileController extends GetxController {
  PokemonTileController({MyPokemon pokemon, bool isHideArtwork = false}) {
    this.pokemon.value = pokemon;
    this.isHideArtwork.value = isHideArtwork;
  }

  var pokemon = MyPokemon(id: null, name: null, speciesId: null).obs;

  var isHideArtwork = false.obs;
}

class ListPokemonController extends GetxController {
  ListPokemonController() {
    scrollController.addListener(() {
      if (pkmTileControllers.length < _totalPkm) {
        double maxPosition = scrollController.position.maxScrollExtent;
        double currentPosition = scrollController.position.pixels;
        if (maxPosition - currentPosition <= Get.height / 3) {
          getNewPokemons();
        }
      }
    });
  }

  var _api = PokeApi();

  var scrollController = ScrollController();

  var pkmTileControllers = <PokemonTileController>[].obs;

  bool _isHideAllArtwork = false;

  int _limit = 15;

  int _totalPkm = 809;

  bool _loading = false;

  void getNewPokemons() async {
    if (_loading == false) {
      _loading = true;
      var names = pkmTileControllers.length + _limit >= _totalPkm
          ? SharedPrefs.instance.getPokedex().sublist(pkmTileControllers.length)
          : SharedPrefs.instance.getPokedex().sublist(
              pkmTileControllers.length, pkmTileControllers.length + _limit);
      if (names.length == 0) {
        _loading = false;
        return;
      }
      var tempControllers = <PokemonTileController>[];
      names.forEach((name) {
        _api.pokemon.get(name: name).then((pkm) {
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
          if (tempControllers.length == names.length) {
            tempControllers.sort(
                (a, b) => a.pokemon.value.id.compareTo(b.pokemon.value.id));
            pkmTileControllers.addAll(tempControllers);
            _loading = false;
          }
        });
      });
      //Loading... countdown
      int start = 10;
      Duration oneSec = Duration(seconds: 1);
      Timer countdown;
      countdown = Timer.periodic(oneSec, (timer) {
        if (tempControllers.length == names.length) {
          timer.cancel();
          countdown.cancel();
        } else if (start == 0) {
          _loading = false;
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

  bool endOfData() {
    if (pkmTileControllers.length == _totalPkm) {
      return true;
    }
    return false;
  }
}

class ListFavoritePokemonController extends GetxController {
  ListFavoritePokemonController() {
    scrollController.addListener(() {
      if (pkmTileControllers.length <
          SharedPrefs.instance.getFavoritesPokemon().length) {
        double maxPosition = scrollController.position.maxScrollExtent;
        double currentPosition = scrollController.position.pixels;
        if (maxPosition - currentPosition <= Get.height / 3) {
          getNewFavoritePokemons();
        }
      }
    });
  }

  var _api = PokeApi();

  var scrollController = ScrollController();

  var pkmTileControllers = <PokemonTileController>[].obs;

  bool _isHideAllArtwork = false;

  int _limit = 15;

  bool _loading = false;

  void getNewFavoritePokemons() async {
    if (SharedPrefs.instance.getFavoritesPokemon().length == 0) {
      return;
    }
    if (_loading == false) {
      _loading = true;
      int totalPkm = SharedPrefs.instance.getFavoritesPokemon().length;
      var ids = pkmTileControllers.length + _limit >= totalPkm
          ? SharedPrefs.instance
              .getFavoritesPokemon()
              .sublist(pkmTileControllers.length)
          : SharedPrefs.instance.getFavoritesPokemon().sublist(
              pkmTileControllers.length, pkmTileControllers.length + _limit);
      if (ids.length == 0) {
        _loading = false;
        return;
      }
      var tempControllers = <PokemonTileController>[];
      ids.forEach((id) {
        _api.pokemon.get(id: int.parse(id)).then((pkm) {
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
          if (tempControllers.length == ids.length) {
            tempControllers.sort(
                (a, b) => a.pokemon.value.id.compareTo(b.pokemon.value.id));
            pkmTileControllers.addAll(tempControllers);
            _loading = false;
          }
        });
      });
      //Loading... countdown
      int start = 10;
      Duration oneSec = Duration(seconds: 1);
      Timer countdown;
      countdown = Timer.periodic(oneSec, (timer) {
        if (tempControllers.length == ids.length) {
          timer.cancel();
          countdown.cancel();
        } else if (start == 0) {
          _loading = false;
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
    getNewFavoritePokemons();
  }

  bool endOfData() {
    if (pkmTileControllers.length ==
        SharedPrefs.instance.getFavoritesPokemon().length) {
      return true;
    }
    return false;
  }
}

class PokemonDetailController extends GetxController {
  PokemonDetailController();

  var _api = PokeApi();

  var isHideArtwork = false.obs;

  var pokemon = MyPokemon(id: null, name: null, speciesId: null).obs;

  var evolutions = <MyPokemon>[].obs;

  var alternativeForms = <MyPokemon>[].obs;

  void init({int id, String name}) {
    pokemon.value = MyPokemon(id: null, name: null, speciesId: null);
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
        String pkmName;
        if (evo.species.name == "deoxys") {
          pkmName = "deoxys-normal";
        } else if (evo.species.name == "mimikyu") {
          pkmName = "mimikyu-disguised";
        } else {
          pkmName = evo.species.name;
        }
        int numOfEvo = evo.evolvesTo.length;
        int tempEvoNo = evoNo;
        _api.pokemon.get(name: pkmName).then((pkm) {
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
            _api.pokemon.get(name: evo.evolvesTo[i].species.name).then((pkm) {
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
