import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3

import "qrc:/pages/KVMLogonPage"
import "qrc:/pages/KVMLogonPage/base"
import "qrc:/Fontello.js" as Fontello

Item {
    //服务器IP输入框
    IconTextField {
        id: ipInput
        width: parent.width
        icon: Fontello.Icons.pc
        text: g_hostIp
        placeholderText: "服务器 IP"
        inputHint: Qt.ImhDigitsOnly
        validator: RegExpValidator{regExp:/((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))/}
        showClearButton: true
        onAccepted: portInput.focus = true
    }

    //服务器端口输入框
    IconTextField {
        id: portInput
        width: parent.width
        anchors.top: ipInput.bottom
        anchors.topMargin: dp(10)
        icon: Fontello.Icons.location
        text: g_hostPort
        placeholderText: "服务器端口"
        inputHint: Qt.ImhDigitsOnly
        validator: RegExpValidator{regExp:/^([0-9]|[1-9]\d{1,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$/}
        showClearButton: true
        onAccepted: pop_sure.focus = true
    }

    Row {
        spacing: dp(10)
        anchors.top: portInput.bottom
        anchors.topMargin: dp(50)
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            text: "取消"
            font.pixelSize: Math.min(dp(40), g_rootWindow.height*0.03)
            width: pop_sure.width
            height: ipInput.height
            onClicked: {
                //恢复IP、Port
                ipInput.text = g_hostIp
                portInput.text = g_hostPort

                //切换至登录页
                _loginPageLoader.sourceComponent = compLogon
            }
        }

        Button {
            id: pop_sure
            width: ipInput.width*0.5
            height: ipInput.height
            highlighted: true
            text: "确认"
            font.pixelSize: Math.min(dp(40), g_rootWindow.height*0.03)
            Material.background: "Green"
            onClicked: {
                //记住IP、Port
                g_hostIp = ipInput.text
                g_hostPort = parseInt(portInput.text)

                //切换至登录页
                _loginPageLoader.sourceComponent = compLogon
            }
        }
    }
}
