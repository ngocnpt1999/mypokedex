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
  int genderRate; //The chance of this Pokémon being female, in eighths; or -1 for genderless
  int evolutionNo;

  MyPokemon({
    @required this.id,
    @required this.name,
    @required this.speciesId,
    this.genus,
    this.entry,
    this.artwork,
    this.height,
    this.weight,
    this.types,
    this.abilities,
    this.genderRate,
    this.evolutionNo,
  });

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

  String getGenders() {
    if (genderRate == -1) {
      return "Unknown";
    } else if (genderRate == 0) {
      return "♂";
    } else if (genderRate == 8) {
      return "♀";
    } else {
      return "♂ ♀";
    }
  }
}
