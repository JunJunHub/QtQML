import QtQuick 2.12
import QtQuick.Layouts 1.14
import QtQuick.Controls.Material 2.12
import QtQuick.Controls 2.14

import "qrc:/common/Base"
import "qrc:/pages/KVMStretchlist"

Sidebar {
    z:100
    height: parent.height
    horizontalPosBase: Sidebar.PosToLeft
    property alias stretchEntry: _stretchEntry

    StretchEntry {
        id: _stretchEntry
        anchors.fill: contentObj
        clip: true
    }
}
