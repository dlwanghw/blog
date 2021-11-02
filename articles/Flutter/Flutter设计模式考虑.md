# Flutter 设计模式考虑

## 典型用例

* 用户按下命令Button，调用底层的服务
  * 快速完成，显示执行结果
  * 很慢完成，需要显示等待画面
  * 执行出错，需要显示出错画面，然后回退到迁移状态
  * 参考FlutterMVVM的教程，此时viewmodel承担了命令执行状态的中间状态的状态维护工作，使用数据绑定的机制，完成了View和ViewModle之间的数据映射，基于数据映射实现画面刷新
* 用户按下操作Button，不调用底层的服务
  * 页面内组件状态变化(如RadioButton被选中，或者Checkbox被选中)
    * 页面内的操作状态是一个中间状态，状态的维护有两个选择，一个是使用组件的状态进行维护，一个是使用独立出来的状态类维护。原则上超过一个组件的状态都需要独立出来维护。
    * 应用内页面很多的情况下如果单纯使用provider机制会带来问题：完整的状态是由多个类来维护，没有整体的印象，如果有状态之间的相互影响的问题，就会引发加大的降低维护性。
  * 页面要迁移
    要有应用内导航管理的设计
* 页面正常显示状态下，外部事件割入，原有画面置灰，显示新的popup画面
  * 要检讨★
* 是否需要支持多个View
	* 如果需要支持多个view，则必须使用mvvm，由vm来隔离model和view，使其能够独立变化
* 应用之间的通信：
  * 如果是同一进程(isolate)内，则使用databus是一个不错的主意
  * 如果将来是不同的进程，则应用间的通信问题如何来解决？
* 要解决的几个问题：
  * 应用与应用之间的通信：统一进程，使用eventbus，不同进程，使用什么呢？要检讨这个事情
  * 页面与页面的通信，或者说页面内组件与组件的通信：使用同一的state来进行通信，等价于flutter状态管理问题
  * 割入的问题
  * 如何来定义组件？
  * 
* 几点见解
  * 应用规模和复杂度的确定：整体如果作为一个大应用，则整体应用是很大的。如果是多进程应用架构，每个应用算是中等类型应用，不算是复杂的应用，使用bloc或者是provider是合理可控的。参考21mm的架构，多个应用间是隔离的，所以要基于多进程的架构为基础来考虑。
  * 当前使用websocket来和后端通信，使用bloc是非常合理的。BLOC的问题是不能使用太多，使用太多的stream会对内存造成负担，所以如果是多进程架构，倾向于使用bloc，如果是单进程架构，倾向于使用provider
  * 应用架构的构成可以是：model+service 、viewmodel、view三部分，整体采用mvvm架构模式来实现
  * 长列表优化是一个极大的问题，需要优先进行解决
  * 


## MVVM架构的定义



在angular中MVVM模式主要分为四部分：

* View：`它专注于界面的显示和渲染`，在angular中则是包含一堆声明式Directive的视图模板。
* ViewModel：`它是View和Model的粘合体，负责View和Model的交互和协作，它负责给View提供显示的数据，以及提供了View中Command事件操作Model的途径；`在angular中$scope对象充当了这个ViewModel的角色；
* Model：`它是与应用程序的业务逻辑相关的数据的封装载体，它是业务领域的对象，Model并不关心会被如何显示或操作，所以模型也不会包含任何界面显示相关的逻辑`。在web页面中，大部分Model都是来自Ajax的服务端返回数据或者是全局的配置对象；而angular中的service则是封装和处理这些与Model相关的业务逻辑的场所，这类的业务服务是可以被多个Controller或者其他service复用的领域服务。
* Controller：这并不是MVVM模式的核心元素，但它负责ViewModel对象的初始化，它将组合一个或者多个service来获取业务领域Model放在ViewModel对象上，使得应用界面在启动加载的时候达到一种可用的状态。

View不能直接与Model交互，而是通过ViewModel来实现与Model的交互。对于界面表单的交互，通过ngModel指令来实现View和ViewModel的同步。ngModelController包含$parsers和$formatters两个转换器管道，它们分别实现View表单输入值到Model数据类型转换和Model数据到View表单数据的格式化。对于用户界面的交互Command事件（如ngClick、ngChange等）则会转发到ViewModel对象上，通过ViewModel来实现对于Model的改变。然而对于Model的任何改变，也会反应在ViewModel之上，并且会通过$scope的“脏检查机制”（$digest）来更新到View。从而实现View和Model的分离，达到对前端逻辑MVVM的分层架构。



## Flutter的状态管理


参考资料

简单实现了view和model数据的绑定，当model数据变化时，view能够同步更新。此种方式比较简单，维护整个应用的状态可能要由多个状态对象构成。如果对大型应用就会带来管理上的混乱和逻辑上的不清晰。
> Flutter | 状态管理探索篇——Scoped Model（一）
https://www.jianshu.com/p/ed75beccb396

实现view和model的数据绑定的同时，将view和modle之间的接口使用action的方式来固化下来，进一步解耦view和modle。其复杂性高，针对多个页面的大型应用是比较好的，因为可以将这个应用的状态做更清晰的隔离和管理。
> Flutter | 状态管理探索篇——Redux（二）
https://www.jianshu.com/p/5d7e2dbdaea5

基于Stream-Reactive设计理念来封装的库，所以学习成本高些，效果是逻辑清晰，flutter官网上的资料推崇此种做法。
> Flutter | 状态管理探索篇——BLoC(三)
https://www.jianshu.com/p/7573dee97dbb
> Flutter | 状态管理拓展篇——RxDart(四)
https://www.jianshu.com/p/e0b0169a742e

## MVVM设计模式实现

参考资料

> flutter mvvm 模式
https://blog.csdn.net/prime_liu/article/details/103131965

## 