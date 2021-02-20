import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListPokemonController extends GetxController {
  ListPokemonController() {
    scrollController.addListener(() {
      double maxPosition = scrollController.position.maxScrollExtent;
      double currentPosition = scrollController.position.pixels;
      if (maxPosition - currentPosition <= Get.height / 3) {
        getNewPokemons();
      }
    });
  }

  var _api = PokeApi();

  var scrollController = ScrollController();

  var pokemons = List<MyPokemon>().obs;

  int _limit = 15;

  bool _loading = false;

  void getNewPokemons() async {
    if (_loading == false) {
      _loading = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var names = prefs
          .getStringList("pokedex")
          .sublist(pokemons.length, pokemons.length + _limit);
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
          if (tempPokemons.length == _limit) {
            tempPokemons.sort((a, b) => a.id.compareTo(b.id));
            pokemons.addAll(tempPokemons);
            _loading = false;
          }
        });
      });
    }
  }
}

class PokemonDetailController extends GetxController {
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
            speciesId: pokeSpec.id,
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
                speciesId: pokeSpec.id,
                artwork: poke.sprites.other.officialArtwork.frontDefault,
                types: poke.types,
                evolutionNo: _tempEvoNo,
              ));
              evolutions.sort((a, b) => a.id.compareTo(b.id));
            });
          }
        }
        evo = evo.evolvesTo[0];
      } while (evo != null && evo.evolvesTo.length >= 0);
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
