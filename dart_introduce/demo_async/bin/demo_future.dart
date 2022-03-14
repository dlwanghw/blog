import 'dart:async';

void main() {
  print("main start");

  Future fut = Future.value(18);
  // 使用then注册Future对象执行完成时的回调函数

  fut.then((res) {
    print('展示简单的注册FutureTask完成后的回调函数注册');
    print(' $res');
  });

  // 链式调用，可以跟多个then，注册多个回调

  Future(() {
    print('展示链式注册回调函数，当futureTask完成后，会逐一回调注册的回调函数');
    print(" future task");
  }).then((res) {
    print(" future task complete callback");
  }).then((res) {
    print(" future task second callback");
  });

  /**
   * 可以使用future对象的wait操作来等待多个future对象完成，在执行注册的回调函数
   */

  Future task1 = Future(() {
    print('使用Future.wait来构造一个Future,实现的效果是等待多个futureTask完成后，再执行下一个任务');
    print(" future task 1");
    return 1;
  });

  Future task2 = Future(() {
    print(" future task 2");
    return 2;
  });

  Future waitTask = Future.wait([task1, task2]);
  waitTask.then((res) {
    print(' future task 1 and 2 finished $res');
  });

  print("main stop");
}
