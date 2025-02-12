# KVMGUI 方案调研



## KVMGUI 开发方案

> 结合 KVMGUI 跨平台需求(Win、Pad、Linux)、RK3588 分布式编解码盒子硬件性能以及开发维护便利性，确定的基于 Qt5.15 使用 C++、qml、javescript 语言混合开发 KVMGUI 模块。
>
> 后面了解到还要做基于新塘 NUC972芯片+FPGA 的自研传输盒子。基于此方案开发的 Qt 程序应该无法运行，用 qml 要依赖 GPU 加速。 
>
> 
>
> 其它方案：
>
> 1、采用纯 QWidget 开发 GUI，控制资源占用，不依赖 GPU 加速，NUC972 芯片应该也能运行起来，网上有跑 Qt 的案例。
>
> 2、采用 LVGL 开发 GUI，更适合可穿戴设备上的 UI。优点是对硬件性能要求低，不支持跨平台。
>
> 3、RK3588 分布式盒子与新塘NUC972芯片自研传输盒子，采用不同的 KVMGUI 方案，要看产品怎么定义。
>
> 
>
> 以下是基于 RK3588 开发 KVMGUI 测试结果以及准备用到的脚手架，确定开发方案后再细化！







### 开发脚手架

#### IDEA

> QtCreate、QMake

#### UI控件

> QtQuick、QtQuick.Controls、QtQuick.Layouts
>
> UI 设计之完成后，基于Qt基础组件库封装统一风格的控件。
>
> 可以参考开源的 [QianWindow: QianWindow](https://github.com/nuoqian-lgtm/QianWindow)，目前还缺少一些大屏、窗口播放类控件。

#### 日志组件

> log4qt  基于此封装一个日志类，并注册为 qml 组件
>
>  [MEONMedical/Log4Qt: Log4Qt](https://github.com/MEONMedical/Log4Qt)





#### 数据库组件

> 考虑到 KVMGUI 本身不存储很多数据，直接使用 QSqlDatabase、QSqlQuery
>
> 
>
> 备选：QxORM 
> [QxOrm library - C++ Qt ORM (Object Relational Mapping) and ODM (Object Document Mapper) library ](https://github.com/QxOrm/QxOrm)

#### 网络通讯

> 需要封装个网络通讯模块，支持 HttpClient、WSClient
>
> QNetworkAccessManager、QNetworkReply、QWebSocket
>
> 
>
> 其它 HttpClient 组件：
>
> XMLHttpRequest 组件较老，可以直接在 qml 中使用
>
> HttpClient  组件 Qt6 才支持，可以直接在 qml 中使用  

#### 调试控制台
> 可视化 JS Console



#### 键盘快捷键

> QHotkey 支持普通桌面系统 Win、Mac、基于 X11 的 Linux 系统，可以兼容后期跨平台需求。
>
> 可以基于此扩展开发基于 evdev 实现读取键盘信号（读取 /dev/input/event）
>
> [Skycoder42/QHotkey: A global shortcut/hotkey for Desktop Qt-Applications (github.com)](https://github.com/Skycoder42/QHotkey)
>
> 
>
> 注：如果 Qt 程序始终全屏显示，就可以通过 QKeyEvent 获取到键盘事件，参见下面的 UI 设计思路。

#### 鼠标信号

> 已测试，基于 QMouseEvent 获取鼠标信号，只有当焦点在 Qt 程序上时，才有鼠标位置数据。
>
> 需要基于 evdev 实现读取鼠标信号（读取 /dev/input/event）。
>
> 
>
> 注：如果 Qt 程序始终全屏显示，就可以通过 QMouseEvent 获取到鼠标数据，参见下面的 UI 设计思路。



基于 evdev 的 嵌入式 Linux 系统，可以考虑通过解析 /proc/bus/input/devices 获取 /dev/input/event 对应的是鼠标还是键盘。

可以参考 Qt 源码键鼠识别方案：

qt-everywhere-src-5.15.16\qtbase\src\platformsupport\input\evdevmouse
qt-everywhere-src-5.15.16\qtbase\src\platformsupport\input\shared



### 工程目录结构

> 看了之前 MSP1000 工程的目录结构，基本所有的代码都放到一个路径下的，总共有好几百个文件，没有参考。一些组件没有抽象成通用控件，和逻辑掺杂在一块，可以看看有么有能复用的组件。
>
> MSP1000 源码：MPU/30-client/mspuilib
>
> 
>
> KVMGUI 工程目录结构大致如下：

```shell
ubuntu@ubuntu-Vostro-3268:/mnt/lyjwin/project/QtProject/KVMGUI$ tree
.
├── build                          # 工程编译 
│   ├── Desktop_Qt_5_15_2_MinGW_64_bit-Debug
│   └── RK3588_QMAKE
│       └── build.sh
|
├── library                        # 开源库
│   ├── log4qt
│   ├── qxorm
│   └── KVMGUI依赖开源组件.md
|
├── document                        # 文档
│   ├── res
│   │   ├── LINUX_DRM.jpg
│   │   └── RK3588_QT_EGLFS_DRM.png
│   └── RK3588GUI显示方案.md
|
├── fonts                           # 字体
│   └── FangZhengHeiTi-GBK-1.ttf
|
├── i18n                            # 翻译
|
└── src
|   |
|   ├── cpp                         # CPP 业务逻辑代码
|   │   ├── common
|   │   │   ├── backed
|   │   │   ├── dbctrl
|   │   │   ├── httpclient
|   │   │   ├── logmodule
|   │   │   ├── qhotkey
|   │   │   ├── qmousetracker
|   │   │   ├── uiframeless
|   │   │   └── uipages
|   |   |
|   │   └── main.cpp
|   |
|   └── qml                        # QML 页面绘制实现
|       ├── common                 # 统一的 QML UI 基础控件。基于 UI 设计提供的资源，统一风格，支持换肤
|       ├── pages                  # KVMGUI 页面绘制
|       │   ├── kvmrespage
|       │   ├── kvmgrabpage
|       │   ├── kvmpushpage
|       │   ├── kvmpushqueuepage
|       │   ├── kvmschemepage
|       │   ├── kvmscreenlayoutpage
|       │   ├── kvmpowerpage
|       │   └── kvmsysconfigpage
|       |
|       ├── main.qml
|       ├── PageManager.qml
|       └── qml.qrc
|
└── kvmgui.pro
```


### 基本业务流程

![image-20250116173547015](.\res\KVMGUI_UML.png)

### 模块划分

**CPP**

> 部分模块封装后需要注册为 QML 包，供 QML UI 绘制使用，比如：日志模块、数据查询模块、网络 HTTP 通讯等。

确认基础方案后，详细设计业务模块。



**QML**

> qml 文件名即包名，大写开头。

![image-20250117104437789](.\res\QML_PACK.png)



## Linux 显示机制

[Linux显示（三）：DRM子系统](https://www.cnblogs.com/arnoldlu/p/17978715)

![img](.\res\LINUX_DRM.jpg)



## RK3588 GUI 送显方案

> RK3588 支持 eglfs drm 显示方案，根据 RK 厂商建议基于此方案修改 eglfs QPA 插件，并使用 rkmpi(RKSDK) 接口跨进程送显；
>
> **实现原理：**
> Qt Process 渲染图像数据后  gbm_bo_create 创建 DMA-BUF (Direct Memory Access Buffer) 并写入数据，通过 gbm_bo_get_fd 获取 dmaBufferFd，并通过本地 socket 通讯将 dmaBufferFd 发送给 VOProcess
> Qt Process 与 VO Process 本质是通过 DMA-BUF 共享图像数据（RKSDK 接口可以通过 dmaBufferFd 访问原始缓冲区的内容）
>
> 下图是 Qt Process 与 VO Process 交互方式，eglfs、eglfs_cursor 中传输的数据是 gbm_bo_get_fd 获取的 dmaBufferFd；eglfs_cursor_xy 直接是坐标信息   

![image-20250117094856863](.\res\RK3588_QT_EGLFS_DRM.png)



**TODO：**与媒控、解码器业务、共同评审

- 待确认依据 HDMI 输出连接的显示器分辨率，GUI 自适应缩放实现方式
- 待确认 VO Process 是由上海 nvrsrv 业务团队实现，还是显控业务团队实现
- 考虑 RKSDK 多进程使用是否会冲突
- 送显程序能否适应不同分辨率的显示器



**媒控组件：**

\\172.16.0.99\DailyVersions\system\EDGEOS\20241226\SYSDEV_RK3588_EDGEOS_20241226#94\cbb\mediactrl_nvr



**RK3588 NVRSDK 编解码 Demo 及文档：**

/home/junjun/RKMPI_Release、/home/junjun/RKMPI_Release/doc/cn



## RK3588 Qt 编译环境

> **基于 buildroot 交叉编译 Qt5.15，使用的 buildroot 是 RockChip 提供的定制版。编译配置：rk3588_with_qt5_mali.config**
>
> 编译环境    ：10.67.69.23  ubuntu admin123
>
> 编译路径	： /home/junjun/RK3588_SDK/buildroot
>
> QPA 插件   ： /home/junjun/QPA/eglfs_1/eglfs/eglfs
>
> VO送显程序：/home/junjun/QPA/eglfs_1/eglfs/eglfs_test_src      **注意：**demo 中的库是 RK3568 平台的，运行时需要替换为 RKMPI_Release 中的库
>
> QPA 编译	：/home/junjun/QPA/eglfs_1/build_eglfs.sh
>
> QT全量打包：/home/junjun/QPA/packed_qt.sh
>
> QT测试程序：/home/junjun/QtDemo/QianWindow-qt5.14_qml    /home/junjun/QtDemo/QianWindow-qt5.14_qml/build/RK3588_QMAKE
>
> 如何交叉编译 RK3588 平台运行的 Qt 程序，参考 /home/junjun/QtDemo/QianWindow-qt5.14_qml/build/RK3588_QMAKE 编译脚本



### Qt Demo 测试

> RK3588 平台 Qt 编译移植已完成。基于 C++、qml、javescript 语言混合开发 Qt 程序基本功能验证通过。以下列举待确认事项：

#### 1、GUI窗口自适应缩放

> 需要实现依据 HDMI 输出口连接的显示器分辨率，自适应调整 Qt 程序窗口大小。

**方案一：**

通过 RK 接口调整 UI 层参数或 eglfs_kms 输出参数设置，简单测试了一下会花屏，不确定是否可行。不确定能否灵活控制。

**方案二：**

通过 UI 整体布局设计，添加一个全屏的透明背景，在背景中间绘制程序主页，可以支持Qt程序自由控制缩放。参考下面 UI 设计示例。



#### 2、设置GUI透明度

> 因为 KVMGUI 要支持预览播放视屏的功能，媒控给的方案是透过 Qt GUI 观看解码输出画面，缺点是会限制 UI 设计。
>
> 普通播放器组件不能支持硬解码，且码流是加密的，预览功能只能通过现在的解码流程实现。
>
> 
>
> **其它方案思考：**
>
> nvrsrv 能否把解码后的 YUV 数据通过共享内存共享出来，Qt 负责播放（在 UI 层展播放，预览帧率不要求 10-15 即可），QtGUI 渲染支持 GPU 加速。
>
> 如果可以支持，可以先弄些 YUV 测试数据，在 RK3588 上用 Qt 程序播放，测试下性能。
>
> YUV 数据转换成 RGB 数据
>
> 
>
> 
>
> - 小窗口预览播放 YUV420P 即可，最好可以自定义
> - 帧率 15 - 25 即可，播放无明显卡顿



传统的 UI 布局设计：

![image-20250117133647079](.\res\UI_Layout.png)

必须支持 UI 局部透明的布局设计，需要固定一块区域做预监预览：

![image-20250117133549773](.\res\UI_Layout_2.png)



#### 3、性能影响

> 编译 Qt 使用了 RK 厂商提供的 libmali 库，支持 GPU 渲染。运行 Qt 程序无卡顿，CPU 占用没啥变化，内存占用目前没有太关注。



### TODO

- 评审确认 VOProcess 送显程序由哪个部门实现

- 基于当前梳理后的功能设计，定义主控侧坐席相关表设计、业务接口，评审后可启动此部分业务开发工作
- 参考原型设计，提需求设计 UI 
- KVMGUI 框架搭建，封装日志、网络通讯、数据库模块
- 基于 UI 设计，封装公用 QML UI 控件
