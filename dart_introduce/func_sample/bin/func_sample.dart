// ignore: slash_for_doc_comments
import 'dart:html';

void main(List<String> arguments) {
  print('Hello world!');

  /**
   * 和JAVA不同的是，函数在Dart中是一等公民，一等公民的意思就是函数对象作为原生对象是支持的
   * 而且能够赋值、能够作为参数传递，能够作为返回值返回
   */
  print('Dart中的函数可以定义在函数里面');
  void subFunc() {
    print('  execute in subFunc in Function');
  }

  subFunc();

  print('函数对象可以作为参数传递,可以用于变量赋值');
  String retString() {
    return 'execute in subRoutine';
  }

  /**
   * 如果函数只有一样，可以使用简化的方式来书写，这里提供了一个语法糖
   */
  String retStringSimple() => 'execute in subRoutine in simpleSytle';
  void subFuncWithFunc(dynamic s) {
    print('  execute in subFunc in Function with Param : ${s()}');
  }

  Function sf = subFuncWithFunc;
  sf(retString);

  subFuncWithFunc(() => 'execute in 匿名函数');

  /**
   * 函数的可选参数
   * 函数的可选参数是现在比较主流的用来实现函数重载的方式
   * 函数的参数有几个问题，这几个问题Dart提供了解法：
   * 1. 函数的参数如果比较多，在调用的时候保证顺序需要花费一定的精力：可选命名参数
   * 2. 函数的参数比较多，可能在当前场景下，变化的就是其中一个参数，其他参数都是默认值，还需要掌握函数的默认值： 可选命名参数
   * 3. 如果觉得上述的命名参数的形式比较啰嗦，可以选择严格按照参数声明顺序来调用，同时定义参数的默认值：这个叫做可选位置参数
   */
  print('使用可选命名参数,不再受限参数传递顺序,也不再受限于一定要提供参数的默认值');
  print('  使用默认的参数声明顺序来调用: ${add(a: 3, b: 2)}');
  print('  使用任意的顺序来调用,不满足函数声明时的参数顺序: ${add(b: 3, a: 2)}');
  print('  省略其中一个参数，其中b的取值为默认值2: ${add(a: 2)}');
  print('  省略所有的参数，参数都使用默认值: ${add()}');

  print('使用可选位置参数,要严格遵循参数声明顺序,可以定义默认值');
  print('  严格按照参数声明顺序、使用了默认值 ${add2(1)}');
  print('  严格按照参数声明顺序、使用了默认值 ${add2(1, 2)}');
  print('  严格按照参数声明顺序、使用了默认值 ${add2(1, 2, 3)}');

  /**
   * 函数还有一个定义函数签名的别名的方式，typedef，非常好理解，不再赘述
   */
}

int add({int a= 1, int b = 2}) {
  return a + b;
}

int add3(int a, {int b=2}){
  return a+ b;
}

int add2(int a, [int b = 2, int c = 3]) {
  return a + b;
}
