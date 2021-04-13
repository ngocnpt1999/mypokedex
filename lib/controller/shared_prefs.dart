import 'dart:convert';

import 'package:mypokedex/controller/pokeapi_http.dart';
import 'package:mypokedex/controller/utility.dart';
import 'package:mypokedex/controller/actions.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/pokemon_generation.dart';
import 'package:mypokedex/model/pokemon_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._privateConstructor();

  static final SharedPrefs instance = SharedPrefs._privateConstructor();

  SharedPreferences _prefs;

  Future<List<bool>> clearCache() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    var deleteList = <Future<bool>>[
      deletePokedex(),
      deleteTypePokemons(MyPokemonType.bug),
      deleteTypePokemons(MyPokemonType.dark),
      deleteTypePokemons(MyPokemonType.dragon),
      deleteTypePokemons(MyPokemonType.electric),
      deleteTypePokemons(MyPokemonType.fairy),
      deleteTypePokemons(MyPokemonType.fighting),
      deleteTypePokemons(MyPokemonType.fire),
      deleteTypePokemons(MyPokemonType.flying),
      deleteTypePokemons(MyPokemonType.ghost),
      deleteTypePokemons(MyPokemonType.grass),
      deleteTypePokemons(MyPokemonType.ground),
      deleteTypePokemons(MyPokemonType.ice),
      deleteTypePokemons(MyPokemonType.normal),
      deleteTypePokemons(MyPokemonType.poison),
      deleteTypePokemons(MyPokemonType.psychic),
      deleteTypePokemons(MyPokemonType.rock),
      deleteTypePokemons(MyPokemonType.steel),
      deleteTypePokemons(MyPokemonType.water),
    ];
    return await Future.wait(deleteList);
  }

  Future<List<bool>> init() async {
    var initList = <Future<bool>>[
      initPokedex(),
      initTypePokemons(MyPokemonType.bug),
      initTypePokemons(MyPokemonType.dark),
      initTypePokemons(MyPokemonType.dragon),
      initTypePokemons(MyPokemonType.electric),
      initTypePokemons(MyPokemonType.fairy),
      initTypePokemons(MyPokemonType.fighting),
      initTypePokemons(MyPokemonType.fire),
      initTypePokemons(MyPokemonType.flying),
      initTypePokemons(MyPokemonType.ghost),
      initTypePokemons(MyPokemonType.grass),
      initTypePokemons(MyPokemonType.ground),
      initTypePokemons(MyPokemonType.ice),
      initTypePokemons(MyPokemonType.normal),
      initTypePokemons(MyPokemonType.poison),
      initTypePokemons(MyPokemonType.psychic),
      initTypePokemons(MyPokemonType.rock),
      initTypePokemons(MyPokemonType.steel),
      initTypePokemons(MyPokemonType.water),
    ];
    return await Future.wait(initList);
  }

  Future<bool> initPokedex() async {
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
    var prefs = await SharedPreferences.getInstance();
    var isFinish = await prefs.remove("pokedex");
    return isFinish;
  }

  Future<bool> initTypePokemons(String typeName) async {
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
    var prefs = await SharedPreferences.getInstance();
    var isFinish = await prefs.remove("type_$typeName");
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
