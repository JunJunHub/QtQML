#ifndef DragEventCatch_H
#define DragEventCatch_H

#include <QObject>

// 拖拽事件捕获，封装实现窗口拖拽效果的基础类
class DragEventCatch : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject* container READ container WRITE setContainer NOTIFY containerChanged)
    Q_PROPERTY(QObject* filterObj READ filterObj WRITE setFilterObj NOTIFY filterObjChanged)

    Q_PROPERTY(bool catchEnable MEMBER _catchEnable NOTIFY catchEnableChanged)

signals:
    void containerChanged();
    void filterObjChanged();
    void catchEnableChanged();

public:
    explicit DragEventCatch(QObject *parent = nullptr);
    ~DragEventCatch();

    QObject *container() { return _container; }
    void setContainer(QObject *container);

    QObject *filterObj() { return  _filterObj; }
    void setFilterObj(QObject *container);

    bool eventFilter(QObject *obj, QEvent *evt);


signals:
    void released(int mouseX, int mouseY);
    void pressed(int mouseX, int mouseY);
    void moved(int mouseX, int mouseY);

protected:

    QObject *_container{nullptr};
    QObject *_filterObj{nullptr};
    bool _catchEnable{true};
};

#endif //DragEventCatch_H
