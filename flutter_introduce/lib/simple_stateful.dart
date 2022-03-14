import 'package:flutter/material.dart';

/// 因为StatefulWidget 有状态，在页面存活期间，能够支持局部刷新
/// 所以可以理解为 StatefulWidget 的生命周期是有一个比较长的生命周期
/// 和安卓类似，这里也有几个生命周期的回调函数：
///
/// initState()
/// 是在 createState 函数调用之后，state对象被创建出来之后立即被调用
/// 如果需要执行额外的初始化的时候，需要调用它，而且能够初始化的是没有依赖的初始化。
///
/// 注意1：必须调用super.initState.
/// 注意2：该方法可以得到 context，但无法真正使用它，因为框架还没有完全将其与 state 关联
/// 从框架实现的角度来解释就是context这个时候对象刚刚创建出来，初始化完毕，但是尚未完成必要的链接(树未构建完成)
/// 所以Context的一些接口都是不能使用的
///
/// didChangeDependencies
/// 如果widget 链接到了一个 InheritedWidget，或者是一个Listener，在每次当InheritedWidget 变化的时候
/// 都会引起Widget的重建，此时会调用该方法
/// 注意点1：必须调用super.didChangeDependencies
/// 注意点2: 这个函数是用来一些比较耗时的初始化的动作的时候，比如StatefulWidget依赖的
/// 一些API的初始化、或者是一些关键数据的初始化(依赖InheritedWidget)才能获得。
///
/// Build
/// 这个函数是每次重新构建widget的时候都会调用；
/// 他的调用频度比 didChangeDependencies 高，每次 didChangeDependencies 调用都会引起
/// build调用，但是并不是每次build调用都是因为 didChangeDependencies 引起的。
/// 这样的场景就是用户主动调用了setState函数，setState函数会触发build函数调用，实现widget重建
///
/// dispose
/// 是widget被废弃/销毁的时候调用
/// 可以在这个函数里面执行一些资源清理工作，比如取消listener的监听等。
///
/// 因为Widget的树机制，StatelessWidget 可以是 StatefulWidget 的parent或者child。


class SimpleDemoStateful extends StatefulWidget {
  const SimpleDemoStateful({required this.title}):super();
  final String title;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SimpleDemoStatefulState();
  }
}

class _SimpleDemoStatefulState extends State<SimpleDemoStateful> {
  int count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('${context.runtimeType} in init');
    count = 0;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('${context.runtimeType} in didChangeDependencies');
    count = 8;
  }

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
    print('reassemble');
    count = 100;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new GestureDetector(
      onTap: onClick,
      child: new Text("$count",style: Theme.of(context).textTheme.headline1,),
    );
  }

  void onClick() {
    setState(() {
      count += 1;
    });
  }
}