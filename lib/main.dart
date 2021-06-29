import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:mypokedex/controller/shared_prefs.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypokedex/extension/actions.dart';
import 'package:mypokedex/model/pokemon_type_colors.dart';
import 'package:mypokedex/widget/search_pokemon.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPrefs.instance.init().whenComplete(() {
    runApp(MyApp());
  });
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

  final HomeController _pageController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(5.0),
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
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case HomeAction.hideAll:
                  _pageController.hideAllArtwork();
                  break;
                case HomeAction.revealAll:
                  _pageController.revealAllArtwork();
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) {
              return HomeAction.choices
                  .map((choice) => PopupMenuItem(
                        child: Text(choice),
                        value: choice,
                      ))
                  .toList();
            },
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
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
            currentIndex: _pageController.selectedTabIndex.value,
            onTap: (index) {
              _pageController.changeTab(index);
            },
          )),
      body: HawkFabMenu(
        icon: AnimatedIcons.menu_arrow,
        items: <HawkFabMenuItem>[
          HawkFabMenuItem(
            label: ListPokemonFilter.ascendingID,
            ontap: () {
              _pageController.changeFilter(
                  filter: ListPokemonFilter.ascendingID);
            },
            icon: Icon(Icons.sort_rounded),
          ),
          HawkFabMenuItem(
            label: ListPokemonFilter.descendingID,
            ontap: () {
              _pageController.changeFilter(
                  filter: ListPokemonFilter.descendingID);
            },
            icon: Icon(Icons.sort_rounded),
          ),
          HawkFabMenuItem(
            label: ListPokemonFilter.alphabetAZ,
            ontap: () {
              _pageController.changeFilter(
                  filter: ListPokemonFilter.alphabetAZ);
            },
            icon: Icon(Icons.sort_by_alpha_rounded),
          ),
          HawkFabMenuItem(
            label: ListPokemonFilter.alphabetZA,
            ontap: () {
              _pageController.changeFilter(
                  filter: ListPokemonFilter.alphabetZA);
            },
            icon: Icon(Icons.sort_by_alpha_rounded),
          ),
        ],
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Card(
                    elevation: 2.0,
                    child: InkWell(
                      onTap: () {
                        _showBottomSheet(
                          context,
                          header: "Select Generation",
                          selections: ListPokemonFilter.generations,
                          snappings: [1.0],
                        );
                      },
                      child: Obx(() => Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              _pageController.selectedGeneration.value
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Obx(() => Card(
                        elevation: 2.0,
                        color: Color(PokemonTypeColors
                            .colors[_pageController.selectedType.value]),
                        child: InkWell(
                          onTap: () {
                            _showBottomSheet(
                              context,
                              header: "Select Type",
                              selections: ListPokemonFilter.types,
                              snappings: [0.55, 1.0],
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              _pageController.selectedType.value.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )),
                ),
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
              ],
            ),
            Expanded(
              child: Obx(() => _pageController
                  .pages[_pageController.selectedTabIndex.value]),
            ),
          ],
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context,
      {String header,
      List<String> selections,
      List<double> snappings = const [0.4, 1.0]}) async {
    await showSlidingBottomSheet(
      context,
      builder: (context) => SlidingSheetDialog(
        elevation: 8.0,
        cornerRadius: 16.0,
        snapSpec: SnapSpec(
          snappings: snappings,
        ),
        builder: (context, state) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Material(
              child: Text(
                header,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              height: 8.0,
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              itemCount: selections.length,
              itemBuilder: (context, index) => Card(
                elevation: 4.0,
                color: ListPokemonFilter.generations.contains(selections[index])
                    ? Colors.grey[300]
                    : Color(PokemonTypeColors.colors[selections[index]]),
                child: InkWell(
                  onTap: () {
                    if (ListPokemonFilter.generations
                        .contains(selections[index])) {
                      _pageController.changeFilter(
                          generation: selections[index]);
                    } else {
                      _pageController.changeFilter(typeName: selections[index]);
                    }
                    Get.back();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      selections[index].toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
