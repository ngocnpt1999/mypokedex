import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/model/typecolors.dart';
import 'package:mypokedex/pokemon_detail.dart';
import 'package:mypokedex/widget/pokemon_artwork.dart';
import 'package:mypokedex/extension/stringx.dart';

class PokemonTile extends StatelessWidget {
  PokemonTile({this.tileController});

  final PokemonTileController tileController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var pokemon = tileController.pokemon.value;
      var types = pokemon.types;
      List<Widget> typeWidgets = [];
      types.forEach((value) => typeWidgets.addAll([
            Image.asset(
              "assets/images/" + value.type.name + ".png",
              height: 25.0,
              width: 25.0,
              fit: BoxFit.contain,
            ),
            Container(
              width: 3.0,
            ),
          ]));
      return Padding(
        padding: EdgeInsets.only(
          left: 5.0,
          right: 5.0,
        ),
        child: Card(
          elevation: 3.0,
          color: Color(PokemonTypeColors.colors[pokemon.types[0].type.name])
              .withOpacity(0.7),
          child: InkWell(
            onTap: () {
              Get.to(() => PokemonDetailPage(id: pokemon.id)).then((value) {
                ListFavoritePokemonController controller = Get.find();
                controller.refresh();
              });
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      tileController.isHideArtwork.value =
                          !tileController.isHideArtwork.value;
                    },
                    child: PokemonArtwork(
                      image: pokemon.artwork,
                      imageCacheWidth: 150,
                      imageCacheHeight: 150,
                      width: Get.width / 5,
                      height: Get.width / 5,
                      isHideArtwork: tileController.isHideArtwork.value,
                    ),
                  ),
                  Container(
                    width: 3.0,
                  ),
                  Expanded(
                    flex: 3,
                    child: ListTile(
                      title: Text(
                        pokemon.name.capitalizeFirstofEach,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(pokemon.getPokedexNo()),
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
