# FlutterTools解析

## FlutterTools支持安卓设备的实现

这是FlutterTools支持安卓设备的概要实现图。

![pd](/Users/a/konyProject/blog/Flutter/attatched/pd.png)


### 当在AndroidStudio按下Debug发生了什么


Flutter Tools的主体框架是通过ResidentRunner及其子类控制Run命令的执行内容和步骤；通过FlutterDeviceManager来遍历当前可用的设备；通过FlutterDevice来完成具体的工作：build、Install、Start、Stop、Uninstall

![FlutterRun_cd_u](/Users/a/konyProject/blog/Flutter/attatched/FlutterRun_cd_u.png)



这是一个时序图，其中可以分成三个主要部分：

1. 枚举当前可用的设备
2. 使用选定的Flutter设备，执行StartApp动作
3. 当第二步执行完成后，Attach到Target机上的Dartvm服务

![FlutterRun_sd](/Users/a/konyProject/blog/Flutter/attatched/FlutterRun_sd.png)



### 设备发现

这是设备发现的子过程。其核心思路是使用pollingGetDevices来实现各类设备的枚举过程。

![DeviceDiscovery_sd](/Users/a/konyProject/blog/Flutter/attatched/DeviceDiscovery_sd.png)

这是设备发现的相关类图，使用设备发现的类用来进行设备发现，返回各类设备的对象给FlutterDeviceManager

![DeviceDiscovery_cd](/Users/a/konyProject/blog/Flutter/attatched/DeviceDiscovery_cd.png)

### 启动应用

这是具体的设备类启动应用即StartApp的时序图。

![StartApp_sd](/Users/a/konyProject/blog/Flutter/attatched/StartApp_sd.png)









---

## Android Studio编译运行Flutter应用


> 修改flutter_tools的源代码，在flutter_tools.dart中的main函数中追加日志输出。
>
> 同时删除flutter/bin/cache目录下的flutter_tools.stamp文件，使其能够保证flutter_tools能够重新编译。



经过上述准备后，使用AndroidStudio创建一个Flutter应用，选择android设备，并运行，能够获取到下面的日志

``` verilog
Building flutter tool...
flutter_tools arg: [--no-color, run, --machine, --track-widget-creation, --device-id=APH0219417003611, --start-paused, --dart-define=flutter.inspector.structuredErrors=true, lib/main.dart]
Running "flutter pub get" in flutter_app...
Launching lib/main.dart on VOG AL10 in debug mode...
①Running Gradle task 'assembleDebug'...
②✓ Built build/app/outputs/flutter-apk/app-debug.apk.
③Installing build/app/outputs/flutter-apk/app.apk...
④Waiting for VOG AL10 to report its views...
⑤Debug service listening on ws://127.0.0.1:62395/EQM78cdLngM=/ws
⑥Syncing files to device VOG AL10...
⑦I/flutter ( 6501): main startup

```

```
vscode 输出 
flutter_tools arg: [run, --machine, --target, lib/main.dart, -d, APH0219417003611, --track-widget-creation, --dart-define=flutter.inspector.structuredErrors=true, --start-paused, --web-server-debug-protocol, ws, --web-server-debug-backend-protocol, ws, --web-allow-expose-url]
```





**①Running Gradle task 'assembleDebug'...**

→gradle.dart  buildGradleApp

**②✓ Built build/app/outputs/flutter-apk/app-debug.apk.**

→gradle.dart 某个函数，尚未定位

**③Installing build/app/outputs/flutter-apk/app.apk...**

→android_device.dart _installApp

→android_device.dart startApp 然后有一段调用：

```dart
_logger.printTrace('Waiting for observatory port to be available...');
    try {
      Uri observatoryUri;
      if (debuggingOptions.buildInfo.isDebug || debuggingOptions.buildInfo.isProfile) {
        observatoryUri = await observatoryDiscovery.uri;
        if (observatoryUri == null) {
          _logger.printError(
            'Error waiting for a debug connection: '
            'The log reader stopped unexpectedly',
          );
          return LaunchResult.failed();
        }
      }
      return LaunchResult.succeeded(observatoryUri: observatoryUri);
```



**④Waiting for VOG AL10 to report its views...**

→resident_runnder.dart connectToServiceProtocol函数


**⑤Debug service listening on ws://127.0.0.1:62395/EQM78cdLngM=/ws**

→resident_web_runner.dart  attach。

**⑥Syncing files to device VOG AL10...**



**⑦I/flutter ( 9190): main startup**

这是获取到应用启动的日志。这里应该有获取日志的动作，在哪里调用呢？是不是在as里面？



通过上述分析，有两点共识：

> 1. AndroidStudio通过flutter run **各种参数传入启动了flutter_tools
> 2. 在Flutter run命令下，陆续完成build→install→start→connect→sync file→get logs的过程

同时有一点疑问：

> AndroidStudio在运行前已经获取了deviceID，这个是通过什么来实现的？



```verilog
flutter_tools arg: [run, --machine, --target, lib/main.dart, -d, macos, --track-widget-creation, --dart-define=flutter.inspector.structuredErrors=true, --start-paused, --web-server-debug-protocol, ws, --web-server-debug-backend-protocol, ws, --web-allow-expose-url]
[38;5;248mdevice.dart DeviceManager::getDevicesById called[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mandroid_device_discovery.dart AndroidDevices::pollingGetDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mrun.dart RunCommand::validateCommand[39;49m
[38;5;248mflutter_command.dart FlutterCommand::findAllTargetDevices[39;49m
[38;5;248mdoctor.dart Doctor::canLaunchAnything[39;49m
[38;5;248mdevice.dart findTargetDevices call getDevices[39;49m
[38;5;248mdevice.dart DeviceManager::getDevicesById called[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mandroid_device_discovery.dart AndroidDevices::pollingGetDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
[38;5;248mdevice.dart PollingDeviceDiscovery::_populateDevices[39;49m
Running "flutter pub get" in flutter_app...
runCommand:shouldUseHotMode=true
runCommand:run with machine
[38;5;248mrun.dart RunCommand::daemon.appDomain.startApp[39;49m
[38;5;248mdaemon.dart AppDomain::startApp: with buildInfo.mode:debug[39;49m
[38;5;248mdaemon.dart AppDomain::startApp: flutterDevice.create[39;49m
[38;5;248mdaemon.dart AppDomain::startApp: run with HotRunner[39;49m
[38;5;248mdaemon.dart AppDomain::startApp: launch app[39;49m
[38;5;248mdaemon.dart AppDomain::startApp: Send Event app_start[39;49m
[38;5;248mrun_hot.dart HotRunner::run...runSourceGenerators[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators call globals.buildSystem.buildIncremental[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators cacheDir:LocalDirectory: '/Users/a/Flutter/flutter/bin/cache'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators fileSystem:Instance of 'LocalFileSystem'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators flutterRootDir:LocalDirectory: '/Users/a/Flutter/flutter'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators outputDir:LocalDirectory: 'build'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators projectDir:LocalDirectory: '/Users/a/FE/android/flutter_app'[39;49m
[38;5;248mcompile.dart DefaultResidentCompiler::recompile[39;49m
resident_runner.dart::FlutterDevice::runHot
Launching lib/main.dart on macOS in debug mode...
 lib/main.dart
resident_runner.dart::FlutterDevice::runHot call AndroidDevice::targetPlatform
[38;5;248mcompile.dart DefaultResidentCompiler::_compile[39;49m
[38;5;248mcompile.dart DefaultResidentCompile run with [/Users/a/Flutter/flutter/bin/cache/dart-sdk/bin/dart, --disable-dart-dev, /Users/a/Flutter/flutter/bin/cache/artifacts/engine/darwin-x64/frontend_server.dart.snapshot, --sdk-root, /Users/a/Flutter/flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk/, --incremental, --target=flutter, --debugger-module-names, --experimental-emit-debug-metadata, -Ddart.developer.causal_async_stacks=true, -Dflutter.inspector.structuredErrors=true, --output-dill, /var/folders/m4/npmd5nnd4n1b3m93v9b0c1nh0000gn/T/flutter_tools.EVhLS9/flutter_tool.fNgk7L/app.dill, --packages, .packages, -Ddart.vm.profile=false, -Ddart.vm.product=false, --enable-asserts, --track-widget-creation, --initialize-from-dill, build/3d53b3c3b3ecbf9ace22571e074e7caf.cache.dill.track.dill, --flutter-widget-cache][39;49m
application_package.ApplicationPackageFactory::getPackageForPlatform
resident_runner.dart::FlutterDevice::runHot call createDevFSWriter
resident_runner.dart::FlutterDevice::runHot call startEchoingDeviceLog
resident_runner.dart::FlutterDevice::runHot call device.startApp
resident_runner.dart::FlutterDevice::runHot startApp return observatoryUris
[38;5;248mrun_hot.dart HotRunner::attach call connectToServiceProtocol[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call connectToServiceProtocol with customize _reloadSourcesService[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call connectToServiceProtocol with customize _compileExpressionService[39;49m
[38;5;248mrun_hot.dart HotRunner::attach connectToServiceProtocol[39;49m
[38;5;248mresident_runner.dart FlutterDevice::connect[39;49m
[38;5;248mresident_runner.dart FlutterDevice::connect set reload service of vm in this function[39;49m
[38;5;248mresident_runner.dart FlutterDevice::connect connect to dart vm in this function[39;49m
Connecting to service protocol: http://127.0.0.1:61081/Nx51ZvnWTQE=/
@@aha third match in connectToServiceProtocol function
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call device.initLogReader[39;49m
[38;5;248mresident_runner.dart FlutterDevice::initLogReader[39;49m
[38;5;248mresident_runner.dart FlutterDevice::_initDevFS[39;49m
[38;5;248mresident_runnder.dart FlutterDevice::setupDevFS[39;49m
[38;5;248mdaemon.dart AppDomain::startApp: Send Event debugPort[39;49m
aha forth match in updateDevFS
[38;5;248mcompile.dart DefaultResidentCompiler::recompile[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call FlutterDevice.vmService.getFlutterViews[39;49m
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call FlutterDevice.devFS.baseUri.resolveUri[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call FlutterDevice.vmService.setAssetDirectory[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call writeVmserviceFile[39;49m
[38;5;248mrun_hot.dart HotRunner::attach call waitForAppToFinish[39;49m
Connecting to VM Service at ws://127.0.0.1:61083/l44GITj3meU=/ws
flutter: main startup
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators call globals.buildSystem.buildIncremental[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators cacheDir:LocalDirectory: '/Users/a/Flutter/flutter/bin/cache'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators fileSystem:Instance of 'LocalFileSystem'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators flutterRootDir:LocalDirectory: '/Users/a/Flutter/flutter'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators outputDir:LocalDirectory: 'build'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators projectDir:LocalDirectory: '/Users/a/FE/android/flutter_app'[39;49m
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
aha forth match in updateDevFS
[38;5;248mcompile.dart DefaultResidentCompiler::recompile[39;49m
Reloaded 1 of 536 libraries in 5,024ms.
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators call globals.buildSystem.buildIncremental[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators cacheDir:LocalDirectory: '/Users/a/Flutter/flutter/bin/cache'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators fileSystem:Instance of 'LocalFileSystem'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators flutterRootDir:LocalDirectory: '/Users/a/Flutter/flutter'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators outputDir:LocalDirectory: 'build'[39;49m
[38;5;248mresident_runner.dart ResidentRunner::runSourceGenerators projectDir:LocalDirectory: '/Users/a/FE/android/flutter_app'[39;49m
[38;5;248mvmservice.dart FlutterDevice-vmservice::getFlutterViews from dart vm[39;49m
aha forth match in updateDevFS
[38;5;248mcompile.dart DefaultResidentCompiler::recompile[39;49m
Reloaded 1 of 536 libraries in 1,097ms.

```



