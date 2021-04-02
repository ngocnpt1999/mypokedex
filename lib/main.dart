import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:mypokedex/controller/state_management.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypokedex/model/actions.dart';
import 'package:mypokedex/widget/search.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

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

  final HomeController _pageController = Get.put(HomeController());

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
            currentIndex: _pageController.selectedIndex.value,
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
              _pageController.changeFilter(ListPokemonFilter.ascendingID);
            },
            icon: Icon(Icons.sort_rounded),
          ),
          HawkFabMenuItem(
            label: ListPokemonFilter.descendingID,
            ontap: () {
              _pageController.changeFilter(ListPokemonFilter.descendingID);
            },
            icon: Icon(Icons.sort_rounded),
          ),
          HawkFabMenuItem(
            label: ListPokemonFilter.alphabetAZ,
            ontap: () {
              _pageController.changeFilter(ListPokemonFilter.alphabetAZ);
            },
            icon: Icon(Icons.sort_by_alpha_rounded),
          ),
          HawkFabMenuItem(
            label: ListPokemonFilter.alphabetZA,
            ontap: () {
              _pageController.changeFilter(ListPokemonFilter.alphabetZA);
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
                      onTap: () async {
                        await showSlidingBottomSheet(
                          context,
                          builder: (context) => SlidingSheetDialog(
                            elevation: 8.0,
                            cornerRadius: 16.0,
                            snapSpec: SnapSpec(
                              snappings: [1.0],
                            ),
                            builder: (context, state) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Material(
                                  child: Text(
                                    "Select Generation",
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
                                  itemCount:
                                      ListPokemonFilter.generations.length,
                                  itemBuilder: (context, index) => Card(
                                    elevation: 4.0,
                                    color: Colors.grey[300],
                                    child: InkWell(
                                      onTap: () {
                                        _pageController.changeGen(index);
                                        Get.back();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          ListPokemonFilter.generations[index],
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
                      },
                      child: Obx(() => Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              ListPokemonFilter.generations[
                                  _pageController.selectedGen.value],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(),
                ),
              ],
            ),
            Expanded(
              child: Obx(() =>
                  _pageController.pages[_pageController.selectedIndex.value]),
            ),
          ],
        ),
      ),
    );
  }
}
