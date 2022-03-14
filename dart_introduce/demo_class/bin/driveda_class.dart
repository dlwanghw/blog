
import 'dart:io';
import 'base.dart';

class DerivedAClass extends BaseClass {
  @override
  void funcA() {
    // TODO: implement funcA
    // super.funcA();
    print('extends funcA in DerivedAClass');
  }

  @override
  void funcB() {
    // TODO: implement funcB
    super.funcB();
    print('extends funcB in DerivedAClass');
  }

  @override
  void funcC() {
    // TODO: implement funcC
    super.funcC();
    print('extends funcC in DerivedAClass');
  }


}