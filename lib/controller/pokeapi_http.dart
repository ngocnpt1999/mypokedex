import 'dart:convert';

import 'package:pokeapi_dart/pokeapi_dart.dart';
import 'package:http/http.dart' as http;

class MyPokeApi {
  static Future<NamedApiResourceList> getPokemonPage(
      {int offset, int limit}) async {
    var response = await http
        .get("https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset/");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      var value = NamedApiResourceList.fromJson(jsonData);
      return value;
    } else {
      print(response.statusCode);
      throw Exception("Failed!!!");
    }
  }

  static Future<Pokemon> getPokemon({int id, String name}) async {
    String index = id != null ? id.toString() : name;
    var response = await http.get("https://pokeapi.co/api/v2/pokemon/$index/");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      var value = Pokemon.fromJson(jsonData);
      return value;
    } else {
      print(response.statusCode);
      throw Exception("Failed!!!");
    }
  }

  static Future<PokemonSpecies> getPokemonSpecies({int id, String name}) async {
    String index = id != null ? id.toString() : name;
    var response =
        await http.get("https://pokeapi.co/api/v2/pokemon-species/$index/");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      var value = PokemonSpecies.fromJson(jsonData);
      return value;
    } else {
      print(response.statusCode);
      throw Exception("Failed!!!");
    }
  }

  static Future<EvolutionChain> getEvolutionChain({int id}) async {
    var response =
        await http.get("https://pokeapi.co/api/v2/evolution-chain/$id/");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      var value = EvolutionChain.fromJson(jsonData);
      return value;
    } else {
      print(response.statusCode);
      throw Exception("Failed!!!");
    }
  }
}
