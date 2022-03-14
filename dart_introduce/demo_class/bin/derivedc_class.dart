
import 'base.dart';

// implements可以从抽象类继承，也可以从子类继承
class DerivedCClass extends BaseClass {
  DerivedCClass():_privateValue=100;
  int? value;

  int _privateValue;

  int get getPrivateValue {
    return _privateValue;
  }

  @override
  void funcA() {
    print('extends funcA in DerivedCClass');
  }

  @override
  void funcB() {
    print('extends funcB in DerivedCClass');
  }

  @override
  void funcC() {
    print('extends funcC in DerivedCClass');
  }

}

int getDerivedCClassPrivateValue(){
  return DerivedCClass()._privateValue;
}

class DerivedDerivedCClass extends DerivedCClass {

  int getBasePrivateValue() {
    return super._privateValue;
  }

}