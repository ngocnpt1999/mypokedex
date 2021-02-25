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

  var pages = <Widget>[
    ListPokemonPage(),
    ListFavoritePokemonPage(),
  ];

  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class ListPokemonController extends GetxController {
  ListPokemonController() {
    scrollController.addListener(() {
      if (pokemons.length < _totalPkm) {
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

  var pokemons = List<MyPokemon>().obs;

  int _limit = 15;

  int _totalPkm = 809;

  bool _loading = false;

  void getNewPokemons() async {
    if (_loading == false) {
      _loading = true;
      var names = pokemons.length + _limit >= _totalPkm
          ? SharedPrefs.instance.getPokedex().sublist(pokemons.length)
          : SharedPrefs.instance
              .getPokedex()
              .sublist(pokemons.length, pokemons.length + _limit);
      if (names.length == 0) {
        _loading = false;
        return;
      }
      var tempPokemons = List<MyPokemon>();
      names.forEach((name) {
        _api.pokemon.get(name: name).then((pokemon) {
          tempPokemons.add(MyPokemon(
            id: pokemon.id,
            name: pokemon.name,
            speciesId: pokemon.id,
            artwork: pokemon.sprites.other.officialArtwork.frontDefault,
            types: pokemon.types,
          ));
          if (tempPokemons.length == names.length) {
            tempPokemons.sort((a, b) => a.id.compareTo(b.id));
            pokemons.addAll(tempPokemons);
            _loading = false;
          }
        });
      });
    }
  }
}

class ListFavoritePokemonController extends GetxController {
  ListFavoritePokemonController() {
    scrollController.addListener(() {
      if (favoritePokemons.length <
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

  var favoritePokemons = List<MyPokemon>().obs;

  int _limit = 15;

  bool _loading = false;

  void getNewFavoritePokemons() async {
    if (SharedPrefs.instance.getFavoritesPokemon().length == 0) {
      return;
    }
    if (_loading == false) {
      _loading = true;
      int totalPkm = SharedPrefs.instance.getFavoritesPokemon().length;
      var ids = favoritePokemons.length + _limit >= totalPkm
          ? SharedPrefs.instance
              .getFavoritesPokemon()
              .sublist(favoritePokemons.length)
          : SharedPrefs.instance.getFavoritesPokemon().sublist(
              favoritePokemons.length, favoritePokemons.length + _limit);
      if (ids.length == 0) {
        _loading = false;
        return;
      }
      var tempPokemons = List<MyPokemon>();
      ids.forEach((id) {
        _api.pokemon.get(id: int.parse(id)).then((pokemon) {
          tempPokemons.add(MyPokemon(
            id: pokemon.id,
            name: pokemon.name,
            speciesId: pokemon.id,
            artwork: pokemon.sprites.other.officialArtwork.frontDefault,
            types: pokemon.types,
          ));
          if (tempPokemons.length == ids.length) {
            tempPokemons.sort((a, b) => a.id.compareTo(b.id));
            favoritePokemons.addAll(tempPokemons);
            _loading = false;
          }
        });
      });
    }
  }

  void refresh() {
    favoritePokemons.clear();
    getNewFavoritePokemons();
  }
}

class PokemonDetailController extends GetxController {
  PokemonDetailController();

  var _api = PokeApi();

  var pokemon = MyPokemon(id: null, name: null, speciesId: null).obs;

  var evolutions = List<MyPokemon>().obs;

  var alternativeForms = List<MyPokemon>().obs;

  void init({int id, String name}) {
    pokemon.value = MyPokemon(id: null, name: null, speciesId: null);
    evolutions.clear();
    alternativeForms.clear();
    //
    _api.pokemon.get(id: id, name: name).then((poke) {
      _api.pokemonSpecies.get(name: poke.species.name).then((pokeSpec) {
        var info = pokeSpec.flavorTextEntries
            .lastWhere((e) => e.language.name == "en");
        var category =
            pokeSpec.genera.firstWhere((e) => e.language.name == "en");
        pokemon.value = MyPokemon(
          id: poke.id,
          name: poke.name,
          speciesId: pokeSpec.id,
          genus: category.genus,
          artwork: poke.sprites.other.officialArtwork.frontDefault,
          entry: info.flavorText,
          height: poke.height,
          weight: poke.weight,
          types: poke.types,
          abilities: poke.abilities,
          genderRate: pokeSpec.genderRate,
        );
        _getEvolutionData(pokeSpec);
        _getAlternativeForms(pokeSpec);
      });
    });
  }

  void _getEvolutionData(PokemonSpecies pokeSpec) async {
    var response = await http.get(pokeSpec.evolutionChain.url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      EvolutionChain evoChain = EvolutionChain.fromJson(jsonData);
      var evo = evoChain.chain;
      int evoNo = 1;
      do {
        int numOfEvo = evo.evolvesTo.length;
        int tempEvoNo = evoNo;
        _api.pokemon.get(name: evo.species.name).then((poke) {
          evolutions.add(MyPokemon(
            id: poke.id,
            name: poke.name,
            speciesId: poke.id,
            artwork: poke.sprites.other.officialArtwork.frontDefault,
            types: poke.types,
            evolutionNo: tempEvoNo,
          ));
          evolutions.sort((a, b) => a.id.compareTo(b.id));
        });
        evoNo++;
        if (numOfEvo > 1) {
          for (int i = 1; i < numOfEvo; i++) {
            int _tempEvoNo = evoNo;
            _api.pokemon.get(name: evo.evolvesTo[i].species.name).then((poke) {
              evolutions.add(MyPokemon(
                id: poke.id,
                name: poke.name,
                speciesId: poke.id,
                artwork: poke.sprites.other.officialArtwork.frontDefault,
                types: poke.types,
                evolutionNo: _tempEvoNo,
              ));
              evolutions.sort((a, b) => a.id.compareTo(b.id));
            });
          }
        }
        evo = evo.evolvesTo.length > 0 ? evo.evolvesTo[0] : null;
      } while (evo != null);
    } else {
      print("Can't get evolution chain");
      throw Exception("Failed!!!");
    }
  }

  void _getAlternativeForms(PokemonSpecies pokeSpec) {
    pokeSpec.varieties.forEach((v) {
      _api.pokemon.get(name: v.pokemon.name).then((poke) {
        String art = poke.sprites.other.officialArtwork.frontDefault;
        if (!art.isBlank && art.isNotEmpty) {
          alternativeForms.add(MyPokemon(
            id: poke.id,
            name: poke.name,
            speciesId: pokeSpec.id,
            artwork: art,
            types: poke.types,
          ));
          alternativeForms.sort((a, b) => a.id.compareTo(b.id));
        }
      });
    });
  }
}
