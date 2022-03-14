
class DemoAuto {

  void showBaseUsage(){
    var str = "yyy";
    print('  var is ${str.runtimeType} when it is inialized by $str');
    // str = 123;// 非动态数据类型，一旦确定了类型，无法修改，这里会报错
  }
  void showDartSpecialUsage() {
    dynamic dyX = "xxx"; // 动态数据类型
    print('  dynamic value is ${dyX.runtimeType} when it is inialized by $dyX'); // 只有在运行的时候才能知道具体的数据类型，所以可能存在数据类型检查失败的情况

    // dyX.foo(); // 这里编译的时候不会报错，但是运行的时候才会报错
    dyX = 123;
    dyX.toDouble();
    print('  dynamic value is ${dyX.runtimeType} when it is modified by $dyX');

    Object obZ = "zzz";
    print('  Object is ${obZ.runtimeType} when it is inialized by $obZ');
    obZ = 456;
    print('  Object is ${obZ.runtimeType} when it is modified by $obZ');
    int intObz = obZ as int; //不同于dynamic，它不能调用Object所不存在的方法
    print( '  new add type convert ${intObz.toDouble()}');
  }
}