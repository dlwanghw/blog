
import 'base.dart';
import 'base_another.dart';

class MultiImplementDClass implements BaseClass,BaseAnotherClass {
  @override
  void funcA() {
    // TODO: implement funcA
    print('  execute funcA in MultiImplementDClass');
  }

  @override
  void funcB() {
    // TODO: implement funcB
    print('  execute funcB in MultiImplementDClass');
  }

  @override
  void funcC() {
    // TODO: implement funcC
    print('  execute funcC in MultiImplementDClass');
  }

  @override
  void funcOtherA() {
    // TODO: implement funcOtherA
    print('  implement the BaseAnotherClass interface');
    print('  execute funcOtherA in MultiImplementDClass');
  }

  @override
  void funcOtherB() {
    // TODO: implement funcOtherB
    print('  execute funcOtherB in MultiImplementDClass');
  }

  @override
  void funcOtherC() {
    // TODO: implement funcOtherC
    print('  execute funcOtherA in MultiImplementDClass');
  }

}