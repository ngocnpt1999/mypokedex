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
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
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
      int prevlength = pokemons.length;
      names.forEach((name) {
        _api.pokemon.get(name: name).then((pokemon) {
          pokemons.add(MyPokemon(
            id: pokemon.id,
            name: pokemon.name,
            artwork: pokemon.sprites.other.officialArtwork.frontDefault,
            types: pokemon.types,
          ));
          pokemons.sort((a, b) => a.id.compareTo(b.id));
          if (pokemons.length - prevlength == _limit) {
            _loading = false;
          }
        });
      });
    }
  }
}

class PokemonDetailController extends GetxController {
  var _api = PokeApi();

  var pokemon = MyPokemon(id: null, name: null).obs;

  var evolutions = List<MyPokemon>().obs;

  var alternativeForms = List<MyPokemon>().obs;

  void getPokemonData({int id, String name}) {
    _api.pokemon.get(id: id, name: name).then((poke) {
      _api.pokemonSpecies.get(id: id, name: name).then((spec) {
        var temp =
            spec.flavorTextEntries.lastWhere((e) => e.language.name == "en");
        pokemon.value = MyPokemon(
          id: poke.id,
          name: poke.name,
          artwork: poke.sprites.other.officialArtwork.frontDefault,
          entry: temp.flavorText,
          height: poke.height,
          weight: poke.weight,
          types: poke.types,
          abilities: poke.abilities,
        );
      });
    });
  }

  void getEvolutionData({int id, String name}) {
    _api.pokemonSpecies.get(id: id, name: name).then((pokeSpec) async {
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
              _api.pokemon
                  .get(name: evo.evolvesTo[i].species.name)
                  .then((poke) {
                evolutions.add(MyPokemon(
                  id: poke.id,
                  name: poke.name,
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
        throw Exception("Failed!!!");
      }
    });
  }

  void getAlternativeForms({int id, String name}) {
    _api.pokemonSpecies.get(id: id, name: name).then((spec) {
      spec.varieties.forEach((v) {
        _api.pokemon.get(name: v.pokemon.name).then((poke) {
          String art = poke.sprites.other.officialArtwork.frontDefault;
          if (!art.isNullOrBlank && art.isNotEmpty) {
            alternativeForms.add(MyPokemon(
              id: poke.id,
              name: poke.name,
              artwork: art,
              types: poke.types,
            ));
            alternativeForms.sort((a, b) => a.id.compareTo(b.id));
          }
        });
      });
    });
  }
}
