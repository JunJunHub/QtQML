import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15

import "qrc:/common"
import "qrc:/pages"
import "qrc:/pages/KVMResPage"  //坐席资源页面

import "qrc:/pages/QianProjectPages"
import "qrc:/pages/QianProjectPages/QianMergeWatermelonPage"
import "qrc:/pages/QianProjectPages/QianDragViewPage"

//右侧功能页面
StackLayout {
    id: stack
    clip: true

    //右侧功能区页面切换
    function switchPage(name) {
        for (var i = 0; i < stack.data.length; i++) {
            if (stack.data[i].name === name) {
                stack.currentIndex = i;
                break;
            }
        }
    }


    //坐席功能页面
    // KVMResPage {
    //     property string name: qsTr("trKVMResPageTitle")
    //     width: stack.width
    //     height: stack.height
    // }


    //以下是示例页面
    BaseControlPage {
        property string name: "Buttons"
        width: stack.width
        height: stack.height

    }
    BaseOtherControlPage {
        property string name: "Other"
        width: stack.width
        height: stack.height
    }
    HintPage {
        property string name: "提示"
        width: stack.width
        height: stack.height
    }
    QianPhotoPage {
        property string name: "图片预览器"
        width: stack.width
        height: stack.height
    }
    QianMergeWatermelonPage {
        property string name: "合成大西瓜"
        width: stack.width
        height: stack.height
    }
    QianDragViewPage {
        property string name: "DragView"
        width: stack.width
        height: stack.height
    }
 }
