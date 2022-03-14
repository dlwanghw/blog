import 'dart:io';

// 模拟耗时操作，调用sleep函数睡眠2秒
// 函数返回值可以添加Future修饰，也可以不加
Future<String> doTask() async {
  // ignore: await_only_futures
  print(' 执行异步任务，开始休眠');
  sleep(const Duration(seconds: 1));
  print(' 执行异步任务，休眠结束');
  return "Ok";
}

// 定义一个函数用于包装
// 函数返回值可以添加Future修饰，也可以不加
Future futureTask() async {
  var r =  await doTask();
  print(r);
  return r;
}

void main() {
  print("main start");
  /**
   * futureTask使用了async修饰，其意思是这个函数会返回一个Future对象
   * 所以此时futureTask的函数定义中，可以不加Future返回值的修饰；
   * 当执行到futureTask的时候，会进入该函数
   * 当遇到了await时，首先进入执行doTask函数，等doTask函数执行完，返回了一个future对象
   * await 发现是一个future对象，则会将await这一行之后的所有函数执行体封装起来，将其发送到eventQueue去执行；
   * 这样futureTask就算是处理完了，然后接着执行main函数后面的逻辑，即输入main end的日志。
   *
   * 当遍历EventQueue时，找到await后面的futureTask的剩余执行体，继续执行。
   *
   * 这里再强调下，async 就是将函数的返回值包装成一个future对象。
   * 所以当futureTask中await之后的部分在eventQueue中执行完成后，返回一个future对象
   * 之后发现有then注册了函数，此时就会立即执行then中注册的函数。
   */
  futureTask().then((value) => print('futureTask执行完成'));
  // doTask(); 可以试试将futureTask注释掉，将此行注释打开，确认下处理顺序
  print("main end");
}
