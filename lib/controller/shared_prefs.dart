import 'dart:convert';

import 'package:mypokedex/controller/pokeapi_http.dart';
import 'package:mypokedex/extension/utility.dart';
import 'package:mypokedex/extension/actions.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/pokemon_generation.dart';
import 'package:mypokedex/model/pokemon_type.dart';
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

  Future<List<bool>> clearCache() async {
    var deleteList = <Future<bool>>[
      deletePokedex(),
    ];
    for (int i = 1; i < ListPokemonFilter.types.length; i++) {
      deleteList.add(deleteTypePokemons(ListPokemonFilter.types[i]));
    }
    return await Future.wait(deleteList);
  }

  Future<List<bool>> fetchData() async {
    var initList = <Future<bool>>[
      fetchPokedex(),
    ];
    for (int i = 1; i < ListPokemonFilter.types.length; i++) {
      initList.add(fetchTypePokemons(ListPokemonFilter.types[i]));
    }
    return await Future.wait(initList);
  }

  Future<bool> fetchPokedex() async {
    int totalPkm = 809;
    var response = await MyPokeApi.getPokemonPage(offset: 0, limit: totalPkm);
    List<String> pokedex = [];
    response.results.forEach((element) {
      int id = Utility.getPkmIdFromUrl(element.url);
      var pkm = MyPokemon(id: id, name: element.name, speciesId: id);
      pokedex.add(jsonEncode(pkm.toJson()));
    });
    var isFinish = await _prefs.setStringList("pokedex", pokedex);
    return isFinish;
  }

  List<String> getPokedex(
      {String generation = PokemonGeneration.allGen,
      String filter = ListPokemonFilter.ascendingID,
      String typeName = MyPokemonType.allType}) {
    if (!_prefs.containsKey("pokedex")) {
      return <String>[];
    }
    var list = ListPokemonFilter.filterByGen(
        _prefs.getStringList("pokedex"), generation);
    list = ListPokemonFilter.filterByType(list, typeName);
    list = ListPokemonFilter.filterByIdOrAlphabet(list, filter);
    return list;
  }

  Future<bool> deletePokedex() async {
    var isFinish = await _prefs.remove("pokedex");
    return isFinish;
  }

  Future<bool> fetchTypePokemons(String typeName) async {
    var type = await MyPokeApi.getPokemonType(name: typeName);
    List<String> pokemons = [];
    type.pokemon.forEach((element) {
      int id = Utility.getPkmIdFromUrl(element.pokemon.url);
      pokemons.add(id.toString());
    });
    var isFinish = await _prefs.setStringList("type_$typeName", pokemons);
    return isFinish;
  }

  List<String> getTypePokemons(String typeName) {
    if (!_prefs.containsKey("type_$typeName")) {
      return <String>[];
    }
    var list = _prefs.getStringList("type_$typeName");
    return list;
  }

  Future<bool> deleteTypePokemons(String typeName) async {
    var isFinish = await _prefs.remove("type_$typeName");
    return isFinish;
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
      String filter = ListPokemonFilter.ascendingID,
      String typeName = MyPokemonType.allType}) {
    if (!_prefs.containsKey("favoritesPokemon")) {
      return <String>[];
    }
    var list = ListPokemonFilter.filterByGen(
        _prefs.getStringList("favoritesPokemon"), generation);
    list = ListPokemonFilter.filterByType(list, typeName);
    list = ListPokemonFilter.filterByIdOrAlphabet(list, filter);
    return list;
  }
}
