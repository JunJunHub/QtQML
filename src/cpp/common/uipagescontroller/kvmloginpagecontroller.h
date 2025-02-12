#ifndef KVMLOGINPAGECONTROLLER_H
#define KVMLOGINPAGECONTROLLER_H

#include <QObject>

class KVMLoginPageController : public QObject
{
    Q_OBJECT
public:
    explicit KVMLoginPageController(QObject *parent = nullptr);

    //Q_INVOKABLE 让 QML 可访问
    Q_INVOKABLE void signIn(const QString &hostname, quint16 port, const QString &username, const QString &password);

signals:
    void successed(bool succeeded, QString data);
    void err(const QString &err);

private:

};

#endif // KVMLOGINPAGECONTROLLER_H
