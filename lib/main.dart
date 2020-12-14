import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/controller.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
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
    _listPokemonController.getNewPokemons();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Obx(() => ListView.separated(
            itemCount: _listPokemonController.pokemons.length,
            itemBuilder: _buildPokemonTile,
            separatorBuilder: (context, index) => Divider(),
          )),
    );
  }

  Widget _buildPokemonTile(BuildContext context, int index) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 5.0),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: _listPokemonController
                  .pokemons[index].sprites.other.officialArtwork.frontDefault,
              width: 60,
              fit: BoxFit.fitWidth,
            ),
          ),
          Container(
            width: 5.0,
          ),
          Expanded(
            flex: 5,
            child: Text(
              "#" +
                  _listPokemonController.pokemons[index].id.toString() +
                  " - " +
                  _listPokemonController.pokemons[index].name[0].toUpperCase() +
                  _listPokemonController.pokemons[index].name.substring(1),
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Expanded(
            flex: 2,
            child: Obx(() {
              var types = _listPokemonController.pokemons[index].types;
              List<Widget> widgets = List();
              types.forEach((value) => widgets.addAll([
                    Image.asset(
                      "assets/images/" + value.type.name + ".png",
                      width: 30.0,
                      fit: BoxFit.fitWidth,
                    ),
                    Container(
                      width: 3.0,
                    ),
                  ]));
              return Row(
                children: widgets,
              );
            }),
          ),
        ],
      ),
    );
  }
}
