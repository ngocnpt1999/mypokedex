import 'package:flutter/material.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

class MyPokemon {
  int id;
  String name;
  int speciesId;
  String genus;
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
      @required this.speciesId,
      this.genus,
      this.entry,
      this.artwork,
      this.height,
      this.weight,
      this.types,
      this.abilities,
      this.evolutionNo});

  //Can't use for alternative forms
  String getPokedexNo() {
    String pokemonNo = speciesId.toString();
    if (speciesId >= 10 && speciesId < 100) {
      pokemonNo = "0" + pokemonNo;
    } else if (speciesId < 10) {
      pokemonNo = "00" + pokemonNo;
    }
    return "#" + pokemonNo;
  }
}
