import 'package:flutter/material.dart';
import 'package:hello_world/compose_widgets.dart';
import 'package:hello_world/demo_provider.dart';
import 'package:hello_world/demo_valuenotifier.dart';
import 'package:hello_world/simple_stateful.dart';
import 'package:hello_world/hello_stateful.dart';
import 'package:hello_world/hello_world.dart';
import 'package:hello_world/why_inherit.dart';

void main() {
  runApp(const MyApp());
}
/// Widget的概念：
/// Widget是最基础的概念，页面内所有的基础组件，组件组合之后的组件、或者一个页面都是Widget
/// 在flutter中，widget是以tree的形式来组织的，
/// Context的概念：
/// Context仅仅是已经创建的所有Widget树结构中，某个Widget的位置引用
/// 一个Context和Widget是一一对应的；
/// 如果一个WidgetA拥有子Widget，则Widget的Context是子Widget的Context的父Context
/// Element是Context的子类，更准确的说法：Element是Widget的实例，Widget是Element的配置信息
/// 在系统开始运行的时候，从根Context开始，开始从Widget树来构建Element树。
///
/// Widget有两种类型：StatelessWidget 和 StatefulWidget
/// StatelessWidget 一旦创建就不会发生任何变化，这句话容易引起误解，不是说在整个页面
/// 存续期间，StatelessWidget不会发生改变，因为在整个页面存续期间，其中某个局部发生变化
/// 如果StatelessWidget正处于要刷新的局部内， 则会重建。
///
/// 这样的StatelessWidget 只能使用构造函数传参来决定子Widget的装饰、尺寸、或者其他的一些子Widget的参数
/// 在build函数中，决定构建的子Widget是什么。
///
/// StatelessWidget 因为在创建之后不会发生改变，所以不会响应任何事件。也就是说任何用户操作
/// 都不会导致widget重绘，只有可能因为某种原因，导致Widget被重建。


/// StatefulWidget
/// 可以由于响应用户事件，而引起Widget重绘，这个说法不够精确，比较准确的说法是：
/// StatefulWidget 会将状态都保存到State对象里面，当State发生变更的时候，会触发
/// StatefulWidget 重新构建。
///
/// 所以严格来说，Widget都是只能重建，不会重绘。
/// StatefulWidget 支持重绘/局部刷新 是将StatefulWidget和State绑定在一起的外在表现的行为。
///
///
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  final String testString = 'This is String From MyApp';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyWhyInheritWidget(),//SimpleDemoStateful(title:'demo'),////ComposeTwoWidget(),//////const DemoStateful(title:'FlutterDemo'),//MyValueNotifierWidget()//ComposeTwoWidget()//MyWhyInheritWidget()////HelloWorld(),//SimpleDemoStateful(),//
    );
  }
}

