#include "qiandrageventcatch.h"
#include <QMouseEvent>
#include <QDebug>

DragEventCatch::DragEventCatch(QObject *parent) : QObject(parent)
{

}


DragEventCatch::~DragEventCatch()
{
    if (_container)
        _container->removeEventFilter(this);

    if (_filterObj)
        _filterObj->removeEventFilter(this);

}

void DragEventCatch::setContainer(QObject *target)
{
    if (!target) return;

    if (_container != target) {
        if (_container) _container->removeEventFilter(this);
        target->installEventFilter(this);
        _container = target;
        emit containerChanged();
    }
}

void DragEventCatch::setFilterObj(QObject *target)
{
    if (!target) return;

    if (_filterObj != target) {
        if (_filterObj) _filterObj->removeEventFilter(this);
        target->installEventFilter(this);
        _filterObj = target;
        emit filterObjChanged();
    }
}


bool DragEventCatch::eventFilter(QObject *obj, QEvent *evt)
{
    QMouseEvent *mouse =  dynamic_cast<QMouseEvent *>(evt);
    if(mouse ) {
        if(mouse->button() == Qt::LeftButton && mouse->type() == QEvent::MouseButtonPress) {
            _catchEnable = true;
            emit pressed(mouse->pos().x(), mouse->pos().y());
        } else if(mouse->buttons() == Qt::LeftButton && mouse->type() == QEvent::MouseMove && _catchEnable) {
            emit moved(mouse->pos().x(), mouse->pos().y());
        } else if(mouse->button() == Qt::LeftButton && mouse->type() ==QEvent::MouseButtonRelease && _catchEnable) {
            emit released(mouse->pos().x(), mouse->pos().y());
        }
    }
    return QObject::eventFilter(obj, evt);
}
