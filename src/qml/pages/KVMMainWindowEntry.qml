import QtQuick 2.12
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14

import Qt.KVM.SkinSingleton 1.0

import "qrc:/common/Base"
import "qrc:/common/KVMTipsDialog"

Rectangle {
    id: windowEntry
    color: skin.mainColor
    gradient: skin.gradient

    //登录成功弹窗提示对话框
    BlogDialog {
        id: skinQianDialog
        backParent: windowEntry
        parent: Overlay.overlay
        onAccept: {
            g_hintMessageTip.setHintMessage('success', "You clicked the accept button!")
            skinQianDialog.close();
        }
    }

    //组件
    Component.onCompleted: {
        skinQianDialog.dialogOpen()
    }

    layer.enabled: skin.windowShadow && !appStartAnimation.running && !g_rootWindow.maximized? true : false
    layer.effect: DropShadow {
        color: "#000000"
    }

    //主功能页面布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        //标题栏
        KVMMainWindowTilteBar {
            color: skin.titleColor
            Layout.fillWidth: true
            Layout.preferredHeight: contentList.fullscreen ? 0 :  42
            Layout.alignment: Qt.AlignTop
            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 300 }
            }
            clip: true
        }

        //主功能区
        KVMMainWindowContentList {
            id: contentList
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    //动画
    SequentialAnimation {
        id: appStartAnimation
        running: true
        NumberAnimation {
            target: windowEntry;
            properties: "scale"; from: 0.3; to: 1.0; easing.type: Easing.InOutQuad; duration: 200 }
    }
}
