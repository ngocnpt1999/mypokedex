import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/model/typecolors.dart';
import 'package:mypokedex/pokemon_detail.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:mypokedex/extension/stringx.dart';

class ListPokemonPage extends StatelessWidget {
  ListPokemonPage();

  final int _totalPkm = 809;

  final ListPokemonController _pageController = ListPokemonController();

  @override
  Widget build(BuildContext context) {
    _fetchData();
    return Obx(() {
      if (_pageController.pokemons.length == 0) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Scrollbar(
        child: ListView.builder(
          controller: _pageController.scrollController,
          itemCount: _pageController.pokemons.length + 1,
          itemBuilder: _buildPokemonTile,
        ),
      );
    });
  }

  Widget _buildPokemonTile(BuildContext context, int index) {
    if (index == _pageController.pokemons.length) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 10.0,
          bottom: 8.0,
        ),
        child: _pageController.endOfData()
            ? Container()
            : CircularProgressIndicator(),
      );
    }
    var pokemon = _pageController.pokemons[index];
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
            Get.to(() => PokemonDetailPage(id: pokemon.id));
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

  void _fetchData() {
    SharedPrefs.instance.init().then((e) {
      if (SharedPrefs.instance.getPokedex().length == 0) {
        Get.dialog(
          AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Container(
                  height: 5.0,
                ),
                Text(
                  "Fetching data...",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
        var api = PokeApi();
        List<String> pokeNames = List();
        api.pokemon.getPage(offset: 0, limit: _totalPkm).then((response) {
          response.results.forEach((value) {
            pokeNames.add(value.name);
          });
          SharedPrefs.instance.setPokedex(pokeNames).then((e) {
            Get.back();
            _pageController.getNewPokemons();
          });
        });
      } else {
        if (_pageController.pokemons.length == 0) {
          _pageController.getNewPokemons();
        }
      }
    });
  }
}
