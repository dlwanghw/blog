
class DemoNum {
  DemoNum();
  int valueInt=20;
  double valueDouble = 30.001;

  void showBasicUsage() {
    print('  valueInt is an int type and the value is $valueInt');
    print('  valueInt is an double type and the value is $valueDouble');
    print('  int convert to double ${valueInt.toDouble()}');
    print('  double convert to int ${valueDouble.toInt()}');
    print('  int convert to string ${valueInt.toString()}');

  }

  void showDartSpecialUsage() {
    print('  Int in dart: bitlength is ${valueInt.bitLength}, and runtimeType is ${valueInt.runtimeType}');
    print('  Double in dart: bitlength is non-existed, and runtimeType is ${valueDouble.runtimeType}');

    var envInt = int.fromEnvironment('init_int');
    print('  you can run dart run -Dinit_int= any Integer to initialize the envInt value');
    print('  you initialize the int value with $envInt');
  }
}

