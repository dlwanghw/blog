import 'demo_enum.dart';
import 'demo_num.dart';
import 'demo_string.dart';
import 'demo_list.dart';
import 'demo_auto.dart';

void main(List<String> arguments) {
  // 基本的程序结构：main函数作为程序的基本入口
  print("Hello world!");


  /**
   * 这是多行注释的写法，单行注释可以使用上一步的//
   */

  /**
   * 基础数值类型
   * 概念上对比：
   * * C++提供了int、float、double 三种数值类型
   * * Dart提供了int 和 double 的两种数据类型
   * 实现上的对比
   * * C++使用内存中的一块空间来保存数据,所以每种基础数值类型有基本的存储长度
   * * Dart完全使用了类对象模型来模拟实现，所以其存储长度是对象的存储长度。另外因为继承于Num
   * 所以Dart中的int和double提供了很多基础的函数。可以参考num类
   */

  print('基础数据类型用法展示、int和double两种数据类型');
  var demoNum = DemoNum();
  demoNum.showBasicUsage();
  demoNum.showDartSpecialUsage();

  /**
   * 字符串类型
   * 概念上对比：
   * * C++提供了char wchar_t 两种字符类型，同时提供了多种std::string
   * * Dart仅提供了String
   * 实现上的对比
   * * Dart的String等价于std::String
   * * Dart中的String可以进行判断是否相等、取出某个字符、取出某个子串等。
   * * 从Dart中的String取出某个字符，字符用int来保存
   */
  print('字符串类型用法展示、只有String类型');
  var demoString = DemoString();
  demoString.showBaseUsage();
  demoString.showDartSpecialUsage();

  /**
   * enum类型
   * C++ 可以支持每个枚举变量的值
   * Dart默认从0开始，不支持某个枚举值默认值的定义
   */
  print('枚举类型用法展示、只支持简单的枚举类型');
  var demoEnum = DemoEnum();


  /**
   * bool 类型
   * bool类型也是一个类对象,最新DartSdk支持了与或非操作。
   * 具体用法省略
   */

  /**
   * 数组/列表 以及Map支持集合类操作。
   * 数据和列表在Dart中是统一的，使用growable来标志，当List是可以增长的，就是列表，当List是不能增长的，可以等价为数组
   */
  print('数组或者列表类型用法展示、数组和列表统一为List');
  var demoList = DemoList();
  demoList.showBasicUsage();
  demoList.showDartSpecialUsage();

  /**
   * Dart支持var 和 Dynamic 两个关键字
   * var：等价于C++的auto，其主要的机制是用编译器自动检查，在初始化的时候来自动推导的
   * Dynamic：和JavaScript中是等价的，如果声明了Dynamic变量，在运行期是可以随意改变的
   */
  print('Dart中的Var等价于auto的概念，其Dynamic等价于JS中的动态类型,可以使用Object基类来声明变量');
  var demoAuto = DemoAuto();
  demoAuto.showBaseUsage();
  demoAuto.showDartSpecialUsage();


  /**
   * 函数对象
   * Dart中的函数是一等公民：意味着可以赋值、可以作为函数参数
   */
  print('Dart中函数对象');
  Object fun (element)=> {print('  lamda function type with input $element')};
  fun('single line lamda yyds');

}

