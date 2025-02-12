import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.14

import "qrc:/common/Base"
import "qrc:/common/KVMSkin"

Rectangle {
    id: mainPage
    width: g_rootWindow.width
    height: g_rootWindow.height
    color: "transparent"

    Component.onCompleted: { timer.start() }

    //当前日期时间
    function currentDateTime(){
        return Qt.formatDateTime(new Date(), "  hh:mm:ss\nM月d日 ddd");
    }

    //定时器
    Timer {
        id: timer
        repeat: true   //重复
        interval: 1000 //间隔(单位毫秒)
        triggeredOnStart:true //启动时立即触发，而不是等待 1 秒后触发
        onTriggered:  textDateTime.text = currentDateTime();
    }

    //显示系统当前时间
    Label {
        id: textDateTime
        text: currentDateTime();
        anchors.centerIn: parent
    }

    Button {
        text: "退出登录"
        anchors.top: textDateTime.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: g_RootPageLoader.sourceComponent = loginPage
    }
}
