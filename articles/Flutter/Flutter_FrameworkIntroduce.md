### **1 引言**

在 Flutter 应用程序开发中，我们常常会使用使用Widget 、 BuildContext 、State 等等
例如：

当我们的数据更新时，我们需要刷新页面效果时使用用如下方法

```text
setState(() {
      
    });
```

又比如我们在使用主题颜色引用时像如下这样写 

```text
Theme.of(context).primaryColor
```

### **2 聊一聊 Widget**

Widget 我们可以理解为 Android、ios 中的 View ，前端中的 div , 在 Flutter 程序设计中，则是采用了 dom树的结构方式来组织起来的。

### **3 谈一谈 Context**

Context 是 Flutter 应用程序在通过 Widget 构建 Widgets树时的引用，应用像是 Android 中的 Context ,ios 中的CGContextRef ，我们通常称之为上下文对象。

一个Flutter 程序有 若干个 Widget 组成 Widgets 树形结构 ，而每一个 Widget 都对应一个 Context ,那么有 Widget 树结构，那么也必然有 Context 树形结构了。

### **4 说一说 State**

Flutter 应用程序是由 Widget 缓存的树形结构 ，在 Flutter 中，sdk 提供了两个 默认的 Widget 
\* StatelessWidget 渲染出的页面不会再次被更改
\* StatefulWidget 渲染出的页面会再次被更改

那么针对 StatefulWidget 这种 Widget 来讲，在实际开发中，渲染出的页面效果会随着数据的改变而改变，数据每改变一次那么页面重新渲染一次，每一次都对应一个状态，就是这里说的 State

在 React 的开发来讲

![img](https://pic1.zhimg.com/80/v2-c99189acaeee5027f0628c49555a5b7c_720w.jpg)


假如我们需要修改上术 state 引用的 date ，需要如下这样来写

```text
tick() {
    this.setState({
      date: new Date()
    });
  }
```

所以 Flutter 程序的设计中 State 与 React 的 State 大同小异，不过 Flutter 中的 State 设计的就更人性化了一点，一个 Widget 在被创建的时候就绑定了一个 State ,从 Widget 的出现 到消亡，也就是 Widget 的生命周期。

我们在创建一个 StatefulWidget 里通常会这样写

```text
class CustomScrollDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollHomePageState();
  }
}

class ScrollHomePageState extends State{
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }
  
  @override
  Widget build(BuildContext context) {
  }

}
```

initState() 方法是在创建 State 对象后要调用的第一个方法，常常用做于初始化一些数据

在实际开发中，我们有时会在这个方法中使用到 context ，比如初始化一个字体颜色时，我们如下这样调用

```text
Theme.of(context).primaryColor
```

常常会报错异常错误，这是因为 Context 可用 程序还没有完全将 State 与 Context 相关联起来，所以还不能使用，当 initState() 方法完全执行完毕后，State 与 Context 也就完全关联起来了。

didChangeDependencies() 方法是在 initState() 方法执行完毕后执行的第二个方法，在这个方法中， State 与 Context 已经完全关联起来了，所以可以使用 Context 

所以在 Flutter 中， StatefulWidget 、Context 、State 是一个不错的组合，当一个 Widget 继承于 StatefulWidget 来创建组件时，会调用StatefulWidget的 createElement方法，并t生成对就StatefulElement对象，

并保留widget引用也就是对应的 BuildContext ，

然后 将这个StatefulElement挂载到Element树上（也就是我们上面说的 Widgets树），

然后根据widget的 createState 方法创建State，

然后 StatefulElement对象调用state的build方法，并将element自身作为BuildContext传入

所以我们在build函数中所使用的context，正是当前widget所创建的Element对象，因为 context 就是 Element 元素的引用，实际指向。

### **5 看一看 of(context)方法**

在上述代码中，我们有如下的写法

```text
Theme.of(context).primaryColor
```

关键代码部分通过 **context.rootAncestorStateOfType** 向上遍历 Element tree，并找到最近匹配的 State。也就是说of实际上是对context跨组件获取数据的一个封装。







## 使用Flutter+MVVM模式



架构模式这种东西，跟你具体用什么语言、什么框架，关系不大。简单讲就是你怎么组织代码。便于逻辑清晰，更具条理。避免代码一整驼一整驼，甚至复制粘贴，全是重复、冗余代码。

***mvc -> mvp -> mvvm\***, 不断演进与升级。了解一下分别是什么后，`mvvm` 的一大优势便是 `view` 与 `model` 双向绑定，任何一方的变动，都可以通知到另外一方。而另外两个，*几乎是* 单方主动请求

## mvvm



![img](https://pic1.zhimg.com/80/v2-40ea831781ad2a0839766d4dd1f1da74_720w.jpg)



`viewModel` 作为 `view` 和 `model` 的中间者，处理`view`发出的请求，并在`model`数据等变化时，通知`view` 更新UI。

说起来很简单的样子。

## flutter项目 mvvm

### 1. 添加插件：`provider` , `rxdart`。 `pubspec.yaml` 文件



![img](https://pic3.zhimg.com/80/v2-90ec31b937e87f6af5a21b58e5a1f259_720w.jpg)



### 2. `view`， 构建UI，数据来源于`viewModel`

```dart
// file path : 'package:client/views/login_widget.dart'

import 'package:flutter/material.dart';

import 'package:client/view_models/login_view_model.dart'

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context); // 获取上层provider
    return Column(
      children: <Widget>[
        TextField(
          controller: viewModel.usernameController, // 方便viewModel 获取输入内容
        ),
        TextField(
          controller: viewModel.passwordController, // 方便viewModel 获取输入内容
        ),

        /// state 初始为 0，显示"登录" 字样；点击按钮后，加载过程值为 1；请求成功值为 2，显示对号
        FlatButton(
          child: viewModel.state == 0 
              ? Text("login")
              : (viewModel.state == 1
                  ? CircleAvatar(
                      backgroundColor: color,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                      maxRadius: 10)
                  : Icon(
                      Icons.done,
                      color: Colors.white,
                    )),
          onPressed: viewModel.login,
        )
      ],
    );
  }
}
```

### 3. `model`, 请求和处理

```dart
// file path : package:client/models/login_model.dart


class LoginModel {
    // 建立 future 对象的 observable
    Observable login(dynamic data) => Observable.fromFuture(
        http.post('http://api_url', body: data)
    );
}
```

### 4. `viewModel`

```dart
// file path : 'package:client/view_models/login_view_model.dart'

import 'package:client/models/login_model.dart';

/// with ChangeNotifer : 通过 notifyListeners() 函数，可以通知本对象数据的正在使用者们。 如 state 变量，在改变后调用 notifyListeners(), UI根据值重新构建登录按钮显示内容

class LoginViewModel with ChangeNotifier {
  final _model = LoginModel(); // model, 网络请求等处理

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  int state = 0;

  /// login 请求需要的数据
  get _data => {
    'username': usernameController.text,
    'password': passwordController.text
   };

  void login() =>_model.login(_data)
  .doOnListen((){state = 1; notifyListeners();}) // 请求过程，state = 1, 显示加载，通知UI
  .listen(// listen 接收两个参数，成功后的处理，失败后的处理。
      (res){ 
    state = res['result'] == 0 ? 2 : 0; // 登录成功时，回包中的result 字段为 0;
    notifyListeners();
  }, (_){ // 请求出错
      state = 0;
      notifyListeners();
  });
}
```

### `main`， 组装三者

```dart
// import 

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
    final _loginViewModel = LoginViewModel();
  @override
  Widget build(BuildContext context) =>
  /// ChangeNotifierProvider
   ChangeNotifierProvider.value(
        value: _loginViewModel,
        child: MaterialApp(
        home: LoginWidget()
    );
  }
}
```

## 效果图

- state == 0， 初始状态

![img](https://pic2.zhimg.com/80/v2-119bca62bacf37f7d85c7b41fe576e6d_720w.jpg)



- state == 1, 点击登录后，显示加载

![img](https://pic3.zhimg.com/80/v2-9a1b52c60de3e52475e8fcd6abf1c0bd_720w.jpg)



- state == 2, 登录成功

![img](https://pic3.zhimg.com/80/v2-44cedbe1fcac4833203a90f1d8e4be35_720w.jpg)



## ~λ：

- 只是简单例子。mvvm作为思想，怎么抽离数据和ui视具体情况而定，灵活解决
- 插件只是为了更好组织，而且差价来自flutter官方团队，并不是第三方野路子。善于利用工具
- 也可尝试用原生 `InheritedWidget` 及其附属内容自己封装出`provider`的效果