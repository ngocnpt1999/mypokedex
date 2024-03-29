import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:get/get.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/extension/utility.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/pokemon_type_colors.dart';
import 'package:mypokedex/page/pokemon_ability_detail.dart';
import 'package:mypokedex/widget/pokemon_artwork.dart';
import 'package:mypokedex/extension/stringx.dart';
import 'package:mypokedex/widget/pokemon_card.dart';
import 'package:random_string/random_string.dart';

class PokemonDetailPage extends StatelessWidget {
  PokemonDetailPage({MyPokemon pokemon}) {
    _pageController.load(pokemon: pokemon);
  }

  PokemonDetailPage.fromIdOrName({int id, String name}) {
    _pageController.loadByIdOrName(id: id, name: name);
  }

  final PokemonDetailController _pageController = Get.find();

  @override
  Widget build(BuildContext context) {
    Widget spacer = Container(height: 8.0);
    Widget pokemonBar = _buildPokeBar();
    Widget speciesCard = _buildWidget(
      header: "Species",
      content: _pokemonSpecies(),
    );
    Widget statsCard = _buildWidget(
      header: "Base Stats",
      content: _pokemonStats(context),
    );
    Widget weaknessCard = _buildWidget(
      header: "Weakness",
      content: _pokemonWeakness(),
    );
    Widget abilitiesCard = _buildWidget(
      header: "Abilities",
      content: _pokemonAbilities(context),
    );
    Widget evolutionsCard = _buildWidget(
      header: "Evolutions",
      content: _evolutionChain(),
    );
    Widget alternativeFormsCard = _buildWidget(
      header: "Alternative forms",
      content: _alternativeForms(),
    );
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFFF88379),
        body: HawkFabMenu(
          icon: AnimatedIcons.menu_close,
          items: <HawkFabMenuItem>[
            HawkFabMenuItem(
              ontap: () {
                int specId = _pageController.pokemon.value.speciesId.value;
                if (specId > 1) {
                  _pageController.loadByIdOrName(id: specId - 1);
                }
              },
              icon: Icon(Icons.arrow_back_rounded),
              label: " Previous Pokemon ",
            ),
            HawkFabMenuItem(
              ontap: () {
                int specId = _pageController.pokemon.value.speciesId.value;
                if (specId < 809) {
                  _pageController.loadByIdOrName(id: specId + 1);
                }
              },
              icon: Icon(Icons.arrow_forward_rounded),
              label: " Next Pokemon ",
            ),
            HawkFabMenuItem(
              ontap: () {
                Future.delayed(Duration(milliseconds: 500)).then((value) {
                  ListFavoritePokemonController controller = Get.find();
                  controller.refresh();
                  Get.back();
                });
              },
              icon: Icon(Icons.close_rounded),
              label: " Return Home ",
            ),
          ],
          body: SafeArea(
            child: Column(
              children: <Widget>[
                pokemonBar,
                Expanded(
                  child: Scrollbar(
                    child: ListView(
                      controller: _pageController.scrollController,
                      shrinkWrap: true,
                      children: <Widget>[
                        spacer,
                        speciesCard,
                        spacer,
                        statsCard,
                        spacer,
                        weaknessCard,
                        spacer,
                        abilitiesCard,
                        spacer,
                        evolutionsCard,
                        spacer,
                        alternativeFormsCard,
                        spacer,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        ListFavoritePokemonController controller = Get.find();
        controller.refresh();
        return true;
      },
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

  Widget _genderWidget(int genderRate) {
    double txtSize = 15.0;
    double iconSize = 16.0;
    if (genderRate == -1) {
      return Text(
        "Unknown",
        style: TextStyle(fontSize: txtSize),
      );
    } else if (genderRate == 0) {
      return Icon(
        MdiIcons.genderMale,
        size: iconSize,
      );
    } else if (genderRate == 8) {
      return Icon(
        MdiIcons.genderFemale,
        size: iconSize,
      );
    } else {
      return Row(
        children: <Widget>[
          Icon(
            MdiIcons.genderMale,
            size: iconSize,
          ),
          Icon(
            MdiIcons.genderFemale,
            size: iconSize,
          ),
        ],
      );
    }
  }

  Widget _buildPokeBar() {
    return Obx(() {
      var pokemon = _pageController.pokemon.value;
      if (!pokemon.hasStats) {
        return Card(
          elevation: 4.0,
          child: _circularProgressIndicator(),
        );
      } else {
        List<Widget> typeWidgets = [];
        pokemon.types.forEach((value) => typeWidgets.add(
              Expanded(
                child: Card(
                  elevation: 3.0,
                  color: Color(PokemonTypeColors.colors[value.type.name]),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      value.type.name.capitalizeFirstofEach.toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                if (pokemon.isFavorite.value) {
                                  pokemon.dislike();
                                } else {
                                  pokemon.like();
                                }
                              },
                              child: Icon(
                                Icons.star_rounded,
                                color: pokemon.isFavorite.value
                                    ? Colors.yellow
                                    : Color(0xFFD3D3D3),
                              ),
                            ),
                            Container(width: 5.0),
                            Expanded(
                              child: Text(
                                pokemon.name.value.capitalizeFirstofEach,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              Utility.getPokedexNo(pokemon.speciesId.value),
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 8.0),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                pokemon.genus.value,
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ),
                            _genderWidget(pokemon.genderRate.value),
                          ],
                        ),
                      ),
                      Container(height: 8.0),
                      Row(
                        children: typeWidgets,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _pageController.isHideArtwork.value =
                      !_pageController.isHideArtwork.value;
                },
                child: PokemonArtwork(
                  image: pokemon.artwork.value,
                  width: Get.height / 5,
                  height: Get.height / 5,
                  isHideArtwork: _pageController.isHideArtwork.value,
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildWidget({String header, Widget content}) {
    return Column(
      children: <Widget>[
        Text(
          header,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(height: 5.0),
        Card(
          elevation: 4.0,
          color: Color(0xFFD3D3D3),
          child: content,
        ),
      ],
    );
  }

  Widget _pokemonSpecies() {
    return Obx(() {
      var pokemon = _pageController.pokemon.value;
      if (!pokemon.hasStats) {
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
                                    pokemon.entry.value,
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
                          style: TextStyle(fontSize: 12.0),
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
                                    (pokemon.weight.value / 10.0).toString() +
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
                          style: TextStyle(fontSize: 12.0),
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
                                    (pokemon.height.value / 10.0).toString() +
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
                          style: TextStyle(fontSize: 12.0),
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
    });
  }

  Widget _pokemonStats(BuildContext context) {
    return Obx(() {
      var pokemon = _pageController.pokemon.value;
      if (!pokemon.hasStats) {
        return _circularProgressIndicator();
      } else {
        var typeColor =
            Color(PokemonTypeColors.colors[pokemon.types[0].type.name]);
        var typeDarkenColor = Utility.darken(typeColor, 0.4);
        var pressColor = Utility.darken(typeColor, 0.2);
        Map<String, int> statsMap = {
          "HP": pokemon.baseHP.value,
          "Attack": pokemon.baseAtk.value,
          "Defense": pokemon.baseDef.value,
          "Sp. Atk": pokemon.baseSpAtk.value,
          "Sp. Def": pokemon.baseSpDef.value,
          "Speed": pokemon.baseSpeed.value,
        };
        int total = 0;
        statsMap.forEach((key, value) => total += value);
        Widget footer = RichText(
          text: TextSpan(
            text: "TOTAL ",
            style: TextStyle(fontSize: 16.0),
            children: [
              TextSpan(
                text: "$total",
                style: TextStyle(
                  color: typeDarkenColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
        int iv;
        int ev;
        double nature;
        if (_pageController.activeMinStat.value ||
            _pageController.activeMaxStat.value) {
          if (_pageController.activeMinStat.value) {
            footer = Text(
              "Minimum values are based on a level 100 Pokémon, a hindering nature, 0 EVs, 0 IVs",
              style: TextStyle(fontSize: 12.0),
            );
            iv = 0;
            ev = 0;
            nature = 0.9;
          } else {
            footer = Text(
              "Maximum values are based on a level 100 Pokémon, a beneficial nature, 252 EVs, 31 IVs",
              style: TextStyle(fontSize: 12.0),
            );
            iv = 31;
            ev = 63;
            nature = 1.1;
          }
          statsMap.forEach((key, value) {
            if (key == "HP") {
              statsMap[key] = value * 2 + 110 + iv + ev;
            } else {
              statsMap[key] = ((value * 2 + 5 + iv + ev) * nature).floor();
            }
          });
        }
        var stats = statsMap.entries.toList();
        int highestStat = stats
            .reduce(
                (current, next) => current.value > next.value ? current : next)
            .value;
        String randomKey = randomString(10);
        return Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Card(
                      elevation: 3.0,
                      color: _pageController.activeBaseStat.value
                          ? pressColor
                          : typeColor,
                      child: InkWell(
                        onTap: () {
                          _pageController.activeBaseStat.value = true;
                          _pageController.activeMinStat.value = false;
                          _pageController.activeMaxStat.value = false;
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Base Stats",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: _pageController.activeBaseStat.value
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 10.0),
                  Expanded(
                    child: Card(
                      elevation: 3.0,
                      color: _pageController.activeMinStat.value
                          ? pressColor
                          : typeColor,
                      child: InkWell(
                        onTap: () {
                          _pageController.activeMinStat.value = true;
                          _pageController.activeBaseStat.value = false;
                          _pageController.activeMaxStat.value = false;
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Min",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: _pageController.activeMinStat.value
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 10.0),
                  Expanded(
                    child: Card(
                      elevation: 3.0,
                      color: _pageController.activeMaxStat.value
                          ? pressColor
                          : typeColor,
                      child: InkWell(
                        onTap: () {
                          _pageController.activeMaxStat.value = true;
                          _pageController.activeMinStat.value = false;
                          _pageController.activeBaseStat.value = false;
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Max",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: _pageController.activeMaxStat.value
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 15.0),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                itemBuilder: (context, index) => Row(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: <Widget>[
                          FAProgressBar(
                            key: ValueKey(randomKey + index.toString()),
                            displayText: "",
                            currentValue: stats[index].value,
                            maxValue: highestStat,
                            progressColor: typeColor,
                            animatedDuration: Duration(milliseconds: 500),
                            displayTextStyle: TextStyle(
                              color: typeDarkenColor,
                              fontSize: 14.0,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text(
                                  stats[index].key,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Container(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                separatorBuilder: (context, index) => Container(height: 8.0),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                  child: footer,
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _pokemonWeakness() {
    return Obx(() {
      var weakness = _pageController.weakness;
      if (weakness.length == 0) {
        return _circularProgressIndicator();
      } else {
        var typeWidgets = <Widget>[];
        weakness.forEach((key, value) {
          if (value >= 2) {
            typeWidgets.add(Container(
              width: Get.width / 2.2,
              child: Tooltip(
                message: "Deals $value" + "x damage",
                child: Card(
                  elevation: 3.0,
                  color: Color(PokemonTypeColors.colors[key]),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(5.0, 8.0, 5.0, 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Container()),
                        Text(
                          key.capitalizeFirstofEach.toUpperCase(),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(
                          child: Text(
                            value.toString() + "x",
                            textAlign: TextAlign.end,
                            style: TextStyle(fontSize: 11.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
          }
        });
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: typeWidgets,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _pokemonAbilities(BuildContext context) {
    return Obx(() {
      var pokemon = _pageController.pokemon.value;
      if (!pokemon.hasStats) {
        return _circularProgressIndicator();
      } else {
        var typeColor =
            Color(PokemonTypeColors.colors[pokemon.types[0].type.name]);
        var abilities = pokemon.abilities;
        List<Widget> abilityCards = [];
        abilities.forEach((value) {
          Widget widget = Row(
            children: <Widget>[
              Expanded(
                child: Card(
                  elevation: 3.0,
                  color: typeColor,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => PokemonAbilityDetail(
                            name: value.ability.name,
                            title: value.ability.name,
                            subtitle: pokemon.name + "'s ability",
                          ));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: value.isHidden
                                ? Text(
                                    "Hidden",
                                    style: TextStyle(fontSize: 12.0),
                                  )
                                : Container(),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              value.ability.name.capitalizeFirstofEach,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.info_outline_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
          abilityCards.add(widget);
        });
        return Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: abilityCards,
          ),
        );
      }
    });
  }

  void _divideEvolutionNoRows(List<Widget> evoNo) {
    List<Widget> tempWidgets = [];
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

  Widget _evolutionChain() {
    return Obx(() {
      var evolutions = _pageController.evolutions;
      if (evolutions.length == 0) {
        return _circularProgressIndicator();
      } else {
        List<Widget> evoNo_1 = [];
        List<Widget> evoNo_2 = [];
        List<Widget> evoNo_3 = [];
        evolutions.forEach((pokemon) {
          var pkmCard = PokemonCard(
            controller: PokemonCardController(pokemon: pokemon),
            imgSize: Get.width / 5,
          );
          if (pokemon.evolutionNo == 1) {
            evoNo_1.add(pkmCard);
          } else if (pokemon.evolutionNo == 2) {
            evoNo_2.add(pkmCard);
          } else {
            evoNo_3.add(pkmCard);
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
          size: 26.0,
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
    });
  }

  Widget _alternativeForms() {
    return Obx(() {
      var forms = _pageController.alternativeForms;
      if (forms.length == 0) {
        return _circularProgressIndicator();
      } else {
        var formWidgets = <Widget>[];
        forms.forEach((pokemon) {
          formWidgets.add(PokemonCard(
            controller: PokemonCardController(pokemon: pokemon),
            imgSize: Get.width / 3.5,
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
    });
  }
}
