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
      {this.id = 0,
      this.name = "",
      this.entry = "",
      this.artwork = "",
      this.height = 0,
      this.weight = 0,
      this.types,
      this.abilities,
      this.evoForm = 0});
}
