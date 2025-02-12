import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.12
import QtQuick.VirtualKeyboard 2.14

import "qrc:/common/Base"
import "qrc:/common/KVMSkin"

Item {
    property int index: 5
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 22

        property int index: 5

        RowLayout {
            Layout.fillWidth: true

            //定义虚拟键盘 InputPanel
            // InputPanel {
            //     id: virtualKeyboardInputPanel
            //     anchors.bottom: parent.bottom
            //     z: 999 // 确保输入面板位于最上层
            // }

            spacing: 5

            BaseTextField {
                id: input
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                text: "数据块" + index
                font.pixelSize: 18
                font.family: "Microsoft Yahei"
                inputMethodHints: Qt.ImhDigitsOnly

                //当输入栏获取焦点时，显示虚拟键盘
                // onFocusChanged: {
                //     if (focus) {
                //         virtualKeyboardInputPanel.visible = true
                //         virtualKeyboardInputPanel.forceActiveFocus()
                //     }
                // }
            }
            SkinBaseButton {
                id: btn
                text: "添加"
                font.pixelSize: 17
                backRadius: 4
                onClicked: {
                    if (input.text.length > 0) {
                        list.append(input.text)
                        index += 1
                        input.text = "数据块" + index
                    }
                }
            }
        }

        QianDragView {
           id: list
           Layout.fillWidth: true
           Layout.fillHeight: true
           clip: true
        }

    }

}
