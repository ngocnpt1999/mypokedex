import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/widget/pokemon_tile.dart';
import 'package:mypokedex/extension/stringx.dart';

class PokemonAbilityDetail extends StatelessWidget {
  PokemonAbilityDetail(
      {int id, String name, this.title = "", this.subtitle = ""}) {
    _pageController.init(id: id, name: name);
  }

  final PokemonAbilityDetailController _pageController = Get.find();

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(
            title.capitalizeFirstofEach,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle.capitalizeFirstofEach,
            style: TextStyle(fontSize: 12.0),
          ),
        ),
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
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Card(
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
      ),
    );
  }

  Widget _listPokemon() {
    return Obx(() {
      Widget content;
      var listPkm = _pageController.isNormalAbility.value
          ? _pageController.normalPkmTileControllers
          : _pageController.hiddenPkmTileControllers;
      if (listPkm.length == 0) {
        content = Center(
          child: CircularProgressIndicator(),
        );
      } else {
        content = ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: listPkm.length,
            itemBuilder: (context, index) => PokemonTile(
                  controller: listPkm[index],
                  onTap: () {
                    var pokemon = listPkm[index].pokemon.value;
                    Get.back();
                    PokemonDetailController controller = Get.find();
                    controller.load(pokemon: pokemon);
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
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Card(
                    color: _pageController.isNormalAbility.value
                        ? Colors.blueGrey
                        : Colors.grey,
                    child: InkWell(
                      onTap: () {
                        _pageController.isNormalAbility.value = true;
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Normal",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: !_pageController.isNormalAbility.value
                        ? Colors.blueGrey
                        : Colors.grey,
                    child: InkWell(
                      onTap: () {
                        _pageController.isNormalAbility.value = false;
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Hidden",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content,
          Container(height: 5.0),
        ],
      );
    });
  }
}
