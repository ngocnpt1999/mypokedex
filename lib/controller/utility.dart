class Utility {
  static int getPkmIdFromUrl(String url) {
    var re = RegExp(r'(?<=pokemon/)(.*)(?=/)');
    var match = re.firstMatch(url);
    return int.parse(match.group(0));
  }

  static int getPkmSpecIdFromUrl(String url) {
    var re = RegExp(r'(?<=pokemon-species/)(.*)(?=/)');
    var match = re.firstMatch(url);
    return int.parse(match.group(0));
  }

  static int getEvoChainIdFromUrl(String url) {
    var re = RegExp(r'(?<=evolution-chain/)(.*)(?=/)');
    var match = re.firstMatch(url);
    return int.parse(match.group(0));
  }
}
