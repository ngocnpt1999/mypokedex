import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/model/typecolors.dart';
import 'package:mypokedex/pokemon_detail.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:mypokedex/extension/stringx.dart';

class ListFavoritePokemonPage extends StatelessWidget {
  ListFavoritePokemonPage();

  final ListFavoritePokemonController _pageController =
      ListFavoritePokemonController();

  @override
  Widget build(BuildContext context) {
    if (_pageController.favoritePokemons.length == 0) {
      _pageController.getNewFavoritePokemons();
    }
    return Obx(() {
      if (_pageController.favoritePokemons.length == 0 &&
          SharedPrefs.instance.getFavoritesPokemon().length == 0) {
        return Center(
          child: Text("No results"),
        );
      }
      if (_pageController.favoritePokemons.length == 0) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Scrollbar(
        child: ListView.builder(
          controller: _pageController.scrollController,
          itemCount: _pageController.favoritePokemons.length,
          itemBuilder: _buildFavoritePokemonTile,
        ),
      );
    });
  }

  Widget _buildFavoritePokemonTile(BuildContext context, int index) {
    var pokemon = _pageController.favoritePokemons[index];
    var types = pokemon.types;
    List<Widget> typeWidgets = List();
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
            .withOpacity(0.5),
        child: InkWell(
          onTap: () {
            Get.to(PokemonDetailPage(id: pokemon.id)).then((value) {
              _pageController.refresh();
            });
          },
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: pokemon.artwork,
                  imageCacheWidth: 150,
                  imageCacheHeight: 150,
                  width: Get.width / 5,
                  height: Get.width / 5,
                  fit: BoxFit.contain,
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
  }
}
