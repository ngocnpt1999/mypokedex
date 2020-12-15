import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';
import 'package:http/http.dart' as http;

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

  void getNewPokemons() {
    if (_loading == false) {
      _loading = true;
      _api.pokemon
          .getPage(offset: pokemons.length, limit: _limit)
          .then((response) {
        int prevlength = pokemons.length;
        response.results.forEach((value) {
          _api.pokemon.get(name: value.name).then((pokemon) {
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
      });
    }
  }
}

class PokemonDetailController extends GetxController {
  var _api = PokeApi();

  Rx<Pokemon> pokemon;

  var evolutions = List<List<MyPokemon>>().obs;

  PokemonDetailController(int pokemon_id) {}

  void getEvolutionData(int pokemon_id) {
    _api.pokemonSpecies.get(id: pokemon_id).then((pokeSpec) async {
      var response = await http.get(pokeSpec.evolutionChain.url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        EvolutionChain evoChain = EvolutionChain.fromJson(jsonData);
        var evo = evoChain.chain;
        while (evo != null && evo.evolvesTo.length > 0) {
          List<MyPokemon> pokemons = List();
          evo.evolvesTo.forEach((value) {
            _api.pokemon.get(name: value.species.name).then((poke) {
              pokemons.add(MyPokemon(
                id: poke.id,
                name: poke.name,
                artwork: poke.sprites.other.officialArtwork.frontDefault,
                types: poke.types,
              ));
              pokemons.sort((a, b) => a.id.compareTo(b.id));
            });
          });
          evolutions.add(pokemons);
          evo = evo.evolvesTo[0];
        }
      } else {
        throw Exception("Failed!!!");
      }
    });
  }
}
