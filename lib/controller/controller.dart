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

  var pokemon = MyPokemon().obs;

  var evolutions = List<MyPokemon>().obs;

  void getPokemon(int id) {
    _api.pokemon.get(id: id).then((poke) => pokemon.value = MyPokemon(
          id: poke.id,
          name: poke.name,
          artwork: poke.sprites.other.officialArtwork.frontDefault,
          height: poke.height,
          weight: poke.weight,
          types: poke.types,
          abilities: poke.abilities,
        ));
  }

  void getEvolutionData(int id) {
    _api.pokemonSpecies.get(id: id).then((pokeSpec) async {
      var response = await http.get(pokeSpec.evolutionChain.url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        EvolutionChain evoChain = EvolutionChain.fromJson(jsonData);
        var evo = evoChain.chain;
        int form = 1;
        do {
          int numOfEvo = evo.evolvesTo.length;
          int tempForm = form;
          _api.pokemon.get(name: evo.species.name).then((poke) {
            evolutions.add(MyPokemon(
              id: poke.id,
              name: poke.name,
              artwork: poke.sprites.other.officialArtwork.frontDefault,
              types: poke.types,
              evoForm: tempForm,
            ));
            evolutions.sort((a, b) => a.id.compareTo(b.id));
          });
          form++;
          if (numOfEvo > 1) {
            for (int i = 1; i < numOfEvo; i++) {
              int _tempForm = form;
              _api.pokemon
                  .get(name: evo.evolvesTo[i].species.name)
                  .then((poke) {
                evolutions.add(MyPokemon(
                  id: poke.id,
                  name: poke.name,
                  artwork: poke.sprites.other.officialArtwork.frontDefault,
                  types: poke.types,
                  evoForm: _tempForm,
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
}
