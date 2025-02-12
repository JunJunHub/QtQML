import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.12

import Qt.KVM.YUVPlayWindow 1.0

import "qrc:/common"
Item {
    property int leftWidth: 182
    property int fontsize: 19

    KVMYUVPlayWindow {
        id: yuvPalyA
        anchors.fill: parent

    }

    // ColumnLayout {
    //     anchors.fill: parent
    //     anchors.rightMargin: 60
    //     anchors.topMargin: 30
    //     anchors.bottomMargin: 30
    //     anchors.leftMargin: 60
    //     spacing: 10



    //     Item {
    //         Layout.fillHeight: true
    //         Layout.fillWidth: true
    //     }

    // }
}
