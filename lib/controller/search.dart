import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/pokemon_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPokemon extends SearchDelegate {
  SearchPokemon(this.prefs);

  final SharedPreferences prefs;

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> pokeNames = List();
    _getSuggestions(pokeNames);
    return ListView.separated(
      itemCount: pokeNames.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          Navigator.pop(context);
          Get.to(PokemonDetailPage(name: pokeNames[index]));
        },
        title: Text(
          pokeNames[index][0].toUpperCase() + pokeNames[index].substring(1),
        ),
      ),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  void _getSuggestions(List<String> pokeNames) {
    if (query.isEmpty) {
    } else {
      pokeNames.addAll(prefs
          .getStringList("pokedex")
          .where((e) => e.startsWith(query.toLowerCase()))
          .take(20));
    }
  }
}
