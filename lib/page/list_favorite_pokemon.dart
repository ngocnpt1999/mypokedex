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
    if (!_pageController.isRunning) {
      _pageController.isRunning = true;
      _pageController.loadMore();
    }
    return Obx(() {
      if (_pageController.hasFavorites.value == false) {
        return Center(
          child: Text("No results"),
        );
      } else {
        if (_pageController.pkmTileControllers.length == 0) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scrollbar(
          child: ListView.builder(
            controller: _pageController.scrollController,
            itemCount: _pageController.pkmTileControllers.length + 1,
            itemBuilder: _buildFavoritePokemonTile,
          ),
        );
      }
    });
  }

  Widget _buildFavoritePokemonTile(BuildContext context, int index) {
    if (index == _pageController.pkmTileControllers.length) {
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
        tileController: _pageController.pkmTileControllers[index],
        onTap: () {
          var pokemon = _pageController.pkmTileControllers[index].pokemon.value;
          Get.to(() => PokemonDetailPage(id: pokemon.id)).then((value) {
            ListFavoritePokemonController controller = Get.find();
            controller.refresh();
          });
        },
      );
    }
  }
}
