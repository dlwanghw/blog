

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// InheritedWidget 允许在 widget 树中有效地向下传播信息
/// InheritedWidget 是一个特殊的 Widget，它将作为另一个子树的父节点放置在 Widget 树中。
/// 该子树的所有 widget 都必须能够与该 InheritedWidget 暴露的数据进行交互。
///
/// 使用InheritedWidget 能够有效的控制刷新范围，即所有订阅了InheritedWidget的数据的widget
/// 在InheritedWidget的数据发生变更时，会得到时机得以重建。
///
/// 这里的WidgetB依赖InheritedWidget Widget，WidgetC 不依赖于InheritedWidget；
/// 但是他们都是InheritedWidget的子类
///
/// 当触发MyInheritedWidget重建时，子类WidgetC不需要重建，提高效率。
///
/// 从这个示例能够看到InheritedWidget能够精准的确定重建范围，从而提高效率。


/// 下面的示例：
/// Widget树结构是 MyInheritedWidget -> _MyInherited -> Scaffold
/// Scaffold -> WidgetA
/// Scafflld -> Column
/// Column -> WidgetB
/// Column -> WidgetC
///
/// WidgetB 去调用 MyInheritedWidget.of(context) 找到了 _MyInherited
/// MyInheritedWidget的State通过 初始化构造函数，传入 _MyInherited ，并保存下来
/// 找到了 _MyInherited 之后，就找到了 MyInheritedWidget的State。
/// 然后可以修改State，当State变更之后，通知到WidgetA和WidgetB，因为这两个Widget订阅了 _MyInherited
///
class Item {
  String reference;

  Item(this.reference);
}

class _MyInherited extends InheritedWidget {
  _MyInherited({
    Key? key,
    required Widget child,
    required this.data,
  }) : super(key: key, child: child);

  final MyInheritedWidgetState data;

  @override
  bool updateShouldNotify(_MyInherited oldWidget) {
    return true;
  }
}

class MyInheritedWidget extends StatefulWidget {
  MyInheritedWidget({
    Key? key,
    required this.child,
  }): super(key: key);

  final Widget child;

  @override
  MyInheritedWidgetState createState() => new MyInheritedWidgetState();

  static MyInheritedWidgetState of(BuildContext context){
    return (context.dependOnInheritedWidgetOfExactType<_MyInherited>() as _MyInherited).data;
  }
}

class MyInheritedWidgetState extends State<MyInheritedWidget>{
  /// List of Items
  List<Item> _items = <Item>[];

  /// Getter (number of items)
  int get itemsCount => _items.length;

  /// Helper method to add an Item
  void addItem(String reference){
    setState((){
      _items.add(new Item(reference));
    });
  }

  @override
  Widget build(BuildContext context){
    print('MyInheritedWidget rebuild');
    return new _MyInherited(
      data: this,
      child: widget.child,
    );
  }
}

class MyWhyInheritWidget extends StatefulWidget {
  @override
  _MyWhyInheritWidgetState createState() => new _MyWhyInheritWidgetState();
}

class _MyWhyInheritWidgetState extends State<MyWhyInheritWidget> {
  @override
  Widget build(BuildContext context) {
    print('MyWhyInheritWidget build');
    return MyInheritedWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Title',style: Theme.of(context).textTheme.headline3,),
        ),
        body: Column(
          children: <Widget>[
            WidgetA(),
            Container(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20,),
                  WidgetB(),
                  SizedBox(width: 20,),
                  WidgetC(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('widget A build');
    final MyInheritedWidgetState state = MyInheritedWidget.of(context);
    return Container(
      child: ElevatedButton(
        child: Text('Add Item',style: Theme.of(context).textTheme.headline3,),
        onPressed: () {
          state.addItem('new item');
        },
      ),
    );
  }
}

class WidgetB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('widget B rebuild');
    final MyInheritedWidgetState state = MyInheritedWidget.of(context);
    return Text('"I am Widget B ${state.itemsCount}"',style: Theme.of(context).textTheme.headline3,);
  }
}

class WidgetC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('widget C rebuild');
    return Text('"I am Widget C"',style: Theme.of(context).textTheme.headline3,);
  }
}




