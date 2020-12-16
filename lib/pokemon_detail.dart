import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/controller.dart';
import 'package:transparent_image/transparent_image.dart';

class PokemonDetailPage extends StatelessWidget {
  PokemonDetailPage(int id) {
    _pageController.getEvolutionData(id);
  }

  final PokemonDetailController _pageController = PokemonDetailController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        List<Widget> form1 = List();
        List<Widget> form2 = List();
        List<Widget> form3 = List();
        _pageController.evolutions.forEach((pokemon) {
          var widget = FadeInImage.memoryNetwork(
            image: pokemon.artwork,
            placeholder: kTransparentImage,
            width: 50,
            fit: BoxFit.fitWidth,
          );
          if (pokemon.evoForm == 1) {
            form1.add(widget);
          } else if (pokemon.evoForm == 2) {
            form2.add(widget);
          } else {
            form3.add(widget);
          }
        });
        return Row(
          children: <Widget>[
            Column(children: form1),
            Column(children: form2),
            Column(children: form3),
          ],
        );
      }),
    );
  }
}
