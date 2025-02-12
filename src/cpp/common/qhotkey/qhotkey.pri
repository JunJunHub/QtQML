INCLUDEPATH += $$PWD
DEPENDPATH += $$PWD


HEADERS += $$PWD/qhotkey.h \
           $$PWD/qhotkey_p.h

SOURCES += $$PWD/qhotkey.cpp \

# Windows平台（win32）
win32 {
    SOURCES += $$PWD/qhotkey_win.cpp
}

# MacOS平台
mac {
    SOURCES += $$PWD/qhotkey_mac.cpp
}

# Linux平台（unix）
unix:!mac {
    SOURCES += $$PWD/qhotkey_x11.cpp
    #SOURCES += $$PWD/qhotkey_linux_evdev1.cpp
}
