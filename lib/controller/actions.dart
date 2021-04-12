import 'dart:convert';

import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/model/pokemon_generation.dart';
import 'package:mypokedex/model/pokemon_type.dart';

class HomeAction {
  static const String hideAll = "Hide All";
  static const String revealAll = "Reveal All";
  static const List<String> choices = [
    hideAll,
    revealAll,
  ];
}

class ListPokemonFilter {
  static const String ascendingID = "Ascending ID";
  static const String descendingID = "Descending ID";
  static const String alphabetAZ = "Alphabet (A-Z)";
  static const String alphabetZA = "Alphabet (Z-A)";

  static const generations = <String>[
    PokemonGeneration.allGen,
    PokemonGeneration.genI,
    PokemonGeneration.genII,
    PokemonGeneration.genIII,
    PokemonGeneration.genIV,
    PokemonGeneration.genV,
    PokemonGeneration.genVI,
    PokemonGeneration.genVII,
  ];

  static const types = <String>[
    MyPokemonType.allType,
    MyPokemonType.bug,
    MyPokemonType.dark,
    MyPokemonType.dragon,
    MyPokemonType.electric,
    MyPokemonType.fairy,
    MyPokemonType.fighting,
    MyPokemonType.fire,
    MyPokemonType.flying,
    MyPokemonType.ghost,
    MyPokemonType.grass,
    MyPokemonType.ground,
    MyPokemonType.ice,
    MyPokemonType.normal,
    MyPokemonType.poison,
    MyPokemonType.psychic,
    MyPokemonType.rock,
    MyPokemonType.steel,
    MyPokemonType.water,
  ];

  static List<String> filterByGen(List<String> list, String generation) {
    switch (generation) {
      case PokemonGeneration.genI:
        list = list.where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          int id = value["speciesId"] as int;
          return id <= 151;
        }).toList();
        break;
      case PokemonGeneration.genII:
        list = list.where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          int id = value["speciesId"] as int;
          return id > 151 && id <= 251;
        }).toList();
        break;
      case PokemonGeneration.genIII:
        list = list.where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          int id = value["speciesId"] as int;
          return id > 251 && id <= 386;
        }).toList();
        break;
      case PokemonGeneration.genIV:
        list = list.where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          int id = value["speciesId"] as int;
          return id > 386 && id <= 493;
        }).toList();
        break;
      case PokemonGeneration.genV:
        list = list.where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          int id = value["speciesId"] as int;
          return id > 493 && id <= 649;
        }).toList();
        break;
      case PokemonGeneration.genVI:
        list = list.where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          int id = value["speciesId"] as int;
          return id > 649 && id <= 721;
        }).toList();
        break;
      case PokemonGeneration.genVII:
        list = list.where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          int id = value["speciesId"] as int;
          return id > 721 && id <= 809;
        }).toList();
        break;
      default:
        break;
    }
    return list;
  }

  static List<String> filterByType(List<String> list, String typeName) {
    if (typeName != MyPokemonType.allType) {
      var typepkms = SharedPrefs.instance.getTypePokemons(typeName);
      list = list.where((element) {
        var value = jsonDecode(element) as Map<String, dynamic>;
        int id = value["id"] as int;
        return typepkms.contains(id.toString());
      }).toList();
    }
    return list;
  }

  static List<String> filterByIdOrAlphabet(List<String> list, String filter) {
    var func = (String a, String b) {
      var mapA = jsonDecode(a) as Map<String, dynamic>;
      var mapB = jsonDecode(b) as Map<String, dynamic>;
      return (mapA["name"] as String).compareTo(mapB["name"] as String);
    };
    switch (filter) {
      case ListPokemonFilter.descendingID:
        list = list.reversed.toList();
        break;
      case ListPokemonFilter.alphabetAZ:
        list.sort((a, b) => func(a, b));
        break;
      case ListPokemonFilter.alphabetZA:
        list.sort((b, a) => func(a, b));
        break;
      default:
        break;
    }
    return list;
  }

  static void sortPkmTile(
      List<PokemonTileController> controller, String filter) {
    switch (filter) {
      case ascendingID:
        controller.sort((a, b) =>
            a.pokemon.value.speciesId.compareTo(b.pokemon.value.speciesId));
        break;
      case descendingID:
        controller.sort((b, a) =>
            a.pokemon.value.speciesId.compareTo(b.pokemon.value.speciesId));
        break;
      case alphabetAZ:
        controller.sort(
            (a, b) => a.pokemon.value.name.compareTo(b.pokemon.value.name));
        break;
      case alphabetZA:
        controller.sort(
            (b, a) => a.pokemon.value.name.compareTo(b.pokemon.value.name));
        break;
      default:
        break;
    }
  }
}
