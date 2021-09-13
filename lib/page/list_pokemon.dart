import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/page/pokemon_detail.dart';
import 'package:mypokedex/widget/pokemon_tile.dart';

class ListPokemonPage extends StatelessWidget {
  ListPokemonPage();

  final ListPokemonController _pageController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (!_pageController.hasData) {
      _fetchData();
    }
    return RefreshIndicator(
      child: Obx(() {
        var tileControllers = _pageController.pkmTileControllers;
        if (tileControllers.length == 0) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scrollbar(
          controller: _pageController.scrollController,
          child: ListView.builder(
            controller: _pageController.scrollController,
            itemCount: tileControllers.length + 1,
            itemBuilder: _buildPokemonTile,
          ),
        );
      }),
      onRefresh: () async {
        _pageController.refresh();
      },
    );
  }

  Widget _buildPokemonTile(BuildContext context, int index) {
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

  void _fetchData() {
    SharedPrefs.instance.clearCache().then((value) {
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Container(
                height: 5.0,
              ),
              Text(
                "Fetching data...",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      SharedPrefs.instance.fetchData().then((value) {
        Get.back();
        _pageController.loadMore();
      });
    });
  }
}
