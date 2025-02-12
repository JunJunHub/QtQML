#ifndef KVMLOGMODULE_H
#define KVMLOGMODULE_H

#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlExtensionPlugin>
#include <QObject>

#include "log4qt/logger.h"

void Log4QtInit();

// 单例模式，全局公用一个Log4Qt日志对象
class KVMLogModule : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(KVMLogModule)
    QML_ELEMENT
    QML_SINGLETON

public:
    static KVMLogModule& instance();

    Q_INVOKABLE void logDebug(const QString& message);
    Q_INVOKABLE void logInfo(const QString& message);
    Q_INVOKABLE void logWarn(const QString& message);
    Q_INVOKABLE void logError(const QString& message);

    Q_INVOKABLE void setLogLevel();

private:
    KVMLogModule();
    ~KVMLogModule() = default;

    Log4Qt::Logger* m_rootLogger;
};



// #include <QQmlExtensionPlugin>

// class KVMLogModulePlugin : public QQmlExtensionPlugin
// {
//     Q_OBJECT
//     Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

// public:
//     void registerTypes(const char* uri) override;
// };

// void KVMLogModulePlugin::registerTypes(const char* uri)
// {
//     Q_ASSERT(uri == QLatin1String("KVMLogModule"));

//     qmlRegisterSingletonType<KVMLogModule>(uri, 1, 0, "KVMLogModule",
//                                            [](QQmlEngine*, QJSEngine*) -> QObject* {
//                                                return &KVMLogModule::instance();
//                                            });
// }

#endif // KVMLOGMODULE_H
