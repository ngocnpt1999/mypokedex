part of 'state_management.dart';

class PokemonDetailController extends GetxController {
  PokemonDetailController();

  ScrollController scrollController = ScrollController();

  var isHideArtwork = false.obs;

  var activeBaseStat = true.obs;
  var activeMinStat = false.obs;
  var activeMaxStat = false.obs;

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;

  var weakness = <String, double>{}.obs;
  var evolutions = <MyPokemon>[].obs;
  var alternativeForms = <MyPokemon>[].obs;

  void load({MyPokemon pokemon}) async {
    _reset();
    var pkm = await MyPokeApi.getPokemon(
        id: pokemon.id.value, name: pokemon.name.value);
    var pkmSpec =
        await MyPokeApi.getPokemonSpecies(id: pokemon.speciesId.value);
    this.pokemon.value = pokemon;
    this.pokemon.value.checkFavorite();
    this.weakness.addAll(await _getTypeWeakness(pkm.types));
    this.evolutions.addAll(await _getEvolutions(pkmSpec));
    this.alternativeForms.addAll(await _getAlternativeForms(pkmSpec));
  }

  void loadByIdOrName({int id, String name}) async {
    _reset();
    var pkm = await MyPokeApi.getPokemon(id: id, name: name);
    var pkmSpec = await MyPokeApi.getPokemonSpecies(name: pkm.species.name);
    this.pokemon.value = MyPokemon(
      id: pkm.id,
      name: pkm.name,
      speciesId: pkmSpec.id,
      allowStats: true,
    );
    this.pokemon.value.checkFavorite();
    this.weakness.addAll(await _getTypeWeakness(pkm.types));
    this.evolutions.addAll(await _getEvolutions(pkmSpec));
    this.alternativeForms.addAll(await _getAlternativeForms(pkmSpec));
  }

  void _reset() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels > 0) {
        scrollController.jumpTo(0);
      }
    }
    this.pokemon.value = MyPokemon(id: 0, name: "", speciesId: 0);
    activeBaseStat.value = true;
    activeMinStat.value = false;
    activeMaxStat.value = false;
    weakness.clear();
    evolutions.clear();
    alternativeForms.clear();
  }

  Future<Map<String, double>> _getTypeWeakness(List<PokemonType> types) async {
    var tempWeakness = <String, double>{};
    for (int i = 0; i < types.length; i++) {
      var type = await MyPokeApi.getPokemonType(name: types[i].type.name);
      type.damageRelations.doubleDamageFrom.forEach((element) {
        if (tempWeakness.containsKey(element.name)) {
          tempWeakness[element.name] = tempWeakness[element.name] * 2.0;
        } else {
          tempWeakness[element.name] = 2.0;
        }
      });
      type.damageRelations.halfDamageFrom.forEach((element) {
        if (tempWeakness.containsKey(element.name)) {
          tempWeakness[element.name] = tempWeakness[element.name] * 0.5;
        } else {
          tempWeakness[element.name] = 0.5;
        }
      });
      type.damageRelations.noDamageFrom.forEach((element) {
        if (tempWeakness.containsKey(element.name)) {
          tempWeakness[element.name] = tempWeakness[element.name] * 0;
        } else {
          tempWeakness[element.name] = 0;
        }
      });
    }
    var entries = tempWeakness.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    tempWeakness = Map.fromEntries(entries);
    return tempWeakness;
  }

  Future<List<MyPokemon>> _getEvolutions(PokemonSpecies pkmSpec) async {
    var evoChain = await MyPokeApi.getEvolutionChain(
        id: Utility.getEvolutionChainIdFromUrl(pkmSpec.evolutionChain.url));
    var tempEvolutions = <MyPokemon>[];
    var addEvolution = (Pokemon pkm, int index) {
      tempEvolutions.add(MyPokemon(
        id: pkm.id,
        name: pkm.name,
        speciesId: pkm.id,
        evolutionNo: index,
        allowStats: true,
      ));
      tempEvolutions.sort((a, b) => a.id.value.compareTo(b.id.value));
    };
    var evo = evoChain.chain;
    int evoNo = 1;
    do {
      int numOfEvo = evo.evolvesTo.length;
      int tempEvoNo = evoNo;
      int id = Utility.getPkmSpecIdFromUrl(evo.species.url);
      var pkm = await MyPokeApi.getPokemon(id: id);
      addEvolution(pkm, tempEvoNo);
      evoNo++;
      if (numOfEvo > 1) {
        for (int i = 1; i < numOfEvo; i++) {
          int _tempEvoNo = evoNo;
          int _id = Utility.getPkmSpecIdFromUrl(evo.evolvesTo[i].species.url);
          var _pkm = await MyPokeApi.getPokemon(id: _id);
          addEvolution(_pkm, _tempEvoNo);
        }
      }
      evo = numOfEvo > 0 ? evo.evolvesTo[0] : null;
    } while (evo != null);
    return tempEvolutions;
  }

  Future<List<MyPokemon>> _getAlternativeForms(PokemonSpecies pkmSpec) async {
    var forms = <MyPokemon>[];
    for (int i = 0; i < pkmSpec.varieties.length; i++) {
      var pkm = await MyPokeApi.getPokemon(
          id: Utility.getPkmIdFromUrl(pkmSpec.varieties[i].pokemon.url));
      String art = pkm.sprites.other.officialArtwork.frontDefault;
      if (art != null && art.isNotEmpty) {
        forms.add(MyPokemon(
          id: pkm.id,
          name: pkm.name,
          speciesId: pkmSpec.id,
          allowStats: true,
        ));
        forms.sort((a, b) => a.id.value.compareTo(b.id.value));
      }
    }
    return forms;
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

class PokemonTileController extends GetxController {
  PokemonTileController({MyPokemon pokemon, bool isHideArtwork = false}) {
    this.pokemon.value = pokemon;
    this.isHideArtwork.value = isHideArtwork;
  }

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;

  var isHideArtwork = false.obs;
}

class PokemonCardController extends GetxController {
  PokemonCardController({MyPokemon pokemon}) {
    this.pokemon.value = pokemon;
  }

  var pokemon = MyPokemon(id: 0, name: "", speciesId: 0).obs;
}
