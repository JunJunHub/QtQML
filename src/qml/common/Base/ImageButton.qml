import QtQuick 2.12
import QtQuick.Controls 2.5

Button {
    id: _imgBtn
    implicitWidth: 38
    implicitHeight: 24
    property var imageSrc: ''
    property var hoverimageSrc: null
    property var backHoverColor: 'transparent'
    property var backColor: 'transparent'
    property alias radius: back.radius

    clip: true
    padding: 0
    background: Rectangle {
       id: back
       anchors.fill: parent
       color: _imgBtn.hovered ? backHoverColor : backColor
       Image {
           anchors.centerIn: parent
           antialiasing: true
           source: _imgBtn.hovered ? (hoverimageSrc == null? imageSrc : hoverimageSrc) : imageSrc
           fillMode: Image.PreserveAspectFit
       }
   }
}
