## 基本原理



1. flutter CLI的代码在flutter/packages/flutter_tools

2. 在执行flutter create flutter_test这样的命令是，最终执行的语句是"$DART" --disable-dart-dev --packages="$FLUTTER_TOOLS_DIR/.packages" $FLUTTER_TOOL_ARGS "$SNAPSHOT_PATH" “$@“

3. 这里FLUTTER_TOOLS_DIR=“$FLUTTER_ROOT/packages/flutter_tools”；DART=“$DART_SDK_PATH/bin/dart”；也就是说执行flutter create等命令，最终都会转化为使用dart命令来解释执行flutter tools源代码目录中的相应dart文件

4. 如果要修改它，要注意在在flutter/bin/cache目录有一个时间戳的概念：flutter_tools.stamp，需要删除此时间戳文件才能够使得本地的flutter tools源代码修改生效

5. 抛开实现框架，flutter/packages/flutter_tools/lib/src/android存放着安卓系统的适配，所以可以直接查看其具体的实现，以便更精细的理解其功能

6. flutter CLI的实现是基本的，处理编辑器相关的功能之外，IDE上基本所有的操作都是依赖Flutter CLI来实现的

7. 参考资料:/21mmPocProject/Android-Flutter-Debug.key

   是在post21mm项目中，适配post21mm Devices过程中整理的设计资料，整理了flutter工具几个典型用例：

   flutter devices、flutter run、hotreload、flutter attach



## 功能列表：

1. 本地开发环境管理：flutter upgrade / flutter downgrade / flutter channel / flutter doctor / flutter config
2. 开发-部署全流程管理: 

- flutter create 创建工程
- flutter create . 在既有的工程中添加其他平台的支持文件
- flutter build AOT编译
- flutter run 加载程序包到目标设备如安卓上运行
- flutter analyze 这是基于工程目录配置的analysis_option文件配置的内容进行编码检查，以及dart语言自身语言规范的检查，检索时候一般介绍是使用linter作为关键字来检索
- flutter devices 检查当前可用的目标设备
- flutter attach 连接目标设备上的应用程序，后续可以进行debug操作
- flutter format 格式化代码，对代码文件进行排版，所以使用flutter并不依赖手工来排版
- flutter logs / flutter screenshot 获取目标设备上应用运行的日志和界面截图
- flutter test 运行工程目录中的test后缀的文件，执行flutter的单元测试用例
- lutter drive 没有使用过，后续补充
