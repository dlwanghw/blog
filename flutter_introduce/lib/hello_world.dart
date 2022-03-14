import 'package:flutter/material.dart';
import 'package:hello_world/hello_stateful.dart';
import 'package:hello_world/main.dart';
import 'package:hello_world/simple_stateful.dart';

import 'compose_widgets.dart';

class HelloWorld extends StatelessWidget {
  const HelloWorld({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor, //颜色背景
        border: Border.all(
          color: Theme.of(context).unselectedWidgetColor,
          width: 5.0,
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        color: Theme.of(context).cardColor,
        child: Center(
          heightFactor: 2,
          child: Text(
            // 这里有几点要注意：
            // 1. 可以找到parent的widget，不能找到同级别的，或者在其他子树分支上的widget/state
            // 2. 如果要找到state，state默认都是包内受限访问，所以要破坏这个封装性，同时也满足上述widget的限制
            // 3. 除了这个方法，比如通过全局变量来获取，是不可信的，因为要意识到树是随时变化的,比如将这个替换成'${simpleDemoStateful.title}',
            //    为了完成上述的需求，需要将simpleDemoStateful设置为全局变量，但是这样一来，就很容易导致内存泄露
            // 4. 还有一个要注意的点：就是当使用热重载的时候，如果是final变量，是不会修改的，因为Final变量意味着赋值一次
            'Hello, world! ${context.findAncestorWidgetOfExactType<ComposeTwoWidget>()}',
            key: Key('title'),
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
      ),
    );
  }
}
