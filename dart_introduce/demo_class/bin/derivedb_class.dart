
import 'base.dart';
import 'driveda_class.dart';

// implements可以从抽象类继承，也可以从子类继承
class DerivedBClass implements DerivedAClass {
  @override
  void funcA() {
    // TODO: implement funcA
    // super.funcA(); // 如果是implements 会假设基类是纯Interface的概念，基类函数默认没有实现
    print('implement funcA in DerivedBClass');
    print('  execute funcA in DerivedBClass');
  }

  @override
  void funcB() {
    // TODO: implement funcB
    // super.funcB();
    print('implement funcB in DerivedBClass');
  }

  @override
  void funcC() {
    // TODO: implement funcC
    // super.funcC();
    print('implement funcC in DerivedBClass');
  }

}