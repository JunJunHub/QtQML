#ifndef QMOUSETRACKER_H
#define QMOUSETRACKER_H

#include <QApplication>
#include <QEvent>
#include <QMouseEvent>
#include <QKeyEvent>
#include <QDebug>

class GlobalEventFilter : public QObject {
    Q_OBJECT

public:
    bool hasMouse() const;

protected:
    bool eventFilter(QObject *obj, QEvent *event) override {
        if (event->type() == QEvent::KeyPress) {
            QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);
            handleKeyPress(keyEvent);
            return true; // 表示事件已被处理

        } else if (event->type() == QEvent::MouseMove) {
            QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
            handleMouseMove(mouseEvent);
            return false; // 返回 false 表示继续传递事件给原始接收者
        }
        return QObject::eventFilter(obj, event);
    }

private:
    void handleKeyPress(QKeyEvent *event) {
        if (event->modifiers() & Qt::ControlModifier && event->key() == Qt::Key_S) {
            qInfo() << "QKeyEvent Ctrl + S pressed";
            // 在这里添加你的快捷键逻辑
        }
        // 可以根据需要添加更多快捷键处理
    }

    void handleMouseMove(QMouseEvent *event) {
        qInfo() << "Mouse moved to:" << event->globalPos();
        // 在这里添加鼠标移动逻辑
    }
};

#endif // QMOUSETRACKER_H
