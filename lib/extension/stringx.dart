extension StringX on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach {
    String newStr = this.replaceAll("-", " ");
    int index = newStr.indexOf(" ");
    String sub = index != -1 ? newStr.substring(index + 1) : "";
    if (sub == "m") {
      sub = "♂";
      newStr = newStr.substring(0, index) + " " + sub;
    } else if (sub == "f") {
      sub = "♀";
      newStr = newStr.substring(0, index) + " " + sub;
    } else if (sub == "jr" || sub == "mime" || sub == "rime") {
    } else if (sub.isNotEmpty) {
      newStr = sub + " " + newStr.substring(0, index);
    }
    return newStr.split(" ").map((str) => str.inCaps).join(" ");
  }
}
