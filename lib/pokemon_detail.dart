import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/controller.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:transparent_image/transparent_image.dart';

class PokemonDetailPage extends StatelessWidget {
  PokemonDetailPage({int id, String name}) {
    _pageController.getPokemonData(id: id, name: name);
    _pageController.getEvolutionData(id: id, name: name);
  }

  final PokemonDetailController _pageController = PokemonDetailController();

  @override
  Widget build(BuildContext context) {
    Widget pokeBar = _buildPokeBar(context);
    Widget specCard = _buildPokeSpecies();
    Widget abiCard = _buildPokeAbilities();
    Widget evoCard = _buildEvoChain();
    return Scaffold(
      backgroundColor: Color(0xFFF88379),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            pokeBar,
            Expanded(
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    specCard,
                    abiCard,
                    evoCard,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pokemonCard(MyPokemon pokemon) {
    var types = pokemon.types;
    List<Widget> typeWidgets = List();
    types.forEach((value) => typeWidgets.addAll([
          Image.asset(
            "assets/images/" + value.type.name + ".png",
            width: 15.0,
            fit: BoxFit.fitWidth,
          ),
          Container(
            width: 2.0,
          ),
        ]));
    var rowTypes = Row(
      children: typeWidgets,
    );
    return Card(
      elevation: 3.0,
      child: InkWell(
        onTap: () {
          Get.back();
          Get.to(PokemonDetailPage(
            id: pokemon.id,
          ));
        },
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
      ),
    );
  }

  Widget _buildPokeBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      child: Card(
        elevation: 4.0,
        child: Obx(() {
          var pokemon = _pageController.pokemon.value;
          if (pokemon.id == null ||
              pokemon.name == null ||
              pokemon.artwork == null ||
              pokemon.types == null) {
            return Center(
              child: CircularProgressIndicator(),
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
                                  width: 30.0,
                                  height: 30.0,
                                  fit: BoxFit.fitWidth,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      value.type.name[0].toUpperCase() +
                                          value.type.name.substring(1),
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
            return Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                pokemon.name[0].toUpperCase() +
                                    pokemon.name.substring(1),
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "#" + pokemon.id.toString(),
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                        Container(
                          height: 5.0,
                        ),
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
                  fit: BoxFit.contain,
                ),
              ],
            );
          }
        }),
      ),
    );
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
        Card(
          elevation: 4.0,
          color: Color(0xFFB6B49C),
          child: Obx(() {
            var pokemon = _pageController.pokemon.value;
            if (pokemon.height == null ||
                pokemon.weight == null ||
                pokemon.entry == null) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
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
        Card(
          elevation: 4.0,
          color: Color(0xFFB6B49C),
          child: Obx(() {
            var pokemon = _pageController.pokemon.value;
            if (pokemon.abilities == null) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
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
                            value.ability.name[0].toUpperCase() +
                                value.ability.name.substring(1),
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

  Widget _buildEvoChain() {
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
        Card(
          elevation: 4.0,
          color: Color(0xFFB6B49C),
          child: Obx(() {
            var evolutions = _pageController.evolutions;
            if (evolutions == null || evolutions.length == 0) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              List<Widget> evoForms_1 = List();
              List<Widget> evoForms_2 = List();
              List<Widget> evoForms_3 = List();
              evolutions.forEach((pokemon) {
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
              return Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: evoWidgets,
                ),
              );
            }
          }),
        ),
      ],
    );
  }
}
