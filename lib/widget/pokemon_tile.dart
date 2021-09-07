import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/extension/utility.dart';
import 'package:mypokedex/model/pokemon_type_colors.dart';
import 'package:mypokedex/widget/pokemon_artwork.dart';
import 'package:mypokedex/extension/stringx.dart';
import 'package:shimmer/shimmer.dart';

class PokemonTile extends StatelessWidget {
  PokemonTile({this.controller, this.onTap});

  final PokemonTileController controller;

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var pokemon = controller.pokemon.value;
      if (!pokemon.hasStats) {
        return Shimmer.fromColors(
          child: Padding(
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            child: Card(
              elevation: 3.0,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Container(height: Get.width / 5),
              ),
            ),
          ),
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
        );
      }
      var types = pokemon.types;
      List<Widget> typeWidgets = [];
      types.forEach((value) => typeWidgets.addAll([
            Image.asset(
              "assets/images/" + value.type.name + ".png",
              height: 25.0,
              width: 25.0,
              fit: BoxFit.contain,
            ),
            Container(width: 3.0),
          ]));
      return Padding(
        padding: EdgeInsets.only(left: 5.0, right: 5.0),
        child: Card(
          elevation: 3.0,
          color: Color(PokemonTypeColors.colors[pokemon.types[0].type.name])
              .withOpacity(0.7),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      controller.isHideArtwork.value =
                          !controller.isHideArtwork.value;
                    },
                    child: PokemonArtwork(
                      image: pokemon.artwork.value,
                      imageCacheWidth: 150,
                      imageCacheHeight: 150,
                      width: Get.width / 5,
                      height: Get.width / 5,
                      isHideArtwork: controller.isHideArtwork.value,
                    ),
                  ),
                  Container(
                    width: 3.0,
                  ),
                  Expanded(
                    flex: 3,
                    child: ListTile(
                      title: Text(
                        pokemon.name.value.capitalizeFirstofEach,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text(Utility.getPokedexNo(pokemon.speciesId.value)),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: typeWidgets,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
