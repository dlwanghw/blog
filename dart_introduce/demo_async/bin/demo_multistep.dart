//
//  假定有这样一个真实的场景，
//  Application需要调用下层的一个模块(模块A)的三个接口，三个接口都是通过网络来调用的
//  也就是说都存在网络IO，这个时候看下使用future以及更高级的抽象stream怎么来解决
//

import 'dart:io';

void main(List<String> parameters) async {
  print('主程序开始');

  if (parameters.isNotEmpty) {
    switch (parameters.first) {
      case 'future':
        // implementInFuture();
        await implementInFuture2();
        break;
      case 'async':
        // 这里并未使用await来等待，所以后续的‘主程序结束’的日志会优先输出
        implementInAsync();
        break;
      case 'stream':
        implementInStream();
        break;
      default:
        print('you must select the option future or stream or async');
        return;
    }
  } else {
    print(
        'please run with "dart run ./bin/demo_multistep.dart with option future/stream/async"');
  }
  print('主程序结束');
}

void implementInFuture() {
  /**
   * 使用future来实现，只能在future的then中创建下一个future
   */
  Future step1 = Future(() {
    print('演示如何通过Future来实现异步回调');
    print(' 执行Step1的接口调用');
    return 'step1 ok';
  });
  step1.then((res) {
    print(' step1 then callback, the response is $res');
    Future step2 = Future.delayed(const Duration(seconds: 1), () {
      print('   执行Step2的接口调用');
      return 'step2 ok';
    });
    step2.then((res) {
      print('   step2 then callback, the response is$res');
      Future step3 = Future(() {
        print('     执行Step3的接口调用');
        return 'step3 ok';
      });
      step3.then((res) {
        print('     step3 then callback, the response is $res');
      });
    });
  });

  /**
   * 能看到当回调多的时候，是比较费精力的，也就是传说中的回调地狱。
   * 强调：这里的应用场景“必须确保严格的调用顺序”
   */
}

implementInFuture2() async {
  /**
   * 使用future + async来实现
   */
  Future step1 = Future(() {
    print('演示如何通过Future来实现异步回调');
    print(' 执行Step1的接口调用');
    return 'step1 ok';
  });
  step1.then((res) {
    print(' step1 then callback, the response is $res');
  });
  await step1;

  Future step2 = Future.delayed(const Duration(seconds: 1), () {
    print('   执行Step2的接口调用');
    return 'step2 ok';
  });
  step2.then((res) {
    print('   step2 then callback, the response is$res');
  });
  await step2;

  Future step3 = Future(() {
    print('     执行Step3的接口调用');
    return 'step3 ok';
  });
  step3.then((res) {
    print('     step3 then callback, the response is $res');
  });
  await step3;

  /**
   * 这里通过 await 来实现了future task的同步(确保调用顺序)。
   * 虽然看上去是同步了，但是要注意因为future都是在EventQueue上执行的，所以并没有消耗CPU上的行为产生
   * 基本上都在I/O等待过程中(这里假定的前提就是Step1~3是网络I/O操作)
   */
}

implementInAsync() async {
  step1Task() async {
    print('演示如何通过 aysnc 和 await 来实现多个顺序调用');
    print(' 执行Step1的接口调用 in async');
    return 'step1 ok';
  }

  step2Task() async {
    print('   执行Step2的接口调用 in async');
    return 'step2 ok';
  }

  step3Task() async {
    print('     执行Step3的接口调用 in async');
    return 'step3 ok';
  }

  /**
   * 如同在async段提到的，此处首先执行step1Task，然后发现返回的是一个future对象
   * 则将await之后的部分，从print -> await step2Task  await step3Task -> print step3 response这些
   * 逻辑都封装到future中，送到eventQueue中去等待执行。然后implementInAsync函数执行完成，顺序执行main函数后面的逻辑
   *
   * 接着遍历eventQueue，找到刚才的future，执行print step1 response；接着执行step2Task
   * 接着await 等待到了step2Task返回的future，将print step2 response -> await step3Task -> print step3 response
   * 的这些逻辑送到EventQueue中，当前的这个future执行完毕。
   *
   * 接着遍历eventQueuqe，找到先前的future，执行print step2 reponse，接着执行step3Task
   * 接着await， 等待到了Step3Task 返回的future，将 print step response 送入EventQueue
   *
   * 接着遍历eventQueue，找到先前的future，执行print step3 response。
   * 至此执行结束。
   */
  var res = await step1Task();
  print(' step1 then callback, the response is $res');
  res = await step2Task();
  print('   step2 then callback, the response is$res');
  res = await step3Task();
  print('     step3 then callback, the response is $res');
}

// /**
//  * implementInAsync实现了用同步调用的思维，实现了异步的调度，整体上非常清晰
//  * 在此基础上，可以很容易的完成如下变体：
//  * 1. 三个async调用并发执行，等待三个都执行完成之后做下一步的动作
//  * → 因其都返回future对象，所以可以使用future.wait的方式来等待三个都完成再做下一步工作
//  * 2. 三个async调用并发执行，等待两个执行完成，做下一步的动作
//  * → 等待两个future同第一种情况，第三种单独等待，可以使用then注册future完成的回调
//  * 3. 三个调用顺序执行，使用上述的方式，使用await实现同步形式的回调逻辑。
//  *
//  * 还有如下的几个场景不好处理：
//  * 1. 存在一个CPU密集型的计算任务，如果放在Dart单线程环境下执行，则Timer、Future.delayd等基于时间的调用都会发生严重偏差
//  * 2. 在Dart和其他模块的交界处，如果其他模块提供了同期且执行时间长的接口，就像是需要执行一个cpu密集型计算任务
//  * →  上述两种情况考虑使用isolate来并发执行，充分利用cpu的多核特性；要解决的问题是当独立的isolate执行完成后
//  * 如何通知到Dart的主运行线程。这部分需求同下面的3，一并说明。
//  * 3. 在Dart和其他模块的交界处，其他模块提供了一个异步的API，其形式类似于：async_op(onFinish())的形式
//  * →  这个时候使用async await就没有办法封装了，因为此时的需求是：要在onFinish函数中通知future已经处理完成
//  * 以便在下一轮次的EventQueue遍历过程中，能够触发之前调用async_op操作时构造的future任务继续执行。
//  * 此时需要使用Completer,可以参考如下地址:https://juejin.cn/post/6896352801082114055
//  */

/// A Future represents a computation that doesn’t complete immediately.
/// Where a normal function returns the result, an asynchronous function returns a Future,
/// which will eventually contain the result. The future will tell you when the result is ready.

/// A stream is a sequence of asynchronous events.
/// It is like an asynchronous Iterable—where,
/// instead of getting the next event when you ask for it,
/// the stream tells you that there is an event when it is ready.
///

/// 还可以使用stream的方式，reactive编程模式，
/// 可以简单理解成异步消息队列的形式，应用开发人员围绕event来设定响应函数，完成应用的需求。
/// Stream：在Java8开始支持了Stream，Dart中也实现了Stream机制、同时也有RxJava、RxJS的库
/// Stream的来源：用户点击、底层模块完成回调触发完成通知事件、Timer事件
/// 底层模块完成后的回调通知有两种处理方式：
/// 1. 在调用底层模块的API时，使用future包装处理完成的逻辑，发送到EventQueue，在回调中使用Completer来触发Future
/// 完成事件，进而触发在EventQueue中的future后续执行；
/// 2. 在调用底层模块的API时，不做处理，直接调用api执行，只是在回调函数里面生成stream的event；
/// 同时在应用层，设计stream的监听函数，在此函数中处理后续逻辑。

implementInStream() async {
  step1Task() async {
    print('演示如何通过Stream来缓解乱序的问题');
    print(' 执行Step1的接口调用 in async');
    return 'step1 ok';
  }

  step2Task() async {
    print('   执行Step2的接口调用 in async');
    return 'step2 ok';
  }

  step3Task() async {
    print('     执行Step3的接口调用 in async');
    return 'step3 ok';
  }

  var step1Res = step1Task();
  var step2Res = step2Task();
  var step3Res = step3Task();

  var streams = Stream<String>.fromFutures([step1Res, step2Res, step3Res]);
  await for (var s in streams) {
    print('收到了 $s 的返回结果');
  }
}
