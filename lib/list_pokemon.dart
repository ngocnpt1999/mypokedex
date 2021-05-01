import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/widget/pokemon_tile.dart';

class ListPokemonPage extends StatelessWidget {
  ListPokemonPage();

  final _pageController = Get.put(ListPokemonController());

  @override
  Widget build(BuildContext context) {
    if (!_pageController.isRun) {
      _pageController.isRun = true;
      _fetchData();
    }
    return Obx(() {
      if (_pageController.pkmTileControllers.length == 0) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Scrollbar(
        child: ListView.builder(
          controller: _pageController.scrollController,
          itemCount: _pageController.pkmTileControllers.length + 1,
          itemBuilder: _buildPokemonTile,
        ),
      );
    });
  }

  Widget _buildPokemonTile(BuildContext context, int index) {
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
