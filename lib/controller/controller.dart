import 'package:get/get.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';

class ListPokemonController extends GetxController {
  var _api = PokeApi();

  var pokemons = List<Pokemon>().obs;

  void getNewPokemons() {
    _api.pokemon.getPage(offset: 0, limit: 20).then((response) {
      response.results.forEach((value) {
        _api.pokemon.get(name: value.name).then((pokemon) {
          pokemons.add(pokemon);
          pokemons.sort((a, b) => a.id.compareTo(b.id));
        });
      });
    });
  }
}
