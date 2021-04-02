import 'dart:convert';

import 'package:mypokedex/model/actions.dart';
import 'package:mypokedex/model/pokemon_generation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._privateConstructor();

  static final SharedPrefs instance = SharedPrefs._privateConstructor();

  SharedPreferences _prefs;

  Future<SharedPreferences> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs;
  }

  Future<bool> setPokedex(List<String> pokedex) async {
    var isFinish = await _prefs.setStringList("pokedex", pokedex);
    return isFinish;
  }

  List<String> getPokedex(
      {String generation = PokemonGeneration.allGen,
      String filter = ListPokemonFilter.ascendingID}) {
    if (!_prefs.containsKey("pokedex")) {
      return <String>[];
    }
    var list = ListPokemonFilter.filterByGen(
        _prefs.getStringList("pokedex"), generation);
    list = ListPokemonFilter.filterByIdOrAlphabet(list, filter);
    return list;
  }

  Future<bool> setRecentSearch(List<String> recents) async {
    var isFinish = await _prefs.setStringList("recentSearchPokemon", recents);
    return isFinish;
  }

  List<String> getRecentSearch() {
    if (!_prefs.containsKey("recentSearchPokemon")) {
      return <String>[];
    }
    return _prefs.getStringList("recentSearchPokemon");
  }

  Future<bool> setFavoritesPokemon(List<String> favorites) async {
    favorites.sort((a, b) {
      var mapA = jsonDecode(a) as Map<String, dynamic>;
      var mapB = jsonDecode(b) as Map<String, dynamic>;
      return (mapA["speciesId"] as int).compareTo(mapB["speciesId"] as int);
    });
    var isFinish = await _prefs.setStringList("favoritesPokemon", favorites);
    return isFinish;
  }

  List<String> getFavoritesPokemon(
      {String generation = PokemonGeneration.allGen,
      String filter = ListPokemonFilter.ascendingID}) {
    if (!_prefs.containsKey("favoritesPokemon")) {
      return <String>[];
    }
    var list = ListPokemonFilter.filterByGen(
        _prefs.getStringList("favoritesPokemon"), generation);
    list = ListPokemonFilter.filterByIdOrAlphabet(list, filter);
    return list;
  }
}
