import QtQuick 2.14
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.12

import Qt.KVM.Log4Qml 1.0

import "qrc:/common/Base"
import "qrc:/pages/KVMLogonPage"
import "qrc:/pages/KVMLogonPage/base"
import "qrc:/pages/KVMLogonPage/KVMLogonController.js" as JsLoginController
import "qrc:/Fontello.js" as Fontello

Item {
    //输入框: 用户名
    IconTextField {
        id: unInput
        width: parent.width
        icon: Fontello.Icons.home
        text: g_userName
        showClearButton: true
        placeholderText: "请输入账号"
        onAccepted: pwInput.focus = true
    }

    //输入框: 密码
    IconTextField {
        id: pwInput
        width: parent.width
        anchors.top: unInput.bottom        
        anchors.topMargin: Math.min(dp(10), parent.height*0.005)
        icon: pwInput.passwordVisible ? Fontello.Icons.lockClose : Fontello.Icons.lockClose
        passwordMode: true
        showClearButton: true
        text: g_passWord
        placeholderText: "请输入密码"
        onAccepted: signInButton.focus = true
    }

    //登录按钮
    Button {
        id: signInButton
        anchors.top: pwInput.bottom
        anchors.topMargin: Math.min(dp(50), parent.height*0.03)
        width: pwInput.width;  height: unInput.height*1.1
        anchors.horizontalCenter: parent.horizontalCenter
        highlighted: true
        enabled: (unInput.text && pwInput.text)? true:false
        text: "登  录"
        font.pixelSize: Math.min(dp(40), g_rootWindow.height*0.03)
        Material.background: "Green"
        onClicked: doSignIn()
    }

    //记住密码、自动登录
    RowLayout {
        id: checkBoxLayout
        anchors.top: signInButton.bottom

        BaseCheckBox {
          font.pixelSize: Math.min(dp(40), g_rootWindow.height*0.03)
          text: "记住密码"
        }
        BaseCheckBox {
          font.pixelSize: Math.min(dp(40), g_rootWindow.height*0.03)
          text: "自动登录"
        }
        //设置服务端 ip/port
        RoundButton {
            id: roundbtn
            text: Fontello.Icons.config + "设置"
            flat: true
            font.family: "fontello"
            font.pixelSize: Math.min(dp(40), g_rootWindow.height*0.03)
            onClicked: _loginPageLoader.sourceComponent = compServerCfg
        }
    }


    //点击登录显示实现
    function doSignIn() {
        //记录用户最后输入的用户名、密码
        g_userName = unInput.text;
        g_passWord = pwInput.text;

        //js 业务实现
        JsLoginController.signIn(g_userName, g_passWord)
            .then((response) => {
                // console.log("response typeof", typeof response); // 打印变量的类型，帮助调试
                // console.log("response object:", response)
                // console.log("response Available methods:", Object.getOwnPropertyNames(response))

                if (response.code !== 0) {
                    //登录失败
                    g_hintMessageTip.setHintMessage('error', response.msg)

                } else {
                    console.log("登录成功，处理响应:", response.data.token);
                    //Log4Qml.logInfo("This is an info message from QML");

                    g_accessToken = response.data.token

                    //连接WS
                    var url = "ws://10.67.69.50:80/mpuaps/v1/ws/subscribe/" + response.data.token
                    g_wsClient.connectFunc(url);
                    console.log("ws connect url:", url)

                    //切换页面
                    //g_RootPageLoader.sourceComponent = mainPage
                    g_RootPageLoader.sourceComponent = mainWinEntry;
                    _loginPageLoader.sourceComponent = undefined; // 卸载登录页
                }
            }).catch((error) => {
                console.log("登录失败，错误信息:", error);
                g_hintMessageTip.setHintMessage("error", error)
            });
    }
}
