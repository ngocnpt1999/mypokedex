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
  int evoForm;

  MyPokemon(
      {this.id,
      this.name,
      this.entry,
      this.artwork,
      this.height,
      this.weight,
      this.types,
      this.abilities,
      this.evoForm});
}