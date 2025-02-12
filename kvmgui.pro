QT += widgets
QT += quick
QT += quickcontrols2
QT += virtualkeyboard
QT += websockets

CONFIG += c++11
CONFIG += resources_big

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
# DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

HEADERS += \

SOURCES += \
    src/cpp/main.cpp \

RESOURCES += \
    src/qml/qml.qrc \
    i18n/kvmgui_i18n.qrc \
    fonts/fonts.qrc

TRANSLATIONS += \
    i18n/kvmgui_en_US.ts \
    i18n/kvmgui_zh_CN.ts

#log4qt
INCLUDEPATH += $$PWD/library/log4qt/include

# Windows平台（win32）
win32 {
    RC_FILE += ./src/qml/res/Icon.rc
    LIBS += -L$$PWD/library/log4qt/lib/release/windows_amd64 -llog4qt

    # 针对MSVC编译器的特定配置
    msvc {
        QMAKE_CXXFLAGS += -wd4267 #禁用特定警告
    }

    #目前仅支持WIN
    include(./src/cpp/common/qhotkey/qhotkey.pri)
}

# MacOS平台
mac {
    # 禁用生成App Bundle
    CONFIG -= app_bundle
}

# Linux平台（unix）
unix:!mac {
    #
    LIBS += -L$$PWD/library/log4qt/lib/release/rk3588_arm64 -llog4qt
}

include(./src/cpp/common/logmodule/logmodule.pri)
include(./src/cpp/common/mediaplay/mediaplay.pri)
#include(./src/cpp/common/qhotkey/qhotkey.pri)
include(./src/cpp/common/qmousetracker/qmousetracker.pri)
include(./src/cpp/common/uidrageventcatch/uidrageventcatch.pri)
include(./src/cpp/common/uiframeless/uiframeless.pri)
include(./src/cpp/common/uipagescontroller/uipagescontroller.pri)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =


# Automatically run lupdate and lrelease during build
#QMAKE_EXTRA_COMPILERS += lrelease
#lrelease.input = TRANSLATIONS
#lrelease.output = ${QMAKE_FILE_BASE}.qm
#lrelease.commands = $$[QT_INSTALL_BINS]/lrelease ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
#lrelease.name = LRELEASE ${QMAKE_FILE_IN}
#lrelease.variable_out = QM_FILES
#PRE_TARGETDEPS += $$QM_FILES

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
