
class DemoString {
  DemoString();
  String valueString = 'initialized';

  void showBaseUsage(){
    print('  Initialzie valueString is $valueString');
    var firstIndexChar = valueString.codeUnitAt(0);
    print('  the fist char value of valueString is $firstIndexChar');
    print('  the fist char of valueString is ${String.fromCharCode(firstIndexChar)}');
  }
  void showDartSpecialUsage() {
    print('  may be nothing special');
  }
}