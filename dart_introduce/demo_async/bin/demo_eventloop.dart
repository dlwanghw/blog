import 'dart:async';

void main(List<String> arguments) {
  print('Hello Dart asnyc world!');

  /**
   * Dart和Nodejs类似，提供了单线程的编程模型--协程的概念，同时提供了并发的编程模型(类似线程的概念)
   * 单线程的编程模型：当遇到函数调用无法理解完成，需要等待的场合，将其添加到EventLoop中，然后继续执行其他的内容。
   * 然后遍历EventLoop，找到等待完成的任务继续执行
   */

  /**
   * 通过Future的构造函数，构造一个Future的任务，同时将这个Future的任务添加到EventLoop中；
   * 通过scheduleMicrotask函数调用，构造一个MicroTask的任务，同时将这个任务添加到MicroTask中
   * Dart主循环执行完成后，会先遍历MicroTask，进而遍历EventLoop，找出其中的任务，然后执行。
   * 所有都执行结束后，程序退出。
   *
   * 哪些任务放在EventQueue中呢？
   * 1. 一些外部事件：比如I/O操作、输入事件、绘图操作、计时器、Stream
   * 2. 一些内部事件：通过Future构造异步任务，这些异步任务会放入EventQueue中
   *
   * 哪些任务会放在MicroTask Queue呢？
   * 主要是一些非常简短的，且需要异步执行的内部动作，比如Stream的异步通知。一般情况下
   * 应用的开发都不需要应用到MicroTask Queue。所以主要了解EventQueue即可。
   *
   * 将任务包装并添加到EventQueue的方法：
   * 构造默认构造函数构造一个Future对象(Future)
   * 构造命名构造函数构造一个Future对象(Future.delayed())
   * 构造一个Timer对象(Timer)
   */

  void microTask() {
    print(' this is worker task in microTask');
  }

  void eventTask() {
    print(' this is worker task in eventQueue');
  }

  Future(eventTask);

  scheduleMicrotask(microTask);

  Future.delayed(Duration(seconds: 1), () {
    print(' delay 1s executed in EventQueue');
  });

  Timer(Duration(seconds: 2), () {
    print(' delayed 2s executed in timer');
  });
  print('程序运行结束啦');
  /**
   * 注意事项：
   * EventLoop是改变了处理顺序，同时节省了因为I/O操作带来的等待时间。
   * 因为其本质上是单线程执行，所以如果遇到非常耗时的CPU密集计算的处理，
   * 会导致EventLoop遍历阻塞，从而导致Timer/Delayed等的时间都不准确。
   */
}
