import QtQuick 2.14
import QtQuick.Controls 2.5

import "qrc:/Fontello.js" as Fontello

//支持自定义图标、清除按钮、文本显示隐藏按钮的文本输入组件

TextField {
    property bool showClearButton: false
    property bool passwordMode: false
    property bool passwordVisible: false
    property int inputHint: Qt.ImhLatinOnly | Qt.ImhPreferLowercase | Qt.ImhNoAutoUppercase
    property string icon: ""

    inputMethodHints: inputHint
    focus: true
    selectByMouse: true
    font.pixelSize: Math.min(dp(45), parent.height*0.1)
    horizontalAlignment: Text.AlignHCenter
    leftPadding: icon ? leftIcon.width*0.8 : dp(15)
    rightPadding: clsBtn.text ? clsBtn.width : dp(5)
    echoMode: (passwordMode && !passwordVisible) ? TextInput.Password : TextInput.Normal
    passwordMaskDelay: 500

    onPressed: g_inputPanel.visible = true; //当选择输入框的时候才显示虚拟键盘

    // left icon
    Label {
        id: leftIcon
        width: icon ? parent.height : 0;
        height: parent.height
        text: icon
        color: parent.text ? "Green" : "DarkGray"
        font {family: "fontello"; pixelSize: parent.height*0.6}
        verticalAlignment: Text.AlignVCenter
        leftPadding: dp(5)
    }

    // clean btn
    RoundButton {
        id: clsBtn
        focusPolicy: Qt.NoFocus
        visible: (showClearButton && parent.activeFocus && parent.text)
        anchors.right: parent.right
        anchors.rightMargin: dp(10)
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(dp(45),parent.width*0.6); height:  Math.min(dp(45),parent.height*0.4)
        flat: true
        text: showClearButton ? Fontello.Icons.trash : ""
        font {family: "fontello"; pixelSize: Math.min(dp(45), parent.height*0.4)}
        onClicked:  if(showClearButton) clear();
    }

    //右侧：密码可见 btn
    RoundButton {
        id: eyeItem
        focusPolicy: Qt.NoFocus
        visible: (passwordMode && parent.activeFocus && parent.text)
        width:  Math.min(dp(45),parent.width*0.6); height: Math.min(dp(45),parent.height*0.4)
        anchors.right: clsBtn.left
        anchors.rightMargin: dp(5)
        anchors.verticalCenter: parent.verticalCenter

        flat: true
        font {family: "fontello"; pixelSize:  Math.min(dp(45),parent.height*0.4)}
        text: (passwordMode && passwordVisible) ? Fontello.Icons.eye :
                                                  (passwordMode && !passwordVisible) ? Fontello.Icons.eyeInvisible : ""
        onClicked: {
            if(passwordMode)
                passwordVisible = !passwordVisible
        }
    }
}
