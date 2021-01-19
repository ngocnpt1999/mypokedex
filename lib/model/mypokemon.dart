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
}
