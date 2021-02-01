import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypokedex/controller/search.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:mypokedex/model/typecolors.dart';
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
        textTheme: GoogleFonts.latoTextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MyHomePage(title: 'Pokedex'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final int _totalPkm = 807;

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
          style: TextStyle(color: Colors.black87),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black87,
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
          child: ListView.builder(
            controller: _listPokemonController.scrollController,
            itemCount: _listPokemonController.pokemons.length + 1,
            itemBuilder: _buildPokemonTile,
          ),
        );
      }),
    );
  }

  Widget _buildPokemonTile(BuildContext context, int index) {
    if (index == _listPokemonController.pokemons.length) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
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
            width: 25.0,
            fit: BoxFit.contain,
          ),
          Container(
            width: 3.0,
          ),
        ]));
    return Card(
      elevation: 3.0,
      color: Color(PokemonTypeColors.colors[pokemon.types[0].type.name])
          .withOpacity(0.5),
      child: InkWell(
        onTap: () {
          Get.to(PokemonDetailPage(id: pokemon.id));
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
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 5,
                fit: BoxFit.contain,
              ),
              Container(
                width: 3.0,
              ),
              Expanded(
                flex: 3,
                child: ListTile(
                  title: Text(
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
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
                    Container(
                      height: 5.0,
                    ),
                    Text(
                      "Fetching data...",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
      var _api = PokeApi();
      List<String> pokeNames = List();
      _api.pokemon.getPage(offset: 0, limit: _totalPkm).then((response) {
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
