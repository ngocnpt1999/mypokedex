import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypokedex/widget/search.dart';

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
      home: MyHomePage(title: 'Pokedex'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final HomeController _pageController = HomeController();

  @override
  Widget build(BuildContext context) {
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
              showSearch(
                context: context,
                delegate: SearchPokemon(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
        currentIndex: _pageController.selectedIndex.value,
        onTap: (index) {
          _pageController.selectedIndex.value = index;
        },
      ),
      body: Obx(() {
        return _pageController.pages[_pageController.selectedIndex.value];
      }),
    );
  }
}
