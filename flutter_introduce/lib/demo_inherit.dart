import 'package:flutter/material.dart';

class DemoInheritWidget extends InheritedWidget {
  const DemoInheritWidget({
    Key? key,
    required this.countValue,
    required Widget child,
  }) : super(key: key, child: child);
  final int countValue;
  static DemoInheritWidget of(BuildContext context) {
    final DemoInheritWidget? result = context.dependOnInheritedWidgetOfExactType<DemoInheritWidget>();
    assert(result != null, 'No DemoInheritWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DemoInheritWidget old) {
    return old.countValue != countValue;
  }
}

class InheritedDemo extends StatefulWidget {
  @override
  _InheritedDemoState createState() => _InheritedDemoState();
}

class _InheritedDemoState extends State<InheritedDemo> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return DemoInheritWidget(
      countValue: _count,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(child: TextA(count: _count), width: 200, height: 100, alignment: Alignment.center,),
          ElevatedButton(onPressed: () {
            setState(() {
              _count++;
            });
          }, child: const Text('ADD'))
        ],
      ),
    );
  }
}

class TextA extends StatelessWidget {
  final int? count;
  TextA({this.count});

  @override
  Widget build(BuildContext context) {
    print('build TextA执行了');
    return TextB(count: count);
  }
}

class TextB extends StatefulWidget {

  final int? count;
  TextB({this.count});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TextBState();
  }
}

class TextBState extends State<TextB> {

  @override
  void didChangeDependencies() {
    //一般来说，很少会在子Widget中重写此方法，因为在依赖改变后，
    // Flutter框架也会调用build()方法重新构建树。但是如果需要在依赖发生改变后
    // 执行一些昂贵或者耗时的操作，比如网络请求，这时候最好的方法就是在didChangeDependencies方法中执行操作，
    // 这样可以避免每次build()都执行这些耗时操作；
    print('didChangeDependencies TextB执行了');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print('build TextB执行了');
    // return Text('${widget.count}');
    return Text(DemoInheritWidget.of(context).countValue.toString());
  }
}


