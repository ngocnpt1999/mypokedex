import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/pokemon_detail.dart';
import 'package:mypokedex/extension/stringx.dart';

class SearchPokemon extends SearchDelegate {
  SearchPokemon() {
    _recents = SharedPrefs.instance.getRecentSearch();
  }

  List<String> _recents = List();

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
      onPressed: () async {
        await SharedPrefs.instance.setRecentSearch(_recents);
        Get.back();
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
        onTap: () async {
          if (!_recents.contains(pokeNames[index])) {
            _recents.insert(0, pokeNames[index]);
            if (_recents.length > 20) {
              _recents.removeLast();
            }
          } else {
            _recents.remove(pokeNames[index]);
            _recents.insert(0, pokeNames[index]);
          }
          await SharedPrefs.instance.setRecentSearch(_recents);
          Get.back();
          Get.to(() => PokemonDetailPage(name: pokeNames[index]));
        },
        leading: query.isEmpty ? Icon(Icons.history_rounded) : null,
        title: Text(
          pokeNames[index].capitalizeFirstofEach,
        ),
      ),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  void _getSuggestions(List<String> pokeNames) {
    if (query.isEmpty) {
      pokeNames.addAll(_recents);
    } else {
      pokeNames.addAll(SharedPrefs.instance
          .getPokedex()
          .where((e) => e.startsWith(query.toLowerCase()))
          .take(20));
    }
  }
}
