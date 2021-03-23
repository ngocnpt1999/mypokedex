import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/pokemon_detail.dart';
import 'package:mypokedex/extension/stringx.dart';

class SearchPokemon extends SearchDelegate {
  SearchPokemon() {
    _recents = SharedPrefs.instance.getRecentSearch();
  }

  List<String> _recents = [];

  int _max = 30;

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
    List<String> pkmNames = [];
    _getSuggestions(pkmNames);
    return ListView.separated(
      itemCount: pkmNames.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () async {
          if (!_recents.contains(pkmNames[index])) {
            _recents.insert(0, pkmNames[index]);
            if (_recents.length > _max) {
              _recents.removeLast();
            }
          } else {
            _recents.remove(pkmNames[index]);
            _recents.insert(0, pkmNames[index]);
          }
          await SharedPrefs.instance.setRecentSearch(_recents);
          Get.back();
          Get.to(() => PokemonDetailPage(name: pkmNames[index])).then((value) {
            ListFavoritePokemonController controller = Get.find();
            controller.refresh();
          });
        },
        leading: query.isEmpty ? Icon(Icons.history_rounded) : null,
        title: Text(
          pkmNames[index].capitalizeFirstofEach,
        ),
        trailing: query.isEmpty ? Icon(Icons.north_west_rounded) : null,
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
          .take(_max));
    }
  }
}
