
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hello_world/demo_valuenotifier.dart';
import 'package:provider/provider.dart';


class ItemInfo {
  String reference;

  ItemInfo(this.reference);
}

class ItemModel with ChangeNotifier {
  ItemInfo _itemInfo = ItemInfo("model");
  String get name => _itemInfo.reference;
  void setName (name) {
    _itemInfo.reference = name;
    notifyListeners();
  }
}

class MyProviderWidget extends StatefulWidget {
  @override
  _MyProviderWidgetState createState() => new _MyProviderWidgetState();
}

class _MyProviderWidgetState extends State<MyProviderWidget> {
  int i = 0;
  // ValueNotifier<List<Item>> _itemListNotifier = ValueNotifier(List.empty(growable: true));
  // void addItem() {
  //   i++;
  //   _itemListNotifier.value.add(Item('pressed $i times'));
  //   _itemListNotifier.notifyListeners();
  // }
  ItemModel itemModel = ItemModel();

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
    itemModel.setName('reassemble');
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        ChangeNotifierProvider<ItemModel>.value(
          value: itemModel,)
      ],
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
  const WidgetA():super();
  @override
  Widget build(BuildContext context) {
    print('widgetA rebuild');
    return Consumer<ItemModel>(
      builder: (context,item,_) {
        print('builder A is executed');
        return Container(
          child: ElevatedButton(
            child: Text('Add Item',style: Theme.of(context).textTheme.headline3,),
            onPressed: () {item.setName('modified'); print('key pressed');},
          ),
          );
      }
    );
  }
}

class WidgetB extends StatelessWidget {
  const WidgetB({Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    print('widget B rebuild');
    return Consumer<ItemModel>(
      builder: (context,item,_) {
        print('builder is executed');
        return Text('"I am Widget B ${item.name}"',style: Theme.of(context).textTheme.headline3,);
      }
    );
  }
}

class WidgetC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('widget C rebuild');
    return Text('"I am Widget C"',style: Theme.of(context).textTheme.headline3,);
  }
}




