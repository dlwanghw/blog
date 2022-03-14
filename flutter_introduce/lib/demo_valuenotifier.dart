
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Item {
  String reference;

  Item(this.reference);
}


/// 使用ValueNotifier的关键点：
/// 1. 构造一个ValueNotifier包装的维护State的变量，比如下面的_itemListNotifier；
/// 2. 增加接口，用来更改State的变量的接口；
/// 3. 在构建Widget树时，使用ValueListenableBuilder，在构造函数中，传入创建出来的"ValueNotifier包装的维护State的变量"
///
///
/// 这个可以实现局部刷新，通过Listener机制，确保只有变化的widget会被重建；
/// 不如意的地方：
/// 1. ValueListenableBuilder构造的时候，需要传递构造出来的ValueNotifier<State>
/// 如果状态量比较多，或者传递的层次比较深，这个时候，代码还是相对复杂；
/// 2.业务逻辑处理和界面组件都耦合在这一个Widget文件中，期望还是将业务逻辑和界面组件给分割开。
///
/// 好的地方：
/// 和InheritedWidget对比，代码实现了简化，不需要写复杂的InheritedWidget类来完成状态的维护；
///
class MyValueNotifierWidget extends StatefulWidget {
  @override
  _MyValueNotifierWidgetState createState() => new _MyValueNotifierWidgetState();
}

class _MyValueNotifierWidgetState extends State<MyValueNotifierWidget> {
  int i = 0;
  ValueNotifier<List<Item>> _itemListNotifier = ValueNotifier(List.empty(growable: true));
  void addItem() {
    i++;
    _itemListNotifier.value.add(Item('pressed $i times'));
    _itemListNotifier.notifyListeners();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Title',style: Theme.of(context).textTheme.headline3,),
        ),
        body: Column(
          children: <Widget>[
            WidgetA(onPressCallback: addItem),
            Container(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20,),
                  ValueListenableBuilder(
                      valueListenable: _itemListNotifier,
                      builder:(context,List<Item> value,_)=>WidgetB(itemList: value) ),
                  SizedBox(width: 20,),
                  WidgetC(),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class WidgetA extends StatelessWidget {
  const WidgetA({required this.onPressCallback}):super();
  final Function onPressCallback;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: Text('Add Item',style: Theme.of(context).textTheme.headline3,),
        onPressed: () {
          onPressCallback();
        },
      ),
    );
  }
}

class WidgetB extends StatelessWidget {
  const WidgetB({Key? key,required this.itemList}):super();
  final List<Item> itemList;
  @override
  Widget build(BuildContext context) {
    print('widget B rebuild');
    return Text('"I am Widget B ${itemList.length}"',style: Theme.of(context).textTheme.headline3,);
  }
}

class WidgetC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('widget C rebuild');
    return Text('"I am Widget C"',style: Theme.of(context).textTheme.headline3,);
  }
}




