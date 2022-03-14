
import 'package:flutter/material.dart';
import 'package:hello_world/demo_inherit.dart';
import 'package:hello_world/hello_world.dart';
import 'package:hello_world/simple_stateful.dart';



/// 这里演示的是错误的例子，虽然能正确运行，不提倡；
SimpleDemoStateful simpleDemoStateful = SimpleDemoStateful(title: 'Global Widget Sample');

class ComposeTwoWidget extends StatelessWidget {
  const ComposeTwoWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.ltr,
      children: [
        simpleDemoStateful,//SimpleDemoStateful(title: 'simple StatefulWidget Demo',),
        Container(width:20,color: Theme.of(context).backgroundColor,),
        HelloWorld(),
        Container(width:20,color: Theme.of(context).backgroundColor,),
        InheritedDemo(),
      ],
    );
  }
}


