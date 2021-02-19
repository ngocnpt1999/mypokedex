import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/typecolors.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:mypokedex/extension/stringx.dart';

class PokemonDetailPage extends StatelessWidget {
  PokemonDetailPage({int id, String name}) {
    _pageController.init(id: id, name: name);
  }

  final PokemonDetailController _pageController = PokemonDetailController();

  @override
  Widget build(BuildContext context) {
    Widget pokemonBar = _buildPokeBar();
    Widget speciesCard = _buildPokeSpecies();
    Widget abilitiesCard = _buildPokeAbilities();
    Widget evolutionsCard = _buildEvolutionChain();
    Widget alternativeFormsCard = _buildAlternativeForms();
    return Scaffold(
      backgroundColor: Color(0xFFF88379),
      body: HawkFabMenu(
        icon: AnimatedIcons.menu_close,
        items: <HawkFabMenuItem>[
          HawkFabMenuItem(
            ontap: () {
              int specId = _pageController.pokemon.value.speciesId;
              if (specId != null && specId > 1) {
                _pageController.init(id: specId - 1);
              }
            },
            icon: Icon(Icons.arrow_back_rounded),
            label: "Previous Pokemon",
          ),
          HawkFabMenuItem(
            ontap: () {
              int specId = _pageController.pokemon.value.speciesId;
              if (specId != null) {
                _pageController.init(id: specId + 1);
              }
            },
            icon: Icon(Icons.arrow_forward_rounded),
            label: "Next Pokemon",
          ),
        ],
        body: SafeArea(
          child: Column(
            children: <Widget>[
              pokemonBar,
              Expanded(
                child: Scrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(height: 5.0),
                      speciesCard,
                      Container(height: 5.0),
                      abilitiesCard,
                      Container(height: 5.0),
                      evolutionsCard,
                      Container(height: 5.0),
                      alternativeFormsCard,
                      Container(height: 5.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circularProgressIndicator() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(35.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _pokemonCard(
      {@required MyPokemon pokemon,
      double imgSize = 70.0,
      double textNameSize = 12.0}) {
    var types = pokemon.types;
    List<Widget> typeWidgets = List();
    types.forEach((value) => typeWidgets.addAll([
          Image.asset(
            "assets/images/" + value.type.name + ".png",
            height: imgSize / 5,
            width: imgSize / 5,
            fit: BoxFit.contain,
          ),
          Container(
            width: 2.0,
          ),
        ]));
    var rowTypes = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: typeWidgets,
    );
    return Card(
      elevation: 3.0,
      color: Color(PokemonTypeColors.colors[pokemon.types[0].type.name])
          .withOpacity(0.5),
      child: InkWell(
        onTap: () {
          _pageController.init(id: pokemon.id);
        },
        child: Container(
          padding: EdgeInsets.all(3.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FadeInImage.memoryNetwork(
                image: pokemon.artwork,
                placeholder: kTransparentImage,
                height: imgSize,
                width: imgSize,
                fit: BoxFit.contain,
              ),
              Text(
                pokemon.name.capitalizeFirstofEach,
                style: TextStyle(
                  fontSize: textNameSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(pokemon.getPokedexNo()),
              rowTypes,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPokeBar() {
    return Obx(() {
      var pokemon = _pageController.pokemon.value;
      if (pokemon.id == null) {
        return Card(
          elevation: 4.0,
          child: _circularProgressIndicator(),
        );
      } else {
        List<Widget> typeWidgets = List();
        pokemon.types.forEach((value) => typeWidgets.add(
              Row(
                children: <Widget>[
                  Expanded(
                    child: Card(
                      elevation: 3.0,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              "assets/images/" + value.type.name + ".png",
                              width: 20.0,
                              height: 20.0,
                              fit: BoxFit.contain,
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  value.type.name.capitalizeFirstofEach
                                      .toUpperCase(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
        return Card(
          elevation: 4.0,
          color: Color(PokemonTypeColors.colors[pokemon.types[0].type.name])
              .withOpacity(0.8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              pokemon.name.capitalizeFirstofEach,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            pokemon.getPokedexNo(),
                            textAlign: TextAlign.end,
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                      Container(height: 5.0),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          pokemon.genus,
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                      Container(height: 5.0),
                      Column(
                        children: typeWidgets,
                      ),
                    ],
                  ),
                ),
              ),
              FadeInImage.memoryNetwork(
                image: pokemon.artwork,
                placeholder: kTransparentImage,
                width: Get.height / 5,
                height: Get.height / 5,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildPokeSpecies() {
    return Column(
      children: <Widget>[
        Text(
          "Species",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(height: 5.0),
        Card(
          elevation: 4.0,
          color: Color(0xFFB6B49C),
          child: Obx(() {
            var pokemon = _pageController.pokemon.value;
            if (pokemon.id == null) {
              return _circularProgressIndicator();
            } else {
              return Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Card(
                                      elevation: 3.0,
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          pokemon.entry,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Pokedex entry",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Card(
                                      elevation: 3.0,
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          (pokemon.weight / 10.0).toString() +
                                              " kg",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Weight",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Card(
                                      elevation: 3.0,
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          (pokemon.height / 10.0).toString() +
                                              " m",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Height",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ],
    );
  }

  Widget _buildPokeAbilities() {
    return Column(
      children: <Widget>[
        Text(
          "Abilities",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(height: 5.0),
        Card(
          elevation: 4.0,
          color: Color(0xFFB6B49C),
          child: Obx(() {
            var pokemon = _pageController.pokemon.value;
            if (pokemon.id == null) {
              return _circularProgressIndicator();
            } else {
              var abilities = pokemon.abilities;
              List<Widget> abiCards = List();
              abilities.forEach((value) {
                if (value.isHidden) {
                  return;
                }
                abiCards.add(Row(
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        elevation: 3.0,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            value.ability.name.capitalizeFirstofEach,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
              });
              return Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: abiCards,
                ),
              );
            }
          }),
        ),
      ],
    );
  }

  void _divideEvolutionNoRows(List<Widget> evoNo) {
    List<Widget> tempWidgets = List();
    for (int i = 0; i < evoNo.length; i += 2) {
      if (i + 1 < evoNo.length) {
        tempWidgets.add(Row(
          children: <Widget>[
            evoNo[i],
            evoNo[i + 1],
          ],
        ));
      } else {
        tempWidgets.add(Row(
          children: <Widget>[
            evoNo[i],
          ],
        ));
      }
    }
    evoNo.clear();
    evoNo.addAll(tempWidgets);
  }

  Widget _buildEvolutionChain() {
    return Column(
      children: <Widget>[
        Text(
          "Evolutions",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(height: 5.0),
        Card(
          elevation: 4.0,
          color: Color(0xFFB6B49C),
          child: Obx(() {
            var evolutions = _pageController.evolutions;
            if (evolutions == null || evolutions.length == 0) {
              return _circularProgressIndicator();
            } else {
              List<Widget> evoNo_1 = List();
              List<Widget> evoNo_2 = List();
              List<Widget> evoNo_3 = List();
              evolutions.forEach((pokemon) {
                var pokeCard = _pokemonCard(
                  pokemon: pokemon,
                  imgSize: Get.width / 5,
                );
                if (pokemon.evolutionNo == 1) {
                  evoNo_1.add(pokeCard);
                } else if (pokemon.evolutionNo == 2) {
                  evoNo_2.add(pokeCard);
                } else {
                  evoNo_3.add(pokeCard);
                }
              });
              if (evoNo_2.length > 2) {
                _divideEvolutionNoRows(evoNo_2);
              }
              if (evoNo_3.length > 2) {
                _divideEvolutionNoRows(evoNo_3);
              }
              List<Widget> evoWidgets = [
                Column(children: evoNo_1),
                Column(children: evoNo_2),
                Column(children: evoNo_3),
              ];
              var forwardIcon = Icon(
                Icons.arrow_forward,
                size: 25.0,
              );
              if (evoNo_2.length > 0) {
                evoWidgets.insert(1, forwardIcon);
              }
              if (evoNo_3.length > 0) {
                evoWidgets.insert(evoWidgets.length - 1, forwardIcon);
              }
              return Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: evoWidgets,
                ),
              );
            }
          }),
        ),
      ],
    );
  }

  Widget _buildAlternativeForms() {
    return Column(
      children: <Widget>[
        Text(
          "Alternative forms",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(height: 5.0),
        Card(
          elevation: 4.0,
          color: Color(0xFFB6B49C),
          child: Obx(() {
            var forms = _pageController.alternativeForms;
            if (forms == null || forms.length == 0) {
              return _circularProgressIndicator();
            } else {
              var formWidgets = List<Widget>();
              forms.forEach((pokemon) {
                formWidgets.add(_pokemonCard(
                  pokemon: pokemon,
                  imgSize: Get.width / 3,
                  textNameSize: 15.0,
                ));
              });
              return Padding(
                padding: EdgeInsets.only(
                  top: 15.0,
                  bottom: 15.0,
                  left: 5.0,
                  right: 5.0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: formWidgets,
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ],
    );
  }
}
