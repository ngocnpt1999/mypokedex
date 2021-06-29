import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/model/mypokemon.dart';
import 'package:mypokedex/model/pokemon_type_colors.dart';
import 'package:mypokedex/widget/pokemon_artwork.dart';
import 'package:mypokedex/extension/stringx.dart';

class PokemonCard extends StatelessWidget {
  PokemonCard({
    @required this.pokemon,
    this.imgSize = 70.0,
    this.textNameSize = 12.0,
  });

  final MyPokemon pokemon;
  final double imgSize;
  final double textNameSize;

  @override
  Widget build(BuildContext context) {
    var types = pokemon.types;
    List<Widget> typeWidgets = [];
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
          .withOpacity(0.8),
      child: InkWell(
        onTap: () {
          PokemonDetailController controller = Get.find();
          controller.init(id: pokemon.id);
        },
        child: Container(
          padding: EdgeInsets.all(3.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PokemonArtwork(
                image: pokemon.artwork,
                height: imgSize,
                width: imgSize,
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
}
