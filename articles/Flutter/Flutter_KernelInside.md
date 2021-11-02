[TOC]



# Flutter编译环境



## 问题背景



对于开发者而言，什么是Flutter？它是用什么语言编写的，包含哪几部分，是如何被编译，运行到设备上的呢？Flutter如何做到Debug模式Hot Reload快速生效变更，Release模式原生体验的呢？Flutter工程和我们的Android/iOS工程有何差别，关系如何，又是如何嵌入Android/iOS的呢？Flutter的渲染和事件传递机制如何工作？Flutter支持热更新吗？Flutter官方并未提供iOS下的armv7支持，确实如此吗？在使用Flutter的时候，如果发现了engine的bug，如何去修改和生效？构建缓慢或出错又如何去定位，修改和生效呢？

凡此种种，都需要对Flutter从设计，开发构建，到最终运行有一个全局视角的观察。

本文将以一个简单的hello_flutter为例，介绍下Flutter相关原理及定制与优化。



## Flutter简介





![img](https://pic3.zhimg.com/80/v2-b97521ab2a1df3b22a3f4a555cf56386_720w.jpg)



Flutter的架构主要分成三层:Framework，Engine和Embedder。

Framework使用dart实现，包括Material Design风格的Widget,Cupertino(针对iOS)风格的Widgets，文本/图片/按钮等基础Widgets，渲染，动画，手势等。此部分的核心代码是:flutter仓库下的flutter package，以及sky_engine仓库下的io,async,ui(dart:ui库提供了Flutter框架和引擎之间的接口)等package。

Engine使用C++实现，主要包括:Skia,Dart和Text。Skia是开源的二维图形库，提供了适用于多种软硬件平台的通用API。其已作为Google Chrome，Chrome OS，Android, Mozilla Firefox, Firefox OS等其他众多产品的图形引擎，支持平台还包括Windows7+,macOS 10.10.5+,iOS8+,Android4.1+,Ubuntu14.04+等。Dart部分主要包括:Dart Runtime，Garbage Collection(GC)，如果是Debug模式的话，还包括JIT(Just In Time)支持。Release和Profile模式下，是AOT(Ahead Of Time)编译成了原生的arm代码，并不存在JIT部分。Text即文本渲染，其渲染层次如下:衍生自minikin的libtxt库(用于字体选择，分隔行)；HartBuzz用于字形选择和成型；Skia作为渲染/GPU后端，在Android和Fuchsia上使用FreeType渲染，在iOS上使用CoreGraphics来渲染字体。



![img](https://pic2.zhimg.com/80/v2-b4dc1aad7cb87154339bc677ed5a7f51_720w.jpg)



Embedder是一个嵌入层，即把Flutter嵌入到各个平台上去，这里做的主要工作包括渲染Surface设置,线程设置，以及插件等。从这里可以看出，Flutter的平台相关层很低，平台(如iOS)只是提供一个画布，剩余的所有渲染相关的逻辑都在Flutter内部，这就使得它具有了很好的跨端一致性。



## Flutter工程结构



本文使用开发环境为flutter beta v0.3.1，对应的engine commit:09d05a389。

以hello_flutter工程为例，Flutter工程结构如下所示:



![img](https://pic3.zhimg.com/80/v2-672567876f7907de590fc21153388a6a_720w.jpg)



其中ios为iOS部分代码，使用CocoaPods管理依赖，android为Android部分代码，使用Gradle管理依赖，lib为dart代码，使用pub管理依赖。类似iOS中Cocoapods的Podfile和Podfile.lock，pub下对应的是pubspec.yaml和pubspec.lock。



## Flutter模式



对于Flutter，它支持常见的debug,release,profile等模式，但它又有其不一样。

Debug模式：对应了Dart的JIT模式，又称检查模式或者慢速模式。支持设备，模拟器(iOS/Android)，此模式下打开了断言，包括所有的调试信息，服务扩展和Observatory等调试辅助。此模式为快速开发和运行做了优化，但并未对执行速度，包大小和部署做优化。Debug模式下，编译使用JIT技术，支持广受欢迎的亚秒级有状态的hot reload。

Release模式：对应了Dart的AOT模式，此模式目标即为部署到终端用户。只支持真机，不包括模拟器。关闭了所有断言，尽可能多地去掉了调试信息，关闭了所有调试工具。为快速启动，快速执行，包大小做了优化。禁止了所有调试辅助手段，服务扩展。

Profile模式：类似Release模式，只是多了对于Profile模式的服务扩展的支持，支持跟踪，以及最小化使用跟踪信息需要的依赖，例如，observatory可以连接上进程。Profile并不支持模拟器的原因在于，模拟器上的诊断并不代表真实的性能。

鉴于Profile同Release在编译原理等上无差异，本文只讨论Debug和Release模式。

事实上flutter下的iOS/Android工程本质上依然是一个标准的iOS/Android的工程，flutter只是通过在BuildPhase中添加shell来生成和嵌入App.framework和Flutter.framework(iOS),通过gradle来添加flutter.jar和vm/isolate_snapshot_data/instr(Android)来将Flutter相关代码编译和嵌入原生App而已。因此本文主要讨论因flutter引入的构建，运行等原理。编译target虽然包括arm,x64,x86,arm64，但因原理类似，本文只讨论arm相关(如无特殊说明，android默认为armv7)。



## Flutter代码的编译与运行(iOS)



## Release模式下的编译



Release模式下，flutter下iOS工程dart代码构建链路如下所示:



![img](https://pic4.zhimg.com/80/v2-a5418d7ba1bc2e7c1b4d2e8c3104c42f_720w.jpg)



其中gen_snapshot是dart编译器，采用了tree shaking(类似依赖树逻辑，可生成最小包，也因而在Flutter中禁止了dart支持的反射特性)等技术，负责生成汇编形式机器代码。再通过xcrun等工具链生成最终的App.framework。所有的dart代码，包括业务代码，三方package代码，它们所依赖的flutter框架代码，最终将会编译成App.framework。

PS.tree shaking功能位于gen_snapshot中，对应逻辑参见: engine/src/third_party/dart/runtime/vm/compiler/aot/[http://precompiler.cc](https://link.zhihu.com/?target=http%3A//precompiler.cc)

dart代码最终对应到App.framework中的符号如下所示:



![img](https://pic4.zhimg.com/80/v2-8886c78ae1edc5bbd67fb8825552839b_720w.jpg)



事实上，类似Android Release下的产物(见下文)，App.framework也包含了kDartVmSnapshotData，kDartVmSnapshotInstructions，kDartIsolateSnapshotData，kDartIsolateSnapshotInstructions四个部分。为什么iOS使用App.framework这种方式，而不是Android的四个文件的方式呢？原因在于在iOS下，因为系统的限制，Flutter引擎不能够在运行时将某内存页标记为可执行，而Android是可以的。

Flutter.framework对应了Flutter架构中的engine部分，以及Embedder。实际中Flutter.framework位于flutter仓库的/bin/cache/artifacts/engine/ios*下，默认从google仓库拉取。当需要自定义修改的时候，可通过下载engine源码，利用Ninja构建系统来生成。

Flutter相关代码的最终产物是:App.framework(dart代码生成)和Flutter.framework(引擎)。从Xcode工程的视角看，Generated.xcconfig描述了Flutter相关环境的配置信息，然后Runner工程设置中的Build Phases新增的xcode_backend.sh实现了Flutter.framework的拷贝(从Flutter仓库的引擎到Runner工程根目录下的Flutter目录)与嵌入，App.framework的编译与嵌入。最终生成的Runner.app中Flutter相关内容如下所示:



![img](https://pic1.zhimg.com/80/v2-defcd43a02d1ef2ae741fbd70e258038_720w.jpg)



其中flutter_assets是相关的资源，代码则是位于Frameworks下的App.framework和Flutter.framework。



## Release模式下的运行



Flutter相关的渲染，事件，通信处理逻辑如下所示:



![img](https://pic4.zhimg.com/80/v2-49729b9595140648ff181688f146849f_720w.jpg)



其中dart中的main函数调用栈如下:



![img](https://pic2.zhimg.com/80/v2-3c32d4c859135a25f9a2e941fb55af71_720w.jpg)





## Debug模式下的编译



Debug模式下flutter的编译，结构类似Release模式，差异主要表现为两点:

1.Flutter.framework

因为是Debug，此模式下Framework中是有JIT支持的，而在Release模式下并没有JIT部分。

2.App.framework

不同于AOT模式下的App.framework是Dart代码对应的机器代码，JIT模式下，App.framework只有几个简单的API，其Dart代码存在于snapshot_blob.bin文件里。这部分的snapshot是脚本快照，里面是简单的标记化的源代码。所有的注释，空白字符都被移除，常量也被规范化，没有机器码，tree shaking或混淆。

App.framework中的符号表如下所示:



![img](https://pic3.zhimg.com/80/v2-0af896169e9add72cf01bc60661f0f6a_720w.jpg)



对Runner.app/flutter_assets/snapshot_blob.bin执行strings命令可以看到如下内容:



![img](https://pic2.zhimg.com/80/v2-daa36329f386ef74d21814b1606b6f69_720w.jpg)



Debug模式下main入口的调用堆栈如下:



![img](https://pic3.zhimg.com/80/v2-3768e92367c3add4bb17760ed5f5d8e6_720w.jpg)





## Flutter代码的编译与运行(Android)



鉴于Android和iOS除了部分平台相关的特性外，其他逻辑如Release对应AOT，Debug对应JIT等均类似，此处只涉及两者不同。 



## Release模式下的编译



release模式下，flutter下Android工程中dart代码整个构建链路如下所示:



![img](https://pic3.zhimg.com/80/v2-e82be70628cab4d5eca74e79d04c69ce_720w.jpg)



其中vm/isolate_snapshot_data/instr内容均为arm指令，其中vm_中涉及runtime等服务(如gc)，用于初始化DartVM，调用入口见Dart_Initialize(dart_api.h)。isolate__则对应了我们的应用dart代码，用于创建一个新的isolate,调用入口见Dart_CreateIsolate(dart_api.h)。flutter.jar类似iOS的Flutter.framework，包括了Engine部分(Flutter.jar中的libflutter.so)，和Embedder部分(FlutterMain,FlutterView,FlutterNativeView等)。实际中flutter.jar位于flutter仓库的/bin/cache/artifacts/engine/android*下，默认从google仓库拉取。需要自定义修改的时候，可通过下载engine源码，利用Ninja构建系统来生成flutter.jar。

以isolate_snapshot_data/instr为例，执行disarm命令结果如下:



![img](https://pic4.zhimg.com/80/v2-4baf73f655ed04a0fc9ea12f811c1dcb_720w.jpg)





![img](https://pic4.zhimg.com/80/v2-e52e38f4de25a4c73f4edda9249a3357_720w.jpg)

)

其Apk结构如下所示:



![img](https://pic1.zhimg.com/80/v2-311db7052362eadace9968f3a9b3512c_720w.jpg)



APK新安装之后，会根据一个判断逻辑(packageinfo中的versionCode结合lastUpdateTime)来决定是否拷贝APK中的assets，拷贝后内容如下所示:



![img](https://pic2.zhimg.com/80/v2-23ed83435242e8d3bc309d5ce5d11b71_720w.jpg)



isolate/vm_snapshot_data/instr均最后位于app的本地data目录下，而此部分又属于可写内容，可通过下载并替换的方式，完成App的动态更新。



## Release模式下的运行





![img](https://pic4.zhimg.com/80/v2-3f93d2609ac5d0b25bd32dadd104b5b3_720w.jpg)





## Debug模式下的编译



类似iOS的Debug/Release的差别，Android的Debug与Release的差异主要包括以下两部分:

1.flutter.jar

区别同iOS

2.App代码部分

位于flutter_assets下的snapshot_blob.bin，同iOS。

在介绍了iOS/Android下的Flutter编译原理后，下面介绍下如何定制flutter/engine以完成定制和优化。鉴于Flutter处于敏捷的迭代中，现有的问题后续不一定是问题，因而此部分并不是要解决多少问题，而是说明不同问题下的解决思路。



## Flutter构建相关的定制与优化



Flutter是一个很复杂的系统，除了上述提到的三层架构中的内容外，还包括Flutter Android Studio(Intellij)插件，pub仓库管理等。但我们的定制和优化往往是flutter的工具链相关逻辑，其逻辑位于flutter仓库的flutter_tools包。下面举例说明下如何针对此部分做定制。



## Android部分



相关内容包括flutter.jar，libflutter.so(位于flutter.jar下)，gen_snapshot，flutter.gradle，flutter(flutter_tools)。

1.限定Android中target为armeabi

此部分属于构建相关，逻辑位于flutter.gradle下。当App是通过armeabi支持armv7/arm64的时候，需要修改flutter的默认逻辑。如下所示:



![img](https://pic4.zhimg.com/80/v2-4fb24af890e6a12f4df6c1fbdf58da03_720w.jpg)



因为gradle本身的特点，此部分修改后直接构建即可生效。

2.设定Android启动时默认使用第一个launchable-activity

此部分属于flutter_tools相关，修改如下:



![img](https://pic3.zhimg.com/80/v2-4b77101b0d4917a81af6cb21bd87c82a_720w.jpg)



这里的重点不是如何去修改，而是如何去让修改生效。原理上，flutter run/build/analyze/test/upgrade等命令实际上执行的都是flutter(flutter/bin/flutter)这一脚本，再透过dart执行flutter_tools.snapshot(通过packages/flutter_tools生成)，逻辑如下:



```text
if [[ ! -f "SNAPSHOT_PATH" ]] || [[ ! -s "STAMP_PATH" ]] || [[ "(cat "STAMP_PATH")" != "revision" ]] || [[ "FLUTTER_TOOLS_DIR/pubspec.yaml" -nt "$FLUTTER_TOOLS_DIR/pubspec.lock" ]]; then
        rm -f "$FLUTTER_ROOT/version"
        touch "$FLUTTER_ROOT/bin/cache/.dartignore"
        "$FLUTTER_ROOT/bin/internal/update_dart_sdk.sh"
        echo Building flutter tool...
    if [[ "$TRAVIS" == "true" ]] || [[ "$BOT" == "true" ]] || [[ "$CONTINUOUS_INTEGRATION" == "true" ]] || [[ "$CHROME_HEADLESS" == "1" ]] || [[ "$APPVEYOR" == "true" ]] || [[ "$CI" == "true" ]]; then
      PUB_ENVIRONMENT="$PUB_ENVIRONMENT:flutter_bot"
    fi
    export PUB_ENVIRONMENT="$PUB_ENVIRONMENT:flutter_install"

    if [[ -d "$FLUTTER_ROOT/.pub-cache" ]]; then
      export PUB_CACHE="${PUB_CACHE:-"$FLUTTER_ROOT/.pub-cache"}"
    fi

    while : ; do
      cd "$FLUTTER_TOOLS_DIR"
      "$PUB" upgrade --verbosity=error --no-packages-dir && break
      echo Error: Unable to 'pub upgrade' flutter tool. Retrying in five seconds...
      sleep 5
    done
    "$DART" --snapshot="$SNAPSHOT_PATH" --packages="$FLUTTER_TOOLS_DIR/.packages" "$SCRIPT_PATH"
    echo "$revision" > "$STAMP_PATH"
    fi
```





不难看出要重新构建flutter_tools，可以删除flutter_repo_dir/bin/cache/flutter_tools.stamp(这样重新生成一次)，或者屏蔽掉if/fi判断(每一次都会重新生成)。

3.如何在Android工程Debug模式下使用release模式的flutter

研发中如果发现flutter有些卡顿，可能是逻辑的原因，也可能是是Debug模式。此时可以构建release下的apk，也可以将flutter强制修改为release模式如下:



![img](https://pic3.zhimg.com/80/v2-a10895702899fd2f5fc576f41a98b57e_720w.jpg)





## iOS部分



相关内容包括:Flutter.framework，gen_snapshot，xcode_backend.sh，flutter(flutter_tools)。

1.优化构建过程中反复替换Flutter.framework导致的重新编译

此部分逻辑属于构建相关，位于xcode_backend.sh中，Flutter为了保证获取到正确的Flutter.framework,每次都会基于配置(见Generated.xcconfig配置)查找和替换Flutter.framework，这也导致工程中对此Framework有依赖代码的重新编译，修改如下:



![img](https://pic1.zhimg.com/80/v2-f67015ea8785af7f1200e9d7998fbce8_720w.jpg)



2.如何在iOS工程Debug模式下使用release模式的flutter

 将Generated.xcconfig中的FLUTTER_BUILD_MODE修改为release，FLUTTER_FRAMEWORK_DIR修改为release对应的路径即可。

3.armv7的支持

原始文章请参见:[https://github.com/flutter/engine/wiki/iOS-Builds-Supporting-ARMv7](https://link.zhihu.com/?target=https%3A//github.com/flutter/engine/wiki/iOS-Builds-Supporting-ARMv7)

事实上flutter本身是支持iOS下的armv7的，但v0.3.1下并未提供官方支持，需自行修改相关逻辑，具体如下:

a.默认的逻辑可以生成Flutter.framework(arm64)

b.修改flutter以使得flutter_tools可以每次重新构建，修改build_aot.dart和mac.dart，将针对iOS的arm64修改为armv7,修改gen_snapshot为i386架构。

其中i386架构下的gen_snapshot可通过以下命令生成:



```text
./flutter/tools/gn --runtime-mode=release --ios --ios-cpu=arm
ninja -C out/ios_release_arm
```





这里有一个隐含逻辑:

构建gen_snapshot的CPU相关预定义宏(x86_64/i386等)，目标gen_snapshot的arch，最终的App.framework的架构整体上要保持一致。即x86_64->x86_64->arm64或者i386->i386->armv7。

c.在iPhone4S上，会发生因gen_snapshot生成不被支持的SDIV指令而造成EXC_BAD_INSTRUCTION(EXC_ARM_UNDEFINED)错误，可通过给gen_snapshot添加参数--no-use-integer-division实现(位于build_aot.dart)。其背后的逻辑(dart编译arm代码逻辑流)如下图所示:



![img](https://pic1.zhimg.com/80/v2-5d2c70c71c21dac1ac1f429e48553038_720w.jpg)



d.基于a和b生成的Flutter.framework,将其lipo create生成同时支持armv7和arm64的Flutter.framework。

e.修改Flutter.framework下的Info.plist，移除



```text
<key>UIRequiredDeviceCapabilities</key>
  <array>
    <string>arm64</string>
  </array>
```





同理，对于App.framework也要作此操作，以免上架后会受到App Thining的影响。

# Flutter调试

## flutter_tools的调试



如果想了解flutter如何构建debug模式下apk时，具体执行的逻辑如何，可以参考下面的思路:

a.了解flutter_tools的命令行参数



![img](https://pic3.zhimg.com/80/v2-6ab517c54d7fd41bfa6330fe5e1adb8a_720w.jpg)



b.以dart工程形式打开packages/flutter_tools，基于获得的参数修改flutter_tools.dart，设置命令行dart app即可开始调试。



![img](https://pic1.zhimg.com/80/v2-360b7f07d3d4049da8dba9539e884758_720w.jpg)





## 定制engine与调试



假设我们在flutter beta v0.3.1的基础上进行定制与业务开发，为了保证稳定，一定周期内并不升级SDK，而此时，flutter在master上修改了某个v0.3.1上就有的bug，记为fix_bug_commit。如何才能跟踪和管理这种情形呢？

1.flutter beta v0.3.1指定了其对应的engine commit为:09d05a389，见flutter/bin/internal/engine.version。

2.[获取engine代码](https://link.zhihu.com/?target=https%3A//github.com/flutter/engine/blob/master/CONTRIBUTING.md)

3.因为2中拿到的是master代码，而我们需要的是特定commit(09d05a389)对应的代码库，因而从此commit拉出新分支:custom_beta_v0.3.1。

4.基于custom_beta_v0.3.1(commit:09d05a389)，执行gclient sync，即可拿到对应flutter beta v0.3.1的所有engine代码。

5.使用git cherry-pick fix_bug_commit将master的修改同步到custom_beta_v0.3.1，如果修改有很多对最新修改的依赖，可能会导致编译失败。

6.对于iOS相关的修改执行以下代码:



```text
./flutter/tools/gn --runtime-mode=debug --ios --ios-cpu=arm
ninja -C out/ios_debug_arm

./flutter/tools/gn --runtime-mode=release --ios --ios-cpu=arm
ninja -C out/ios_release_arm

./flutter/tools/gn --runtime-mode=profile --ios --ios-cpu=arm
ninja -C out/ios_profile_arm

./flutter/tools/gn --runtime-mode=debug --ios --ios-cpu=arm64
ninja -C out/ios_debug

./flutter/tools/gn --runtime-mode=release --ios --ios-cpu=arm64
ninja -C out/ios_release

./flutter/tools/gn --runtime-mode=profile --ios --ios-cpu=arm64
ninja -C out/ios_profile
```





即可生成针对iOS的arm/arm64&debug/release/profile的产物。可用构建产物替换flutter/bin/cache/artifacts/engine/ios*下的Flutter.framework和gen_snapshot。

如果需要调试Flutter.framework源代码，构建的时候命令如下:



```text
./flutter/tools/gn --runtime-mode=debug --unoptimized --ios --ios-cpu=arm64
ninja -C out/ios_debug_unopt
```





用生成产物替换掉flutter中的Flutter.framework和gen_snapshot，即可调试engine源代码。

7.对于Android相关的修改执行以下代码:



```text
./flutter/tools/gn --runtime-mode=debug --android --android-cpu=arm
ninja -C out/android_debug

./flutter/tools/gn --runtime-mode=release --android --android-cpu=arm
ninja -C out/android_release

./flutter/tools/gn --runtime-mode=profile --android --android-cpu=arm
ninja -C out/android_profile
```





即可生成针对Android的arm&debug/release/profile的产物。可用构建产物替换flutter/bin/cache/artifacts/engine/android*下的gen_snapshot和flutter.jar。





# Dart和C++绑定

## Dart绑定层如何工作

出于性能或者跨平台或其他原因，脚本语言或者基于虚拟机的语言都会提供c/c++或函数对象绑定到具体语言对象的接口，以便在语言中接着操控c/c++对象或函数，这层API称为绑定层。例如: 最易嵌入应用程序中的[Lua binding](https://link.zhihu.com/?target=http%3A//lua-users.org/wiki/BindingCodeToLua) ，[Javascript V8 引擎的binding](https://link.zhihu.com/?target=http%3A//pmed.github.io/v8pp/wrapping.html) 等等。

Dart虚拟机在初始化时，会将C++声明的某个类或者函数和某个函数和Dart中的某个类或者绑定起来，依次注入Dart运行时的全局遍历中，当Dart代码执行某一个函数时，便是指向具体的C++对象或者函数。

下面是几个常见的绑定的几个c++类和对应的Dart类

> flutter::EngineLayer --> ui.EngineLayer
> flutter::FrameInfo --> ui.FrameInfo
> flutter::CanvasImage --> ui.Image
> flutter::SceneBuilder --> ui.SceneBuilder
> flutter::Scene --> ui.Scene

以`ui.SceneBuilder`一个例子了解下Dart是如何绑定c++对象实例，并且控制这个c++实例的析构工作。

> Dart层渲染过程是配置的layer渲染树，并且提交到c++层进行渲染的过程。`ui.SceneBuilder`便是这颗渲染树的容器



![img](https://pic3.zhimg.com/80/v2-7467013a0cd158f713385fefff2eceee_720w.jpg)



1. Dart代码调用构造函数`ui.SceneBuilder()`时，调用c++方法`SceneBuilder_constructor`
2. 调用`flutter::SceneBuilder`的构造方法并生成c++实例sceneBuilder
3. 因`flutter::SceneBuilder` 继承自内存计数对象`RefCountedDartWrappable`，对象生成后会内存计数加1
4. 将生成c++实例sceneBuilder使用Dart的API生成一个`WeakPersitentHandle`，注入到Dart上下中。在这里之后，Dart便可使用这个`builder`对象，便可操作这个c++的`flutter::SceneBuilder`实例。
5. 程序运行许久后，当Dart虚拟机判断Dart 对象builder没有被任何其他对象引用时（例如简单的情况是被置空builder=null，也称为无可达性），对象就会被垃圾回收器（Garbage Collection）回收释放，内存计数将会减一
6. 当内存计数为0时，会触发c++的析构函数，最终c++实例指向的内存块被回收

**可以看到，Dart是通过将C/C++实例封装成WeakPersitentHandle且注入到Dart上下文的方式，从而利用Dart虚拟机的GC（Garbage Collection）来控制C/C++实例的创建和释放工作**

更直白而言，只要C/C++实例对应的Dart对象能正常被GC回收，C/C++所指向的内存空间便会正常释放。

### WeakPersistentHandle是什么

因为Dart对象在VM中会因为GC整理碎片化中经常移动，所以使用对象时不会直接指向对象，而是使用句柄（handle）的方式间接指向对象，再者c/c++对象或者实例是介乎于Dart虚拟机之外，生命周期不受作用域约束，且一直长时间存在于整个Dart虚拟机中，所以称为常驻（Persistent），所以WeakPersistentHandle专门指向生命周期与常在的句柄，在Dart中专门用来封装C/C++实例。

在flutter官方提供的Observatory工具中，可以查看所有的WeakPersistentHandle对象 

![img](https://pic2.zhimg.com/80/v2-0da4e1b0d3c3a56a87de35d372f3884d_720w.jpg)



其中Peer这栏也就是封装c/c++对象的指针



![img](https://pic4.zhimg.com/80/v2-8b8592dfba64959d88d48b15562d5b03_720w.jpg)





# Flutter渲染

## Flutter的渲染原理



Flutter的UI Task Runner负责执行Dart代码，而Flutter的渲染管线也是在UI Task Runner中运行的。每次Flutter App的界面需要更新时，Framework会通过ui.window.scheduleFrame通知Engine。然后Engine会注册一个Vsync信号的回调，在下一个VSync信号到来之际，Engine会通过ui.window.onBeginFrame和ui.window.onDrawFrame回调给Framework来驱动Flutter渲染管线，渲染管线中的Build、Layout、Paint一一被执行，生成了最新的Layer Tree。最后Layer Tree通过ui.window.render发送到了Engine端，交给GPU Task Runner做光栅化与上屏。



![img](https://pic4.zhimg.com/80/v2-eb9540482e9fa8d6485f5e900e1a0a9f_720w.jpg)





## 使用Flutter的渲染原理来检测卡顿现象



 使用Flutter技术构建的应用，一直以高性能高流畅度著称。但是随着应用复杂度越来越高，Flutter会出现一些页面流畅度明显低于Native的情况，甚至可能发生一些卡顿。而很多时候卡顿都发生在线上，即使获得了用户的操作路径，也难以重现。如果我们有一套卡顿监控系统，能够帮助我们捕获到卡顿时的堆栈，那么在发生卡顿的时候，我们就可以定位到具体是哪个函数引起的卡顿，从而解决这些问题。

 既然想要设计一个卡顿监控系统，那么我们就需要先解决两个问题：一个是如何判断当前发生了卡顿，另一个是如何在卡顿时获取堆栈。其中卡顿部分我们结合了Flutter渲染原理给出了一个方案，而获取堆栈部分我们则陆续探索了三个方案。

## 1. 如何判断卡顿

 既然我们希望能够抓取Flutter的卡顿堆栈，那么首先我们得先有办法判断Flutter App是否发生卡顿。为此，我们先来简单回顾一下Flutter的渲染原理。Flutter的UI Task Runner负责执行Dart代码，而Flutter的渲染管线也是在UI Task Runner中运行的。每次Flutter App的界面需要更新时，Framework会通过ui.window.scheduleFrame通知Engine。然后Engine会注册一个Vsync信号的回调，在下一个VSync信号到来之际，Engine会通过ui.window.onBeginFrame和ui.window.onDrawFrame回调给Framework来驱动Flutter渲染管线，渲染管线中的Build、Layout、Paint一一被执行，生成了最新的Layer Tree。最后Layer Tree通过ui.window.render发送到了Engine端，交给GPU Task Runner做光栅化与上屏。



![img](https://pic4.zhimg.com/80/v2-eb9540482e9fa8d6485f5e900e1a0a9f_720w.jpg)



 我们可以定义一个卡顿阈值，在ui.window.onBeginFrame开始计时，在ui.window.onDrawFrame做好卡口，如果渲染管线的执行时间过长，大于卡顿阈值，那么我们就可以判断发生了卡顿。

 如果等到我们判断出了当前发生了卡顿，再去采集堆栈，为时已晚。因此，我们需要另外起一个Isolate，每隔一小段时间就去采集一次root Isolate的堆栈，那么当我们判断出现卡顿时，只要将从卡顿开始到卡顿结束的这段时间采集到的堆栈做一次聚合，就能知道是哪个方法引起了卡顿了。

 举个例子，如果我们定义的卡顿阈值为100ms，然后每隔5ms采集一次卡顿堆栈，假设ui.window.onBeginFrame开始到ui.window.onDrawFrame结束总共耗时200ms，其中foo方法耗时160ms，bar方法耗时30ms，其余方法耗时10ms。那么在这段时间，我们一共能采集到40个堆栈，其中有32个堆栈的栈顶为foo方法，6个堆栈的栈顶为bar方法。在堆栈聚合后，我们就能发现foo方法的耗时大约为160ms，而bar方法的耗时大约为30ms。

 这个方案看上去比较简单，整体思路上也是借鉴了Android端的卡顿检测框架BlockCanary，那么这个方案是否可行呢？我们需要解决的第一个问题，就是如何在另一个Isolate去采集root Isolate的堆栈。

## 2. 堆栈采集方案一：修改Dart SDK

 在Dart中，我们可以通过调用StackTrace.current来获取当前Isolate的调用栈。那么它能否帮助我们获取卡顿时候的堆栈呢？非常可惜，它做不到这一点。

 举个例子：假设我们有一个名叫foo的方法，耗时大概300ms，在root Isolate中执行，很明显，这个方法会引起卡顿。而StackTrace.current并不能获取帮助我们定位到这个耗时的foo方法。我们需要的，是在另一个Isolate中采集到root Isolate堆栈的方法。

### 2.1. 官方与之相关的Issue

 并不是只有我们有这个诉求，google的同学在flutter的repo下，提了Issue：[Add API to query main Isolate's stack trace #37204](https://link.zhihu.com/?target=https%3A//github.com/flutter/flutter/issues/37204)。这个Issue的大致内容是说，希望Dart能够提供一个API，用于在另一个Isolate去采集main Isolate堆栈，当前这个Issue还是open的状态。

 Issue提出到现在大概已经过去一年时间了，为什么这个API还是没有实现呢？其实，实现这个API本身并不困难，只是官方有一些自己的考量，其中之一就是这可能会引入安全性问题：Dart Isolate之间本应该相互隔离，如果添加了这个API，那么可能会有黑客通过多次调用该API来获取大量的堆栈信息，再通过比对这些堆栈的差异来对加密秘钥发起定时攻击等。看来官方短期之内是不会提供这个API了，那么我们是不是可以先试试通过修改Dart SDK来实现类似的功能。

### 2.2. 通过修改Dart SDK提供API

 我们先来看看StackTrace.current是如何获取堆栈的吧

```dart
//dart/sdk/lib/core/stacktrace.dart
abstract class StackTrace {
  StackTrace(); // In case existing classes extend StackTrace.

  external static StackTrace get current;
}
```

 我们可以看到，StackTrace.current方法的修饰符中有一个external，这代表了这是一个external函数，Dart中的external函数意味着这个函数的声明和实现是分开的，这里只是声明，实现在另一个地方，其实现的地方如下：

```dart
//dart/sdk/lib/_internal/vm/lib/core_patch.dart

@patch
class StackTrace {
  @patch
  static StackTrace get current native "StackTrace_current";
}
```

 从StackTrace.current的实现中有一个native关键字，native关键字是Dart的Native Extension的关键字，意味着这个方法是C/C++实现的。Native Extension与Java中的JNI非常的相似。

```cpp
//dart/runtime/lib/stacktrace.cc

DEFINE_NATIVE_ENTRY(StackTrace_current, 0, 0) {
  return CurrentStackTrace(thread, false);
}

static RawStackTrace* CurrentStackTrace(
    Thread* thread,
    bool for_async_function,
    intptr_t skip_frames = 1,
    bool causal_async_stacks = FLAG_causal_async_stacks) {
  if (!causal_async_stacks) {
    // Return the synchronous stack trace.
    return CurrentSyncStackTrace(thread, skip_frames);
  }

  ......

  const StackTrace& result = StackTrace::Handle(
      zone, StackTrace::New(code_array, pc_offset_array, async_stack_trace,
                            sync_async_end));

  return result.raw();
}
```

 我们终于找到了实现，CurrentStackTrace，通过观察发现，它的第一个参数是一个thread。可见CurrentStackTrace方法获取的堆栈是基于thread的，那么是不是说，如果我们在另一个Isolate中，将root Isolate对应的Thread作为参数，传入到CurrentStackTrace方法里，就能获得root Isolate对应的堆栈了呢？

 为了验证我们这个想法，我们新增了两个方法：StackTrace.prepare和StackTrace.root，我们在root Isolate 中调用StackTrace.prepare，将root Isolate的thread对象使用静态变量rootIsolateThread保存起来。StackTrace.prepare对应的C++实现如下

```cpp
static Thread *rootIsolateThread;

DEFINE_NATIVE_ENTRY(StackTrace_prepare, 0, 0) {
  rootIsolateThread = Thread::Current();
  return Object::null();
}
```

 然后我们新开一个Isolate，在这个新的Isolate中，我们调用StackTrace.root来获取root Isolate的堆栈，StackTrace.root对应的C++实现如下

```cpp
DEFINE_NATIVE_ENTRY(StackTrace_prepare, 0, 0) {
  return CurrentStackTrace(rootIsolateThread, false)
}
```

 经过验证发现，通过这个方案，的确能在另一个Isolate中获取root Isolate的堆栈。当然上面的修改主要还是为了验证可行性，如果真的要采用修改Dart SDK的方案，还有非常多的地方需要考虑。

 修改Dart SDK的这个方案大大增加了后期的维护成本，有没有可能存在一种不修改Dart SDK，还是能获取到堆栈的方案呢？

## 3. 堆栈采集方案二：AOT模式下采集堆栈（暂停线程）

 在不修改Dart SDK的前提下获取堆栈，听上去感觉是一个不可能完成的任务。但是有时候我们遇到了问题，或许转变一下思路，就能找到答案。

### 3.1. AOT模式与符号表

 让我们一起来梳理一下我们的诉求，首先我们设计的是一个线上卡顿监控方案，这个场景下的Dart代码是基于AOT编译的，在iOS端其产物为App.framework，在Android端则为libapp.so。基于AOT，也就意味着Dart代码（包括SDK和你自己的）会被编译成平台相关的机器码。

 那么Dart语言AOT编译生成的可执行程序与C语言编译生成的可执行程序，是否有区别呢？从操作系统的角度来看，它们并没有什么本质区别。操作系统只关心这个可执行程序如何加载，如何执行，至于程序是从C语言还是Dart语言编译过来的，它并不关心。

 我们先来把目光聚焦到Dart代码在iOS端profile模式下的产物App.framework。从iOS的视角触发，这是一个Embedded Framework。我们可以使用nm命令导出其符号表，以下是符号表的一部分：



![img](https://pic2.zhimg.com/80/v2-e0a08f0eade23a01ac46f504caac6141_720w.jpg)

 我们惊喜地发现，这些符号与Dart函数几乎是一一对应。比如符号Precompiled_Element_update_260，很明显对应的Dart函数为Element.update。

 有了这份符号表，也就意味着，如果我们能采集到root Isolate对应线程的native的堆栈，我们就可以通过符号化来还原出当时Dart函数的调用栈。而且我们也不再需要去寻找从另一个Isolate获取root Isolate的Dart堆栈的方法了。与之对应的，我们只需要能够在另一个线程获取root Isolate对应的线程的native堆栈即可。

### 3.2. 堆栈采集的方案

栈帧采集的方案整体思路如下：

1. 获取当前进程中的所有线程，并找到Flutter UI TaskRunner对应的线程
2. 暂停该线程，并获取该线程当前的寄存器的值，重点为PC和FP
3. 根据栈帧回溯算法，获取堆栈
4. 让该线程继续运行
5. 在当前进程或者远端做符号化

### 3.3. 堆栈采集方案的实现

接下来我们来看看如何实现这个方案，我们以iOS端为例子，来说明如何实现这个方案：

在iOS端，我们可以通过API`task_threads`来获取所有的线程，代码如下：

```c
//获取所有线程
thread_act_array_t threads;
mach_msg_type_number_t threadCount;
kern_return_t returnVal = task_threads(mach_task_self(), &threads, &threadCount);
```

 我们可以通过比对线程名字来定位到UI Task Runner对应的线程，如果是Flutter单Engine方案，那么UI Task Runner对应的Thread的名字应为"io.flutter.1.ui"。

```c
//获取Flutter UI Task Runner对应的线程
for (int i = 0; i < threadCount; ++i) {
    char name[256];
    pthread_t pt = pthread_from_mach_thread_np(threads[i]);
    if (pt) {
        name[0] = '\0';
        int rc = pthread_getname_np(pt, name, sizeof name);
    }

    if (strstr(name, "io.flutter") && strstr(name, "ui")) {
        thread = threads[i];
        break;
    }
}
```

 在采集堆栈前，我们得先暂停这个线程。

```c
//暂停线程
thread_suspend(thread);
```

 暂停线程后，我们就可以通过`thread_get_state`去获取这个线程此时此刻的寄存器的值了，其中能够帮助我们做栈帧回溯的两个寄存器分别是pc和fp，我们这里的代码是以arm64为例子的，在实际的产品中，还需要考虑到其他的架构：

```c
//获取线程暂停时寄存器中的pc和fp
uintptr_t stack[256];
_STRUCT_MCONTEXT mcontext;
mach_msg_type_number_t stateCnt;
_STRUCT_MCONTEXT *mcontext_p = &mcontext;

mach_msg_type_number_t state_count = ARM_THREAD_STATE64_COUNT;
kern_return_t rt = thread_get_state(thread, ARM_THREAD_STATE64,(thread_state_t)&mcontext_p->__ss, &state_count);

#if defined (__arm64__)
   origin_pc = mcontext_p->__ss.__pc;
   origin_fp  = mcontext_p->__ss.__fp;
#endif
```

 获取pc和fp后，就可以进行栈帧回溯了。至于如何进行栈帧回溯，我们会在下一个小节单独说明。栈帧采集完之后，我们需要让线程继续运行：

```c
//恢复线程
thread_resume(thread);
```

 以上就是iOS端堆栈采集方案的大体实现了。Android端想实现这个方案，思路上大同小异，无论是找到所有的线程，定位到UI Task Runner对应的线程，还是线程的暂停和恢复，都能找到解决方案。唯一比较麻烦的地方在于如何获取另一个线程暂停时的寄存器的值，这部分可以使用ptrace来完成，不过这个需要起一个独立的进程。

### 3.4. 栈帧回溯的原理

 上文说到，我们获得了pc和fp寄存器的值，该如何做栈帧回溯呢？



![img](https://pic2.zhimg.com/80/v2-7c8c87386aafa2e0a6c1ac863321ae11_720w.jpg)



 这里我们以ARM64栈帧布局为例子（也就是上图）。每次函数调用，都会在调用栈上，维护一个独立的栈帧，每个栈帧中都有一个FP（Frame Pointer），指向上一个栈帧的FP，而与FP相邻的LR（Link Register）中保存的是函数的返回地址。也就是我们可以根据FP找到上一个FP，而与FP相邻的LR对应的函数就是该栈帧对应的函数。回溯的算法如下

```c
while(fp) {
  pc = *(fp + 1);
  fp = *fp;
}
```

 堆栈采集完毕后，我们只需要将采集到的堆栈进行符号化即可。

## 4. 堆栈采集方案3：AOT模式下采集堆栈（通过信号）

### 4.1 性能的瓶颈

 上面的这个方案可能会对性能造成一些影响，堆栈回溯本身并不耗时，真正的耗时在于线程的暂停和恢复。线程暂停后，线程就会进入阻塞状态，而去恢复线程时，线程并不会立即执行，而是会进入就绪状态，等待内核调度为其分配CPU时间片。所以在这个方案，每一次采集线程堆栈，都意味着这个线程的状态可能会从运行态到阻塞态再到就绪态。



![img](https://pic3.zhimg.com/80/v2-3b193860601668be4652bf39b7e152fe_720w.jpg)



 那么有没有更为轻量级的采集堆栈的方案？

### 4.2 信号机制的原理

 信号（Signal）是事件发生时对进程的通知机制，有时候也称之为软件中断。一般发给进程的信号，通常是由内核产生的，比如访问了非法的内存地址，或者被0除等等，当然，一个进程可以向另一个进程或者自身发送信号。如果进程注册了信号处理器（Signal Handler），那么当收到信号后，就会中断当前程序，开始调用信号处理器程序，等信号处理器程序执行完成后，当前程序会在被中断的位置继续执行。



![img](https://pic3.zhimg.com/80/v2-e835450ea1deda251f2557ed8599647e_720w.jpg)



### 4.3. 新方案的实现

 我们先注册一个信号处理器，用于采集堆栈。接着，我们还是启动一个采集线程，每隔一段时间，向UI Task Runner发送一个信号。当收到信号后，UI Task Runner对应的线程就会被中断，执行信号处理器程序来采集堆栈，堆栈采集完后，程序会从中断点回复执行。

 我们来看看这个方案具体如何实现，这次我们以Android端为例子：

 首先我们先注册一些signal handler，用于在收到信号时采集堆栈

```cpp
struct sigaction act = {};
act.sa_sigaction = signalHandler;
sigemptyset(&act.sa_mask);
act.sa_flags = SA_RESTART | SA_SIGINFO | SA_ONSTACK;
r = sigaction(SIGPROF, &act, NULL);
```

 接着我们每隔一段时间，就向UI Task Runner对应的线程发送一个信号。

```cpp
int32_t pid = static_cast<int32_t>(getpid());
int32_t thisThreadId = static_cast<int32_t>(syscall(__NR_gettid));
int result = syscall(__NR_tgkill, getpid(), threadId, SIGPROF);
```

 信号到达后，该线程就会中断当前执行的程序，然后调用signal handler采集堆栈，其中signalHandler的实现如下

```cpp
void signalHandler(int signal, siginfo_t *info, void *context_) {
    if (signal != SIGPROF) {
      return;
    }

    ucontext_t *context = reinterpret_cast<ucontext_t *>(context_);
    mcontext_t mcontext = context->uc_mcontext;
    .....
    //后面根据mcontext去获取pc和fp，使用上文中提到的栈帧回溯的方法
}
```

 实际上，FaceBook的性能监控方案profilo，以及Dart VM的CPU Profiler，均使用了这个方案来采集堆栈。

## 5. 堆栈采集方案对比

 我们来对比一下上面提到的3个方案，它们的区别如下图所示：

| | 方案一 | 方案二 | 方案三 | | ----------- | -------------------------- | ---------------------- | ---------------------- | | 原理 | 修改SDK增加采集Dart堆栈API | 暂停线程采集Native堆栈 | 通过信号采集Native堆栈 | | 是否修改SDK | 是 | 否 | 否 | | 适用模式 | JIT / AOT | AOT | AOT | | 维护成本 | 高 | 低 | 低 | | 性能损耗 | 较高 | 较高 | 低 |

 我们可以看到，方案三无需修改SDK，所以维护成本较低，并且在三个方案中它的性能损耗是最低的。最终我们决定采用方案三来作为我们堆栈采集的方案。

## 6. 总结

 本文主要介绍了我们在设计Flutter卡顿监控系统的一些思路，给出了如何判断卡顿跟如何获取堆栈的思考和探索，目前这个方案的产品化正在进行当中。Flutter作为高性能的跨平台方案，其渲染性能从理论上来说，可以做到不弱于原生。同时Flutter在性能体验方向上，和原生相比，还有非常多值得探索的地方，让我们一起不忘初心，继续朝着这个方向前进。