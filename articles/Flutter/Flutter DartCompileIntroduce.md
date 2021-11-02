## Dart VM



### Dart通过JIT解释执行Dart源码

``` dart
// hello.dart
main() => print('Hello, World!');
```

使用dart vm来解释执行

``` shell
$ dart hello.dart
Hello, World!
```



### Dart通过JIT从内核二进制执行

从 Dart 2 开始，VM 就不在具有直接从文字源码中直接执行的能力，而是 VM 期望被给到一份 *内核二进制(Kernel binaries)* (也被称为 *dill files*)， 它包含了序列化后的 [Kernel ASTs](https://github.com/dart-lang/sdk/blob/master/pkg/kernel/README.md)。这个把 Dart 源码翻译成 Kernel AST 的任务是由 [common front-end(CFE)](https://github.com/dart-lang/sdk/tree/master/pkg/front_end) 处理，它由 Dart 编写，在不同的 Dart 工具链中共享 (例如： VM, dart2js, Dart Dev Compiler)。

![dart cfe process](https://mrale.ph/dartvm/images/dart-to-kernel.png)



就算是使用dart2，仍然可以直接使用dart ***.dart来执行。这个其实现原理是：

Dart 也执行了一个辅助独立服务，叫做 *kernel service*，他控制了把 Dart 源码编译到内核代码，然后 VM 就直接执行内核二进制。

![kernel-service](https://mrale.ph/dartvm/images/kernel-service.png)



### Flutter的方式

Flutter 完全分离了 *编译(compilation)* 到 *内核(kernel)* 以及 *从内核执行(execution from Kernel)* 的步骤，放到了不同的设备中：开发机器负责编译，目标移动设备则负责执行，通过 *flutter* 工具发送接收内核二进制文件。

![flutter kernel to device](https://mrale.ph/dartvm/images/flutter-cfe.png)

需要注意的是，**flutter 工具并没有自己处理从 Dart 代码编译的过程，而是开辟了一条固定线程 *frontend_server*, 它是 CFEE 的简单包装，附带了简单的 Flutter 特殊的 Kernel-to-Kernel 转换。 *frontend_server* 编译 Dart 源码到内核文件，flutter 工具随后把它转发给设备。常驻的 *frontend_server* 进城是为了可以执行开发者们要求的 *hot reload* 功能：这种情况下， *frontend_server* 可以从前一个编译中重用 CFE 状态，然后只编译那些变化的部分**。



### Dart代码转换为快照，有VM执行

VM 可以序列化 isolate 的堆或驻留在堆中更加精确的对象图到一个二进制的 *快照(snapshot)* 中。快照随后可以被用来在启动 VM 独立域的时候重新创建相同的状态

![snapshot](https://mrale.ph/dartvm/images/snapshot.png)



## Flutter编译运行机制汇总



Flutter 工具启动一个线程 *frontend_server*, 它是 CFEE 的简单包装，附带了简单的 Flutter 特殊的 Kernel-to-Kernel 转换。 *frontend_server* 编译 Dart 源码到内核文件，flutter 工具随后把它转发给设备。

常驻的 *frontend_server* 进程是为了可以执行开发者们要求的 *hot reload* 功能：这种情况下， *frontend_server* 可以从前一个编译中重用 CFE 状态，然后只编译那些变化的部分。 

---

嵌入式平台使用Flutter的环境：

1. ***通过FlutterTools 执行命令：flutter build bundle 创建Flutter资产库***

2. ***使用定制的FlutterEngine flutter_wayland flutter_assets 将Flutter资产的目录传递给engine***

3. ***flutter engine通过flutter资产的目录找到应用的dart代码编译后的kernel文件进行执行***

4. ***应用dart代码调用flutter framework，进而调用flutter engine的核心功能接口***

---





## Flutter In Android



![截屏2020-11-13 上午11.01.07](/Users/a/Desktop/截屏2020-11-13 上午11.01.07.png)





![截屏2020-11-13 上午11.02.35](/Users/a/Desktop/截屏2020-11-13 上午11.02.35.png)



