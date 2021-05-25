import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/widget/pokemon_tile.dart';
import 'package:mypokedex/extension/stringx.dart';

class PokemonAbilityDetail extends StatelessWidget {
  PokemonAbilityDetail({int id, String name, this.title = ""}) {
    _pageController.init(id: id, name: name);
  }

  final PokemonAbilityDetailController _pageController = Get.find();

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.capitalizeFirstofEach),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Obx(() {
            return _content(
              header: "Description",
              text: _pageController.description.value,
            );
          }),
          Obx(() {
            return _content(
              header: "Effect",
              text: _pageController.effect.value,
            );
          }),
          Obx(() {
            return _content(
              header: "Short Effect",
              text: _pageController.shortEffect.value,
            );
          }),
          _listPokemon(),
        ],
      ),
    );
  }

  Widget _content({String header, String text}) {
    Widget content;
    if (text.isEmpty) {
      content = Container(
        padding: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    } else {
      content = Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Card(
      elevation: 3.0,
      color: Color(0xFFD3D3D3),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    header,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listPokemon() {
    return Obx(() {
      Widget content;
      if (_pageController.pkmTileControllers.length == 0) {
        content = Center(
          child: CircularProgressIndicator(),
        );
      } else {
        content = ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _pageController.pkmTileControllers.length,
            itemBuilder: (context, index) => PokemonTile(
                  tileController: _pageController.pkmTileControllers[index],
                  onTap: () {
                    var pokemon =
                        _pageController.pkmTileControllers[index].pokemon.value;
                    Get.back();
                    PokemonDetailController controller = Get.find();
                    controller.init(id: pokemon.id);
                  },
                ));
      }
      return Column(
        children: <Widget>[
          Container(height: 5.0),
          Text(
            "Pokemon with Ability",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(height: 8.0),
          content,
          Container(height: 5.0),
        ],
      );
    });
  }
}
