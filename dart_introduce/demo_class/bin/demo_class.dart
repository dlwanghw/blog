
import 'derivedc_class.dart';
import 'driveda_class.dart';
import 'derivedb_class.dart';
import 'mixin_extends.dart';
import 'multi_implement.dart';

void main(List<String> arguments) {
  print('Hello world!');

  /**
   * Java 提供了 Interface 和 Class 两种概念，Interface只是提供了接口，其成员函数只能是空函数
   * Dart 没有提供Inteface和Class的概念，但是使用extends 和implements 来等价于Interface和Class的概念
   * 当类A implements 类B，则类A不能复用类B的任何实现，只能复用接口
   * 当类A extends 类B，则类A可以复用类B的接口和实现，在具体的处理中体现就是可以调用super.***来实现
   * 抽象类和非抽象类的区别是是否可以实例化。
   */

  print('类A继承于类B的时候,可以复用类B的接口和实现,如果要复用实现,必须显示调用super.***函数');
  var demoA = DerivedAClass();
  demoA.funcA();
  demoA.funcB();
  demoA.funcC();

  print('类A 实现 类B的时候,可以复用类B的接口,不能复用实现,无论类B中的接口是否已经有处理内容');
  var demoB = DerivedBClass();
  demoB.funcA();
  demoB.funcB();
  demoB.funcC();

  /**
   * 访问权限分成两类,包内可访问，全局可访问：
   * 包内可访问：无限制，默认都是包内可访问
   * 全局可访问：无显示，除非使用_下划线开头的变量或者函数来命名做限制，否则全局都可访问。
   */
  print('成员变量的访问权限演示');
  var demoC = DerivedCClass();
  print('  确认成员函数的访问权限 默认都是公开的 ${demoC.value}');
  demoC.value = 5;
  print('  确认成员函数的访问权限 默认都是公开的,修改后的值 ${demoC.value}');

  var demoD = DerivedCClass();

  print('当添加了_ 下划线标识后，就标识是私有变量，在同一个包内可以访问，不同的包不能访问，可以提供get/set函数来访问');
  print('  确认成员函数的访问权限 默认都是公开的 ${demoD.getPrivateValue}}');
  print('  确认成员函数的访问权限 默认都是公开的 ${getDerivedCClassPrivateValue()}');

  /**
   * Class/Interface的多重继承
   * 和Java一样，如果是Interface的实现，一个类是可以实现多个Interface的接口的
   */
  print('implements支持从多个基类来继承接口--不能继承实现');
  var demoMulti = MultiImplementDClass();
  demoMulti.funcA();
  demoMulti.funcOtherA();

  /**
   * Mixin
   * 适用场景：
   * 当想要复用某个类如类B的成员或者函数时，则可以将类B Mixin 到我们的类中。
   *
   * 比Java多支持了Mixin，Mixin的规则是mixin的两个类有一个同样签名的函数，以最后一个为主
   * 如果Mixin的两个类不一样的签名，则使用存在签名的那个类的函数。
   *
   * Mixin的两个前提，即能够用于Mixin的类需要满足两个条件
   * 1. 从Object继承，也就是一个全新定义的类或者是implements 接口类的类
   * 2. 类没有构造函数
   * 下面也演示了一个dart的语法糖，就是链式调用。
   */
  print('从多个类extends是不支持的,但是支持从多个类来mixin');
  var demoMixin = MixinMultiClass();
  demoMixin..funcA()..funcB()..funcC()..funcOtherA()..funcOtherB()..funcOtherC();

  /**
   * 成员函数的重载
   * Dart不支持成员函数的重载，通过函数的参数(可选名称参数和可选位置参数)来实现重载的效果
   * 函数比较多，参考函数类的工程
   */

  /**
   * 构造函数
   * Dart中的构造函数相关的特色还挺多的
   * 1. 通常构造函数的简化写法
   * 2. 命名构造函数--将构造函数换个名字，更准确的表达含义
   * 3. 单纯定义一个构造函数的别名，也叫重定向构造函数
   * 4. 构造函数使用初始化列表
   * 5. 子类的构造函数可以调用父类的构造函数
   * 6. 使用Const修饰常量构造函数
   * 7. 工厂构造函数，便于实现单例、享元，也可以用来构造子类的实例
   * 详细的参考demo_contruct.dart文件的例子。
   */


}
