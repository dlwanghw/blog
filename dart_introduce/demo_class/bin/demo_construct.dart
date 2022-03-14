// 通常写法，和java一致
// class Point {
//   double x = 0;
//   double y = 0;

//   Point(int x, int y) {
//     this.x = x as double;
//     this.y = y as double;
//   }
// }

// Dart中的写法，使用this.x,this.y 简化了上述的this.x=x as double的写法
class Point {
  num x = 0;
  num y = 0;
  Point(this.x, this.y);

  // 使用命名构造函数可以为一个类实现多个构造函数， 或者使用命名构造函数来更清晰的表明你的意图
  Point.fromJson(Map json) {
    x = json['x'];
    y = json['y'];
  }

  //重定向构造函数，使用冒号调用其他构造函数，一个重定向构造函数是没有代码的，在构造函数声明后，使用 冒号调用其他构造函数
  Point.alongXAxis(num x) : this(x, 0);
}

class Person {
  final String name;
  final int age;
  final String address;
  // 在构造函数体执行之前可以初始化实例参数。 使用逗号分隔初始化表达式。初始化列表非常适合用来设置 final 变量的值。
  Person(this.name, this.age):address='dalian';
}

class Woman extends Person {
  // 子类需要显示调用父类的构造函数，也可以调用父类的命名构造函数
  Woman(String name, int age) : super(name, age);
}

// 工厂构造函数是一种构造函数，与普通构造函数不同，工厂函数不会自动生成实例,而是通过代码来决定返回的实例对象。
// 如果一个构造函数并不总是返回一个新的对象（单例），则使用 factory 来定义这个构造函数。工厂构造函数无法访问this。

class Singleton {
  String name;
  //工厂构造函数无法访问this，所以这里要用static
  // 这里面因为是null-safety，所以需要明确_cache变量是否允许是null.
  static Singleton? _cache;

  //工厂方法构造函数，关键字factory
  factory Singleton([String name = 'singleton']) =>
      Singleton._cache ??= Singleton._newObject(name);

  //定义一个命名构造函数用来生产实例
  Singleton._newObject(this.name);
}
