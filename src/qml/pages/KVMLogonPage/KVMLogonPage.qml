import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.14

import "qrc:/pages/KVMLogonPage/component"

Item {
    width: g_rootWindow.width;
    height: g_rootWindow.height
    anchors.centerIn: parent

    //本设备ID
    property string device_id: "98323fa12432c923c"

    Component.onCompleted: g_titleStr = "账户登录"

    Component{ id: compLogon; Logon{} }
    Component{ id: compServerCfg; ServerConfig{} }

    // Logo
    Item {
        id: logo_rect
        width: logo.width;
        height: parent.height*0.5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        Image {
            id: logo
            width: logo.height*5
            height: getwidth(g_rootWindow.width*0.15, g_rootWindow.height*0.15, dp(120))
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            source: "qrc:/res/icon.png"
        }
    }

    //登录页 login 或者 ip/port
    Loader{
        id: _loginPageLoader
        anchors.centerIn: parent
        sourceComponent: compLogon
        width: logo.width*1.15
        height: logo.height*3
    }

    //设备信息显示
    Label {
        id: devid
        font.pixelSize: Math.min(g_rootWindow.height*0.025, dp(30))
        text: "设备 ID: " + device_id
        anchors.bottom: copyrightRect.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    //页脚显示版权信息 Footer
    Rectangle {
        id: copyrightRect
        width: parent.width; height: Math.min(dp(250), g_rootWindow.height*0.15)
        anchors.bottom: parent.bottom
        color: "transparent"

        Label {
            id: copyright
            font.pixelSize: Math.min(g_rootWindow.height*0.026, dp(28))
            text: "版权所有@ 科达科技有限公司"
            anchors.bottom: copyright2.top
            anchors.bottomMargin: Math.min(dp(10),g_rootWindow.height*0.005)
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: copyright2
            font.pixelSize: Math.min(g_rootWindow.height*0.022, dp(25))
            text: "Copyright © 2024-"+ Qt.formatDateTime(new Date(), "yyyy") +" Kedacom Technology Co., LTD."
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Math.min(dp(60), g_rootWindow.height*0.04)
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
