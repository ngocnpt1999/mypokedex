import 'package:flutter/material.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

class MyPokemon {
  int id;
  String name;
  String entry;
  String artwork;
  int height;
  int weight;
  List<PokemonType> types;
  List<PokemonAbility> abilities;
  int evolutionNo;

  MyPokemon(
      {@required this.id,
      @required this.name,
      this.entry,
      this.artwork,
      this.height,
      this.weight,
      this.types,
      this.abilities,
      this.evolutionNo});

  //Can't use for alternative forms
  String getPokedexNo() {
    String pokemonNo = id.toString();
    if (id >= 10 && id < 100) {
      pokemonNo = "0" + pokemonNo;
    } else if (id < 10) {
      pokemonNo = "00" + pokemonNo;
    }
    return "#" + pokemonNo;
  }
}
