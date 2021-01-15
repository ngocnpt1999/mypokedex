import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/controller.dart';
import 'package:mypokedex/controller/search.dart';
import 'package:mypokedex/pokemon_detail.dart';
import 'package:pokeapi_dart/pokeapi_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyPokedex',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Pokedex'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final ListPokemonController _listPokemonController = ListPokemonController();

  @override
  Widget build(BuildContext context) {
    _fetchData(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: Image.asset("assets/icons/icon.png"),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                showSearch(
                  context: context,
                  delegate: SearchPokemon(prefs),
                );
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_listPokemonController.pokemons.length == 0) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scrollbar(
          child: ListView.separated(
            controller: _listPokemonController.scrollController,
            itemCount: _listPokemonController.pokemons.length + 1,
            itemBuilder: _buildPokemonTile,
            separatorBuilder: (context, index) => Divider(),
          ),
        );
      }),
    );
  }

  Widget _buildPokemonTile(BuildContext context, int index) {
    if (index == _listPokemonController.pokemons.length) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(5.0),
        child: CircularProgressIndicator(),
      );
    }
    var pokemon = _listPokemonController.pokemons[index];
    var types = pokemon.types;
    List<Widget> typeWidgets = List();
    types.forEach((value) => typeWidgets.addAll([
          Image.asset(
            "assets/images/" + value.type.name + ".png",
            height: 25.0,
            fit: BoxFit.fitHeight,
          ),
          Container(
            width: 3.0,
          ),
        ]));
    return ListTile(
      onTap: () {
        Get.to(PokemonDetailPage(id: pokemon.id));
      },
      leading: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: pokemon.artwork,
        imageCacheWidth: 150,
        imageCacheHeight: 150,
        height: 65.0,
        fit: BoxFit.fitHeight,
      ),
      title: Text(
        pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
      ),
      subtitle: Text(
        "#" + pokemon.id.toString(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: typeWidgets,
      ),
    );
  }

  void _fetchData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("pokedex")) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text(
                      "Fetching data...",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
      var _api = PokeApi();
      List<String> pokeNames = List();
      _api.pokemon.getPage(offset: 0, limit: 807).then((response) {
        response.results.forEach((value) {
          pokeNames.add(value.name);
        });
        prefs.setStringList("pokedex", pokeNames).whenComplete(() {
          Navigator.pop(context);
          _listPokemonController.getNewPokemons();
        });
      });
    } else {
      _listPokemonController.getNewPokemons();
    }
  }
}
