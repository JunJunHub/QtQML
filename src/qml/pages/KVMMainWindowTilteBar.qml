import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.12
import Qt.KVM.SkinSingleton 1.0

import "qrc:/common/Base"
import "qrc:/common/KVMSkin"

//主功能区上部信息栏

Rectangle {
    id: windowtitle

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: {
            scaleInput.clicked();
        }
    }

    RowLayout {
        z: 2
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.margins: 0
        Layout.margins: 0
        spacing: 0

        Image {
            antialiasing: true
            source: "qrc:/res/icon.png"
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            fillMode: Image.PreserveAspectFit
        }

        YaheiText {
            text: g_rootWindow.title
            font.pixelSize: 17
            color: "#FFF"
            Layout.fillWidth: true
            Layout.leftMargin: 3
        }

        ImageButton {
            imageSrc: "qrc:/res/skin.png"
            Layout.alignment:  Qt.AlignTop | Qt.AlignRight
            backHoverColor: "#22FFFFFF"
            BaseToolTip {
                 visible: parent.hovered
                 text: "主题"
                 font.pixelSize: 12
                 delay: 1000
            }
            onClicked: {
                skin_popup.open()
            }
            padding: 3
        }

        ImageButton {
            imageSrc: "qrc:/res/minimize.png"
            Layout.alignment:  Qt.AlignTop | Qt.AlignRight
            backHoverColor: "#22FFFFFF"

            BaseToolTip {
                 visible: parent.hovered
                 text: "最小化"
                 font.pixelSize: 12
                 delay: 1000
            }
            onClicked: {
               showMinimized()
            }
            padding: 1
        }

        ScaleImageButton {
            id: scaleInput
            backHoverColor:"#22FFFFFF"
            normalImage: "qrc:/res/normal.png"
            maxImage: "qrc:/res/max.png"

            BaseToolTip {
                 visible: parent.hovered
                 text: scaleInput.shrink ? "最大化" : "恢复"
                 font.pixelSize: 12
                 delay: 1000
            }

            Layout.alignment : Qt.AlignTop | Qt.AlignRight
            focusPolicy: Qt.NoFocus
            onShrinkChanged: {
                g_rootWindow.maximized = !shrink
                g_rootWindow.update();
            }
            padding: 3
        }

        ImageButton {
            imageSrc: "qrc:/res/close.png"
            hoverimageSrc:"qrc:/res/close_hover.png"
            Layout.alignment:  Qt.AlignTop | Qt.AlignRight
            backHoverColor: "#FA5151"

            BaseToolTip {
                 visible: parent.hovered
                 text: "关闭"
                 font.pixelSize: 12
                 delay: 1000
            }
            onClicked: g_rootWindow.closeFunc()
            padding: 3
        }
    }

    SkinPopup {
        id: skin_popup
    }
}
