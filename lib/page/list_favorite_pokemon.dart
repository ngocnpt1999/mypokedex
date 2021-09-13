import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/page/pokemon_detail.dart';
import 'package:mypokedex/widget/pokemon_tile.dart';

class ListFavoritePokemonPage extends StatelessWidget {
  ListFavoritePokemonPage();

  final ListFavoritePokemonController _pageController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (!_pageController.hasData) {
      _pageController.loadMore();
    }
    return RefreshIndicator(
      child: Obx(() {
        var tileControllers = _pageController.pkmTileControllers;
        if (!_pageController.hasFavorites && tileControllers.length == 0) {
          return Center(
            child: Text("No results"),
          );
        } else {
          if (tileControllers.length == 0) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Scrollbar(
            child: ListView.builder(
              controller: _pageController.scrollController,
              itemCount: tileControllers.length + 1,
              itemBuilder: _buildFavoritePokemonTile,
            ),
          );
        }
      }),
      onRefresh: () async {
        _pageController.refresh();
      },
    );
  }

  Widget _buildFavoritePokemonTile(BuildContext context, int index) {
    var tileControllers = _pageController.pkmTileControllers;
    if (index == tileControllers.length) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 10.0,
          bottom: 8.0,
        ),
        child: _pageController.endOfData()
            ? Container()
            : CircularProgressIndicator(),
      );
    } else {
      return PokemonTile(
        controller: tileControllers[index],
        onTap: () {
          var pokemon = tileControllers[index].pokemon.value;
          Get.to(() => PokemonDetailPage(pokemon: pokemon));
        },
      );
    }
  }
}
