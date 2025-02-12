#include "kvmlogmodule.h"

#include "log4qt/logmanager.h"
#include "log4qt/patternlayout.h"
#include "log4qt/consoleappender.h"
#include "log4qt/dailyfileappender.h"

void Log4QtInit() {
    //初始化log4qt配置，这里可以根据需要进行更多的配置

    //初始化根 Logger，name 为 root；
    Log4Qt::Logger *rootLogger = Log4Qt::Logger::rootLogger();
    rootLogger->setLevel(Log4Qt::Level::DEBUG_INT);  //设置日志输出级别
    Log4Qt::LogManager::setHandleQtMessages(true);  //处理Qt调试输出信息，将qDebug之类的信息重定向到Log4Qt

    //支持创建很多个其它 Logger，并配置不同的参数
    //Log4Qt::Logger *mylog1 = Log4Qt::Logger::logger("Mylog1");  //其他Logger，name为Mylog1的


    /*********************配置日志的输出格式****************************/
    Log4Qt::PatternLayout *layout = new Log4Qt::PatternLayout();
    // %p: 日志级别（Priority）。例如：DEBUG, INFO, WARN, ERROR, FATAL
    // %c: 日志记录器名称（Category）。这是日志记录器的全限定名，通常是类名或模块名
    // %m: 日志消息（Message）。这是实际的日志内容，由调用者提供的信息
    // %r: 自程序启动以来的时间（Relative time in milliseconds）
    // %t: 线程名称（Thread name）。如果是多线程环境，这将显示产生日志的线程名称
    // %F: 文件名（File name）。这是产生日志的源文件名
    // %M: 函数名（Method name）。这是产生日志的函数名
    // %L: 行号（Line number）。这是产生日志的代码行号
    // %l: 完整位置信息（Location information）。包括文件名、函数名和行号，格式为 filename:linenumber - functionname
    // %n: 换行符（Newline character）。用于在不同的日志条目之间换行
    //layout->setConversionPattern("%d{yyyy-MM-dd hh:mm:ss} %p %c %m %r %t %F %M %L %l %n"); //全量信息
    layout->setConversionPattern("%d{yyyy-MM-dd hh:mm:ss} %p %m %r %t %F:%L:%M %n");
    layout->activateOptions(); // 激活Layout

    /**********************配置日志的输出位置***************************/
    //ConsoleAppender：输出到控制台
    Log4Qt::ConsoleAppender *appender = new Log4Qt::ConsoleAppender(layout, Log4Qt::ConsoleAppender::STDOUT_TARGET);
    appender->activateOptions();
    rootLogger->addAppender(appender);

    /***********************配置日志回滚策略***************************/
    //DailyFileAppender：每天新建一个文件，保存当天的日志，超过指定的天数，删除最开始的日志
    Log4Qt::DailyFileAppender *dailiAppender = new Log4Qt::DailyFileAppender;
    dailiAppender->setLayout(layout);             //设置输出格式
    dailiAppender->setFile("KVMGUILogFile.log");  //日志文件名：固定前缀
    dailiAppender->setDatePattern("_yyyy_MM_dd"); //日志文件名：根据每天日志变化的后缀
    dailiAppender->setAppendFile(true);           //true表示消息增加到指定文件中，false则将消息覆盖指定的文件内容，默认值是false
    dailiAppender->setKeepDays(30);               //设置保留天数
    dailiAppender->activateOptions();
    rootLogger->addAppender(dailiAppender);

    return;
}

KVMLogModule& KVMLogModule::instance()
{
    static KVMLogModule instance;
    return instance;
}

KVMLogModule::KVMLogModule()
{
    m_rootLogger = Log4Qt::Logger::rootLogger();
    return;
}

void KVMLogModule::logDebug(const QString& message)
{
    m_rootLogger->debug(message);
    return;
}

void KVMLogModule::logInfo(const QString& message)
{
    m_rootLogger->info(message);
    return;
}

void KVMLogModule::logWarn(const QString& message)
{
    m_rootLogger->warn(message);
    return;
}

void KVMLogModule::logError(const QString& message)
{
    m_rootLogger->error(message);
    return;
}

void KVMLogModule::setLogLevel()
{
    Log4Qt::Logger *rootLogger = Log4Qt::Logger::rootLogger();
    rootLogger->setLevel(Log4Qt::Level::INFO_INT);  //设置日志输出级别
    return;
}
