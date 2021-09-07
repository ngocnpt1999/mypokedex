part of 'state_management.dart';

class PokemonDetailController extends GetxController {
  PokemonDetailController();

  ScrollController scrollController = ScrollController();

  var isHideArtwork = false.obs;

  var activeBaseStat = true.obs;
  var activeMinStat = false.obs;
  var activeMaxStat = false.obs;

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;

  void init({MyPokemon pokemon, int id, String name}) async {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels > 0) {
        scrollController.jumpTo(0);
      }
    }
    this.pokemon.value = MyPokemon(id: 0, name: "", speciesId: 0);
    activeBaseStat.value = true;
    activeMinStat.value = false;
    activeMaxStat.value = false;
    //
    if (pokemon != null) {
      this.pokemon.value = pokemon;
      this.pokemon.value.initAll();
    } else {
      var pkm = await MyPokeApi.getPokemon(id: id, name: name);
      var pkmSpec = await MyPokeApi.getPokemonSpecies(name: pkm.species.name);
      this.pokemon.value = MyPokemon(
        id: pkm.id,
        name: pkm.name,
        speciesId: pkmSpec.id,
        allowStats: true,
        allowExpansion: true,
      );
    }
  }
}

class PokemonAbilityDetailController extends GetxController {
  PokemonAbilityDetailController();

  var description = "".obs;

  var effect = "".obs;

  var shortEffect = "".obs;

  var normalPkmTileControllers = <PokemonTileController>[].obs;
  var hiddenPkmTileControllers = <PokemonTileController>[].obs;

  var isNormalAbility = true.obs;

  void init({int id, String name}) async {
    description.value = "";
    effect.value = "";
    shortEffect.value = "";
    normalPkmTileControllers.clear();
    hiddenPkmTileControllers.clear();
    isNormalAbility.value = true;
    //
    var ability = await MyPokeApi.getPokemonAbility(id: id, name: name);
    description.value = ability.flavorTextEntries
        .lastWhere((element) => element.language.name == "en")
        .flavorText;
    var effectEntry = ability.effectEntries
        .firstWhere((element) => element.language.name == "en");
    effect.value = effectEntry.effect;
    shortEffect.value = effectEntry.shortEffect;
    var tempControllers = <PokemonTileController>[];
    var tempHiddenControllers = <PokemonTileController>[];
    var normal = <Future<Pokemon>>[];
    var hidden = <Future<Pokemon>>[];
    ability.pokemon.forEach((element) {
      int id = Utility.getPkmIdFromUrl(element.pokemon.url);
      if (id <= 809) {
        if (element.isHidden) {
          hidden.add(MyPokeApi.getPokemon(id: id));
        } else {
          normal.add(MyPokeApi.getPokemon(id: id));
        }
      }
    });
    Future.wait(normal).then((pokemons) {
      pokemons.forEach((pkm) {
        if (pkm != null) {
          tempControllers.add(PokemonTileController(
            pokemon: MyPokemon(
              id: pkm.id,
              name: pkm.name,
              speciesId: Utility.getPkmSpecIdFromUrl(pkm.species.url),
              allowStats: true,
            ),
          ));
        }
      });
      normalPkmTileControllers.addAll(tempControllers);
    });
    Future.wait(hidden).then((pokemons) {
      pokemons.forEach((pkm) {
        if (pkm != null) {
          tempHiddenControllers.add(PokemonTileController(
            pokemon: MyPokemon(
              id: pkm.id,
              name: pkm.name,
              speciesId: Utility.getPkmSpecIdFromUrl(pkm.species.url),
              allowStats: true,
            ),
          ));
        }
      });
      hiddenPkmTileControllers.addAll(tempHiddenControllers);
    });
  }
}

class PokemonCardController extends GetxController {
  PokemonCardController({MyPokemon pokemon}) {
    this.pokemon.value = pokemon;
  }

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;
}
