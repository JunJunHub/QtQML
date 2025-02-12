#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <QDir>
#include <QFontDatabase>
#include <QTranslator>

#include "kvmlogmodule.h"
//#include "qmousetracker.h"
//#include "qhotkey.h"
#include "drageventcatch.h"
//#include "yuv_video_play/cplaywidget.h"
//#include "uiframeless.h"

//自定义字体测试
void testFonts() {
    //确认当前设备默认支持哪些字体类型
    QFontDatabase fontDatabase;
    foreach (const QString &fontFamily, fontDatabase.families())
    {
        qInfo()<< "The font library supported by the current device:" << fontFamily;
    }

    //自定义图标字库 http://fontello.com
    QFontDatabase::addApplicationFont(":/fontello.ttf");

    //测试使用开源字体
    QString fontPath = ":/FangZhengHeiTi-GBK-1.ttf";
    int fontId = fontDatabase.addApplicationFont(fontPath);
    if (fontId < 0) {
        qWarning() << "Failed to load font:" << fontPath;
    } else {
        qInfo() << "load font:" << fontPath;
        QStringList fontFamliles= fontDatabase.applicationFontFamilies(fontId);
        QFont font;
        font.setFamily(fontFamliles.first());
        QApplication::setFont(font);
    }
    return;
}

//快捷键测试
void testQHotkey(QApplication &app) {
    //测试注册鼠标键盘事件过滤器
    //TODO -- 如果鼠标焦点不在Qt程序上，获取不到鼠标信号
    //        也没有键盘信号
    //GlobalEventFilter filter;
    //app.installEventFilter(&filter);  // 安装全局事件过滤器


    //测试 qhotkey 快捷键
    //依赖系统级接口 Linux 平台是 X11
    //嵌入式设备不支持 X11 可以基于此框架扩展实现（直接读取 /dev/input/event0）
    //键鼠设备识别可以参考 qt evdev 源码  qt-everywhere-src-5.15.16\qtbase\src\platformsupport\input\evdevmouse
    //                      qt-everywhere-src-5.15.16\qtbase\src\platformsupport\input\shared
    // QHotkey saveKVMHotkey(QKeySequence(Qt::CTRL + Qt::Key_A), true, &app);
    // QObject::connect(&saveKVMHotkey, &QHotkey::activated, []() {
    //     qInfo() << "QHotkey Ctrl + S shortcut activated";
    // });
    return;
}

//测试虚拟键盘
void testQVirtualKeyboard() {
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    //可选：设置虚拟键盘样式
    QQuickStyle::setStyle("Basic");

    //TODO - 测试开源输入法组件

    return;
}

//测试翻译
void testI18n(QApplication &app) {
    //Q_INIT_RESOURCE(i18n);

    //Step-1 整理所有要翻译的字符串
    //使用 lupdate 工具可以自动提取源代码中需要翻译的字符串，也可以手动维护
    //提取后自己翻译，再根据翻译后的 ts 文件生成对应的 qm 资源文件
    // lupdate -verbose -recursive kvmgui.pro -ts kvmgui_zh_CN.ts
    // /home/junjun/QT5.15_RK3588_NO_OPENGL/bin/lupdate -verbose -recursive kvmgui.pro -ts i18n/kvmgui_zh_CN.ts

    //Step-2 生成 qm 资源文件
    // lrelease i18n/kvmgui_zh_CN.ts -qm i18n/qm/kvmgui_zh_CN.qm
    // /home/junjun/QT5.15_RK3588_NO_OPENGL/bin/lrelease i18n/kvmgui_zh_CN.ts -qm i18n/qm/kvmgui_zh_CN.qm


    //Step-3 加载 qm 资源文件  必须在 main 函数中加载才生效??
    QTranslator translator;
    if(translator.load(":/qm/kvmgui_zh_CN.qm")) {
        app.installTranslator(&translator);
        qInfo() << "Qt load translation file" << ":/qm/kvmgui_zh_CN.qm";
    } else {
        qWarning() << "QTranslator error: Failed to load translation file" << ":/qm/kvmgui_zh_CN.qm";
    }



    //测试实现动态切换语种
    //TODO

    return;
}

//测试入口
void testInit(QApplication &app) {
    testFonts();
    testI18n(app);
    testQVirtualKeyboard();
    testQHotkey(app);
    return;
}

//程序入口
int main(int argc, char *argv[])
{
    //初始化Log4Qt日志组件
    Log4QtInit();

    //打印版本信息
    qInfo() << "Qt version:" << QT_VERSION_STR;

    //启用虚拟键盘
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));


    //初始化 APP 属性参数
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);//自适应高分辨率屏幕
    QCoreApplication::setOrganizationName("kedacom");
    QCoreApplication::setApplicationName("KVMGUI");
    QCoreApplication::setApplicationVersion("V1.0.0");

    //初始化 APP 实例
    QApplication app(argc, argv);

    //测试代码
    testInit(app);

    //加载翻译文件
    QTranslator translator;
    if(translator.load(":/qm/kvmgui_zh_CN.qm")) {
        app.installTranslator(&translator);
    } else {
        qWarning() << "QTranslator error: Failed to load translation file" << ":/qm/kvmgui_zh_CN.qm";
    }

    //设置 QQuickStyle
    QQuickStyle::setStyle("Material");

    //初始化 QQmlApplicationEngine
    QQmlApplicationEngine qmlEngine;

    //将 C++ 实现的组件注册为 qml 组件
    qmlRegisterType<DragEventCatch>("Qt.DragEventCatch", 1, 0, "DragEventCatch");
    //qmlRegisterType<FramelessWindow>("Qt.KVM.FramelessWindow", 1, 0, "KVMFramelessWindow");

    //将 C++ 实现的日志组件注册为 qml 组件
    qmlRegisterSingletonType<KVMLogModule>("Qt.KVM.Log4Qml", 1, 0, "KVMLog4Qml",
                                           [](QQmlEngine*, QJSEngine*) -> QObject* {
                                               return &KVMLogModule::instance();
                                           });

    //将 QML 皮肤组件注册为全局单例类型
    qmlRegisterSingletonType(QUrl("qrc:/common/KVMSkin/SkinModel.qml"), "Qt.KVM.SkinSingleton", 1, 0, "SkinSingleton");


    //QQmlApplicationEngine load
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&qmlEngine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                            if (!obj && url == objUrl)
                                QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    qmlEngine.load(url);

    return app.exec();
}
