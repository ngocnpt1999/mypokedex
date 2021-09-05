import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/extension/utility.dart';
import 'package:mypokedex/page/pokemon_detail.dart';
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
    List<String> listPkm = [];
    _getSuggestions(listPkm);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: listPkm.length,
      itemBuilder: (context, index) {
        var jsonPkm = jsonDecode(listPkm[index]) as Map<String, dynamic>;
        return ListTile(
          onTap: () async {
            if (!_recents.contains(listPkm[index])) {
              _recents.insert(0, listPkm[index]);
              if (_recents.length > _max) {
                _recents.removeLast();
              }
            } else {
              _recents.remove(listPkm[index]);
              _recents.insert(0, listPkm[index]);
            }
            await SharedPrefs.instance.setRecentSearch(_recents);
            Get.back();
            Get.to(() => PokemonDetailPage(name: jsonPkm["name"].toString()))
                .then((value) {
              ListFavoritePokemonController controller = Get.find();
              controller.refresh();
            });
          },
          leading: query.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.history_rounded),
                  ],
                )
              : null,
          title: Text(jsonPkm["name"].toString().capitalizeFirstofEach),
          subtitle: Text(Utility.getPokedexNo(jsonPkm["speciesId"] as int)),
          trailing: query.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.north_west_rounded),
                  ],
                )
              : null,
        );
      },
    );
  }

  void _getSuggestions(List<String> listPkm) {
    if (query.isEmpty) {
      listPkm.addAll(_recents);
    } else {
      String keyword = query.trim().toLowerCase();
      if (keyword.length > 1 && keyword[0] == "#") {
        int num = int.tryParse(keyword.substring(1));
        if (num != null) {
          var jsonPkm = SharedPrefs.instance.getPokedex().firstWhere((element) {
            var value = jsonDecode(element) as Map<String, dynamic>;
            return num == (value["id"] as int);
          }, orElse: () => null);
          if (jsonPkm != null) {
            listPkm.add(jsonPkm);
          }
        }
      } else {
        var jsonPkms = SharedPrefs.instance.getPokedex().where((element) {
          var value = jsonDecode(element) as Map<String, dynamic>;
          return value["name"].toString().startsWith(query.toLowerCase());
        }).take(_max);
        jsonPkms.forEach((element) {
          listPkm.add(element);
        });
      }
    }
  }
}
