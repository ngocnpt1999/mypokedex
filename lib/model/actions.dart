import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';

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

  static void filterSort(
      List<PokemonTileController> controller, String filter) {
    switch (filter) {
      case ascendingID:
        controller
            .sort((a, b) => a.pokemon.value.id.compareTo(b.pokemon.value.id));
        break;
      case descendingID:
        controller
            .sort((b, a) => a.pokemon.value.id.compareTo(b.pokemon.value.id));
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

  static void rxFilterSort(
      RxList<PokemonTileController> controller, String filter) {
    switch (filter) {
      case ascendingID:
        controller
            .sort((a, b) => a.pokemon.value.id.compareTo(b.pokemon.value.id));
        break;
      case descendingID:
        controller
            .sort((b, a) => a.pokemon.value.id.compareTo(b.pokemon.value.id));
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
