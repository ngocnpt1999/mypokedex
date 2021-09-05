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

  void init({int id, String name}) async {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels > 0) {
        scrollController.jumpTo(0);
      }
    }
    pokemon.value = MyPokemon(id: 0, name: "", speciesId: 0);
    weakness.clear();
    evolutions.clear();
    alternativeForms.clear();
    activeBaseStat.value = true;
    activeMinStat.value = false;
    activeMaxStat.value = false;
    //
    var pkm = await MyPokeApi.getPokemon(id: id, name: name);
    var pkmSpec = await MyPokeApi.getPokemonSpecies(name: pkm.species.name);
    var entries = pkmSpec.flavorTextEntries
        .lastWhere((element) => element.language.name == "en");
    var category =
        pkmSpec.genera.firstWhere((element) => element.language.name == "en");
    pokemon.value = MyPokemon(
      id: pkm.id,
      name: pkm.name,
      speciesId: pkmSpec.id,
      genus: category.genus,
      artwork: pkm.sprites.other.officialArtwork.frontDefault,
      entry: entries.flavorText,
      height: pkm.height,
      weight: pkm.weight,
      types: pkm.types,
      abilities: pkm.abilities,
      genderRate: pkmSpec.genderRate,
      baseHP: pkm.stats[0].baseStat,
      baseAtk: pkm.stats[1].baseStat,
      baseDef: pkm.stats[2].baseStat,
      baseSpAtk: pkm.stats[3].baseStat,
      baseSpDef: pkm.stats[4].baseStat,
      baseSpeed: pkm.stats[5].baseStat,
    );
    weakness.addAll(await _getTypeWeakness(pkm.types));
    evolutions.addAll(await _getEvolutions(pkmSpec));
    alternativeForms.addAll(await _getAlternativeForms(pkmSpec));
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
        id: Utility.getEvoChainIdFromUrl(pkmSpec.evolutionChain.url));
    var tempEvolutions = <MyPokemon>[];
    var addEvolution = (Pokemon pkm, int no) {
      tempEvolutions.add(MyPokemon(
        id: pkm.id,
        name: pkm.name,
        speciesId: pkm.id,
        artwork: pkm.sprites.other.officialArtwork.frontDefault,
        types: pkm.types,
        evolutionNo: no,
      ));
      tempEvolutions.sort((a, b) => a.id.compareTo(b.id));
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
      if (art.isNotEmpty) {
        forms.add(MyPokemon(
          id: pkm.id,
          name: pkm.name,
          speciesId: pkmSpec.id,
          artwork: art,
          types: pkm.types,
        ));
        forms.sort((a, b) => a.id.compareTo(b.id));
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
              artwork: pkm.sprites.other.officialArtwork.frontDefault,
              types: pkm.types,
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
              artwork: pkm.sprites.other.officialArtwork.frontDefault,
              types: pkm.types,
            ),
          ));
        }
      });
      hiddenPkmTileControllers.addAll(tempHiddenControllers);
    });
  }
}
