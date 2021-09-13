import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/pokeapi_http.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/extension/utility.dart';
import 'package:mypokedex/page/list_favorite_pokemon.dart';
import 'package:mypokedex/page/list_pokemon.dart';
import 'package:mypokedex/extension/actions.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/pokemon_generation.dart';
import 'package:mypokedex/model/pokemon_type.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

part 'state_management_part.dart';

class HomeController extends GetxController {
  HomeController() {
    initControllers();
    pages = <Widget>[
      ListPokemonPage(),
      ListFavoritePokemonPage(),
    ];
  }

  void initControllers() {
    Get.put(ListPokemonController());
    Get.put(ListFavoritePokemonController());
    Get.put(PokemonDetailController());
    Get.put(PokemonAbilityDetailController());
  }

  var pages = <Widget>[];

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

class ListPokemonController extends GetxController {
  ListPokemonController() {
    scrollController.addListener(() {
      if (scrollController.hasClients) {
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
      }
    });
  }

  bool get hasData {
    if (this.pkmTileControllers.length > 0) {
      return true;
    } else {
      return false;
    }
  }

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
                allowStats: true,
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
      if (scrollController.hasClients) {
        if (pkmTileControllers.length <
            SharedPrefs.instance
                .getFavoritesPokemon(
                    generation: _generation, typeName: _typeName)
                .length) {
          double maxPosition = scrollController.position.maxScrollExtent;
          double currentPosition = scrollController.position.pixels;
          if (maxPosition - currentPosition <= Get.height / 3) {
            loadMore();
          }
        }
      }
    });
  }

  bool get hasData {
    if (this.pkmTileControllers.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  var scrollController = ScrollController();

  var pkmTileControllers = <PokemonTileController>[].obs;

  bool get hasFavorites {
    if (SharedPrefs.instance
            .getFavoritesPokemon(generation: _generation, typeName: _typeName)
            .length >
        0) {
      return true;
    } else {
      return false;
    }
  }

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
        _isLoading = false;
        return;
      }
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
                allowStats: true,
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
