#基于qtlog4封装的QML日志插件

INCLUDEPATH += $$PWD
DEPENDPATH += $$PWD

HEADERS += \
$$PWD/kvmlogmodule.h

SOURCES += \
$$PWD/kvmlogmodule.cpp


## QtLog4
# LOG4QT_PATH = $$PWD/log4qt-1.5.1
# DEFINES += LOG4QT_LIBRARY
# INCLUDEPATH += \
# $$LOG4QT_PATH/src \
# $$LOG4QT_PATH/src/log4qt \
# $$LOG4QT_PATH/include \
# $$LOG4QT_PATH/include/log4qt \

# include($$LOG4QT_PATH/src/log4qt/log4qt.pri)
# include($$LOG4QT_PATH/build.pri)
# include($$LOG4QT_PATH/g++.pri)
