import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

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

  var pokemons = List<Pokemon>().obs;

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
            pokemons.add(pokemon);
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
