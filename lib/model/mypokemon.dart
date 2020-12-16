import 'package:pokeapi_dart/pokeapi_dart.dart';

class MyPokemon {
  int id;
  String name;
  String artwork;
  List<PokemonType> types;
  int evoForm = 0;

  MyPokemon({this.id, this.name, this.artwork, this.types, this.evoForm});
}
