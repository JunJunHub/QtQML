import QtQuick 2.0
import Qt.WebSockets 1.15

Item {
    //定义消息回调接口映射表: key=moduleName value=mspCallBackFun
    property var msgCallBackFunMap

    //初始化入口
    function init() {
        msgCallBackFunMap = new Map();
        //msgCallBackFunMap.set("moduleName", );
    }

    //定义连接WS接口
    function connectFunc(url) {
        _wsSocket.url = url
        _wsSocket.active = true
    }

    //定义关闭WS接口
    function closeFunc() {
        _wsSocket.active = false
        _wsSocket.url = ""
    }

    //设置处理WS消息入口，支持设置多个
    function setHandleFunc(moduleName, handleFunc) {
        if (msgCallBackFunMap.hasOwnProperty(moduleName)) {
             console.log("WSClient# msgCallBackFunMap exist, key: ", moduleName);
        }
        msgCallBackFunMap.set(moduleName, handleFunc);
    }

    //WS文本消息处理入口(如何定义为私有接口)
    function _textMsgHandle(message) {
        try {
            var jsObj = JSON.parse(message)
            if (jsObj.topic === "emNotifyAlive") {
                //WS链路保活消息
                _wsSocket.sendTextMessage(message)
            } else {
                console.log("WSClient# Text message received, need to process: " + message);

                //将WS消息回传给各个模块处理数据更新通知
                for (const key in msgCallBackFunMap) {
                    if (msgCallBackFunMap.hasOwnProperty(key)) {
                        const handleFunc = msgCallBackFunMap[key];
                        handleFunc(jsObj); //调用函数并传入参数
                    }
                }
            }
        } catch (error) {
            console.log("WSClient#", message)
            console.log("WSClient# Text message received, failed to parse: " + error);
        }
    }

    //WS二进制消息处理入口
    function _binaryMsgHandle(message) {
        console.log("WSClient# Binary message received, no need to process: " + message);
    }

    //WS状态变更处理入口
    function _statusChangeHandle() {
        console.log('WSClient#', _wsSocket.url)
        if (_wsSocket.status === WebSocket.Connecting){
            console.log('WSClient#', 'socket Connecting')
        } else if (_wsSocket.status === WebSocket.Closing) {
            console.log('WSClient#', 'socket error' + _wsSocket.errorString)
        } else if (_wsSocket.status === WebSocket.Error) {
            console.log('WSClient#', 'socket error' + _wsSocket.errorString)
        } else if (_wsSocket.status === WebSocket.Open) {
            console.log('WSClient#', 'socket open')
        } else if (_wsSocket.status === WebSocket.Closed) {
            console.log('WSClient#', 'socket closed')
        }
    }

    //WS组件
    WebSocket {
        id:	_wsSocket
        url: ""
        active: false
        onBinaryMessageReceived: _binaryMsgHandle(message) //当接收到二进制消息时触发
        onTextMessageReceived: _textMsgHandle(message)     //当接收到文本消息时触发
        onStatusChanged: _statusChangeHandle()             //连接状态变更时触发
    }
}
