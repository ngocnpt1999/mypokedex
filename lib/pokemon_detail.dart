import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/controller.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:transparent_image/transparent_image.dart';

class PokemonDetailPage extends StatelessWidget {
  PokemonDetailPage(int id) {
    _pageController.getEvolutionData(id);
  }

  final PokemonDetailController _pageController = PokemonDetailController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF88379),
      appBar: AppBar(),
      body: Obx(() {
        Widget evoExpandable = _buildEvoChainExpandable();
        return Column(
          children: <Widget>[
            evoExpandable,
          ],
        );
      }),
    );
  }

  Widget _pokemonCard(MyPokemon pokemon) {
    var types = pokemon.types;
    List<Widget> typeWidgets = List();
    types.forEach((value) => typeWidgets.add(
          Image.asset(
            "assets/images/" + value.type.name + ".png",
            width: 15.0,
            fit: BoxFit.fitWidth,
          ),
        ));
    var rowTypes = Row(
      children: typeWidgets,
    );
    return Card(
      elevation: 3.0,
      child: Container(
        padding: EdgeInsets.all(3.0),
        child: Column(
          children: <Widget>[
            FadeInImage.memoryNetwork(
              image: pokemon.artwork,
              placeholder: kTransparentImage,
              width: 65.0,
              fit: BoxFit.fitWidth,
            ),
            Text(pokemon.name[0].toUpperCase() + pokemon.name.substring(1)),
            rowTypes,
          ],
        ),
      ),
    );
  }

  Widget _buildEvoChainExpandable() {
    List<Widget> evoForms_1 = List();
    List<Widget> evoForms_2 = List();
    List<Widget> evoForms_3 = List();
    _pageController.evolutions.forEach((pokemon) {
      var pokeCard = _pokemonCard(pokemon);
      if (pokemon.evoForm == 1) {
        evoForms_1.add(pokeCard);
      } else if (pokemon.evoForm == 2) {
        evoForms_2.add(pokeCard);
      } else {
        evoForms_3.add(pokeCard);
      }
    });
    if (evoForms_2.length > 2) {
      List<Widget> tempWidgets = List();
      for (int i = 0; i < evoForms_2.length; i += 2) {
        if (i + 1 < evoForms_2.length) {
          tempWidgets.add(Row(
            children: <Widget>[
              evoForms_2[i],
              evoForms_2[i + 1],
            ],
          ));
        } else {
          tempWidgets.add(Row(
            children: <Widget>[
              evoForms_2[i],
            ],
          ));
        }
      }
      evoForms_2.clear();
      evoForms_2.addAll(tempWidgets);
    }
    if (evoForms_3.length > 2) {
      List<Widget> tempWidgets = List();
      for (int i = 0; i < evoForms_3.length; i += 2) {
        if (i + 1 < evoForms_3.length) {
          tempWidgets.add(Row(
            children: <Widget>[
              evoForms_3[i],
              evoForms_3[i + 1],
            ],
          ));
        } else {
          tempWidgets.add(Row(
            children: <Widget>[
              evoForms_3[i],
            ],
          ));
        }
      }
      evoForms_3.clear();
      evoForms_3.addAll(tempWidgets);
    }
    List<Widget> evoWidgets = [
      Column(children: evoForms_1),
      Column(children: evoForms_2),
      Column(children: evoForms_3),
    ];
    var forwardIcon = Icon(
      Icons.arrow_forward,
      size: 20.0,
    );
    if (evoForms_2.length > 0) {
      evoWidgets.insert(1, forwardIcon);
    }
    if (evoForms_3.length > 0) {
      evoWidgets.insert(evoWidgets.length - 1, forwardIcon);
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4.0,
      color: Color(0xFFB6B49C),
      child: Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: evoWidgets,
        ),
      ),
    );
  }
}
