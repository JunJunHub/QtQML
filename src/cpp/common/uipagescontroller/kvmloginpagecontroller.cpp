#include "kvmloginpagecontroller.h"

#include <QDebug>

KVMLoginPageController::KVMLoginPageController(QObject *parent)
    : QObject{parent}
{
}

void KVMLoginPageController::signIn(const QString &hostname, quint16 port, const QString &username, const QString &password)
{
    //TODO 在这里可以使用 C++ 实现通过网络远程校验账密 或 本地数据库校验账密

    //以下是测试代码, 这里略去复杂数据库验证过程
    qDebug() << "FuncParams" << hostname << port << username << password;
    if( "admin" != username.trimmed() ){
        emit err("账号错误");
        return;
    }
    if( "admin" != password.trimmed() ){
        emit err("密码错误");
        return;
    }
    emit successed(true, "登录成功");
}
