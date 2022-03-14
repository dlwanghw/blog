
class DemoList {
  // DemoList();

  List privateList = List.empty();
  void showBasicUsage() {
    // 使用构造创建,初始化，并且使用forEach函数遍历，这里使用了lamda函数形式
    var list1 = [1, 2, 3];
    list1.forEach((element) { print('  List initialized by $element');});

    var list2 = List.of([4,5,6]);
    list2.forEach((element) { print('  List initialized by $element');});

    print(' List支持从一个已有的列表来创建，同时支持添加一个元素，添加另外一个列表');
    var list3 = List.from([40,50,60]);
    list3.add("append value");
    list3.addAll([7,8,9]);
    list3.forEach((element) { print('  List initialized by $element');});

    // Dart中的List是支持泛型的
    print('List中的每个元素是泛型的，支持动态修改， 修改前');
    var list4 = List.from(['first',2,'second']);
    list4.forEach((element) { print('  List initialized by $element');});
    list4[1] = 'second';
    list4.forEach((element) { print('  List second Element modified to $element');});

  }
  void showDartSpecialUsage() {
    print("  nothing special");
  }
}