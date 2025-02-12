import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.3
import QtQuick.Window 2.15
import QtQuick.VirtualKeyboard 2.14
import QtGraphicalEffects 1.12
import Qt.WebSockets 1.15
import Qt.labs.platform 1.1
import Qt.labs.settings 1.0

import Qt.KVM.SkinSingleton 1.0
import Qt.KVM.Log4Qml 1.0

import "qrc:/common"
import "qrc:/common/KVMHints"
import "qrc:/pages"
import "qrc:/pages/KVMLogonPage"

//根窗口. TODO 程序运行在不同的环境(嵌入式盒子|Win主机|安卓Pad)，根窗口有不同的样式设置
ApplicationWindow {
    id: g_rootWindow

    //根窗口属性
    Material.accent: accentColor
    Material.theme: skin.light ? Material.Light : Material.Dark
    Material.foreground: tingeColor
    visible: true
    //visibility: Window.Minimized
    visibility: Window.FullScreen
    //color: "transparent"
    //flags: Qt.FramelessWindowHint
    title: g_titleStr
    font.pixelSize: dp(30);  // 全局字体 ApplicationWindow
    width: 1920
    height: 1080
    minimumWidth: 1130
    minimumHeight: 730

    //扩展属性定义
    property string g_titleStr: qsTr("trGUITitle") //根窗口标题
    property int    g_runningEnv: g_kvmAppSetting.runningEnv
    property bool   g_recordPassword: g_kvmAppSetting.recordPassword
    property bool   g_autoLogon: g_kvmAppSetting.autoLogon
    property string g_userName: g_kvmAppSetting.username
    property string g_passWord: g_kvmAppSetting.recordPassword ? g_kvmAppSetting.passWord : ""
    property string g_hostIp: g_kvmAppSetting.hostIp
    property int    g_hostPort: g_kvmAppSetting.hostPort
    property string g_accessToken: ""
    property bool   g_logonSuccess: false

    property bool   dataPrepared: true
    property var    myData
    property bool   dark
    property real   dpScale: 1     //分辨率: 范围(0.8 ~ 2) //还可以添加 PinchArea 指捏缩放

    readonly property real pixelPerDp: Screen.pixelDensity * 0.12

    function dp(x) { return x * pixelPerDp * dpScale }


    //定义全局统一的 RGBA 颜色参数，供各页面 UI 控件使用
    property color accentColor: SkinSingleton.skins[g_kvmAppSetting.skinIndex].accentColor              // 皮肤深色
    property color accentContrlColor: SkinSingleton.skins[g_kvmAppSetting.skinIndex].accentContrlColor  // 皮肤控件深色
    property color accentOpacityColor: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.5)        // 皮肤控件深色透明 (一般用在滚动条)
    property color accentOpacityHoverColor: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.45)  // 皮肤控件深色透明淡色 (一般用在滚动条鼠标徘徊)

    property color tingeColor: skin.light ? "#555" : "#b1b1b1"                      // 皮肤淡色(白色皮肤为浅黑，黑色皮肤为灰色)
    property color tingeDrakerColor: Qt.darker(tingeColor, 1.2)                     // 皮肤谈深色
    property color tingeOpacityColor: skin.light ? "#11000000" : "#11FFFFFF"        // 皮肤谈透明色
    property color tingeOpacityLightColor: skin.light ? "#06000000" : "#06FFFFFF"   // 皮肤谈透明色(亮)

    //主色调
    property color mainColor: !skin.gradSupport && !skin.imageSupport ? skin.mainColor :
                            !skin.light ? Qt.rgba(0,0,0, skin.gradMainOpacity - g_kvmAppSetting.skinOpacity * 0.48) : Qt.rgba(1,1,1, skin.gradMainOpacity + g_kvmAppSetting.skinOpacity * 0.28)

    //当前生效的皮肤
    property var skin: SkinSingleton.skins[g_kvmAppSetting.skinIndex]


    //加载不同的组件，实现页面切换
    Loader {
        id: g_RootPageLoader
        anchors.centerIn: parent
        sourceComponent: loginPage
    }
    Component{ id: loginPage; KVMLogonPage {} }
    Component{ id: mainWinEntry; KVMMainWindowEntry {
            //主功能界面入口
            //TODO 根据运行环境，调整主界面布局
            //     在嵌入式边端设备，rootWindow 始终全屏。主功能区居中，并占 rootWindow 的 3/5
            //     在普通的桌面系统，rootWindow 设置大小。主功能区填充整个 rootWindow

            anchors.fill: parent //将主功能区矩形填充整个根窗口

            // 将主功能区矩形锚定在父项中央
            // width: g_rootWindow.width * 0.80
            // height: g_rootWindow.height * 0.80
            // anchors.centerIn: parent

            anchors.margins: g_rootWindow.maximized ? 0 : 8
            radius: g_rootWindow.maximized ? 0 : 4
        }
    }


    //全局消息提示组件
    Message {
        id: g_hintMessageTip
        z: 1
        parent: Overlay.overlay

        function setHintMessage(type, message) {
            if(type !== 'success' && type !== 'error' && type !== 'info'){
                return false
            }
            g_hintMessageTip.open(type, message)
        }
    }

    //全局WS客户端
    KVMWSClient { id: g_wsClient }

    //全局APP配置文件
    Settings {
        id: g_kvmAppSetting
        fileName: "app.ini"

        //运行环境
        property int runningEnv: 1

        //皮肤
        property int skinIndex: 1
        property real skinOpacity: 1
        property string skinCustomFile: ""

        //登录账户信息. 记住输入参数，方便下次登录
        property alias recordPassword: g_rootWindow.g_recordPassword
        property alias autoLogon: g_rootWindow.g_autoLogon
        property alias username: g_rootWindow.g_userName
        property alias password: g_rootWindow.g_passWord
        property alias hostIp: g_rootWindow.g_hostIp
        property alias hostPort: g_rootWindow.g_hostPort
    }

    //全局虚拟键盘控件，实现自适应虚拟键盘大小及宽高。默认很宽，很高，而且不好切换语言
    InputPanel {
        id: g_inputPanel
        z: 99
        x: (g_rootWindow.width-g_inputPanel.width)*0.5
        y: g_rootWindow.height
        width: getwidth(g_rootWindow.width, g_rootWindow.height, dp(1100))

        states: State {
            name: "visible"
            when: g_inputPanel.active
            PropertyChanges {
                target: g_inputPanel
                y: g_rootWindow.height - g_inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"

            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }


    //
    function getwidth(w, h, v) {
        var width=0; var tmp=v;
        if(w>tmp)
            if(h>tmp) width=tmp; else width=h;
        else
            if(w>tmp) width=tmp; else width=w;
        return width
    }

    //定义关闭窗口处理接口
    function closeFunc() {
        //Log4Qml.logDebug("This is an debug message from QML");
        //Log4Qml.logInfo("This is an info message from QML");
        //Log4Qml.logWarn("This is an warn message from QML");
        //Log4Qml.logError("This is an error message from QML");
        close();
    }
}
