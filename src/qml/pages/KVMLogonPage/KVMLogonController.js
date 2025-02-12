.pragma library

// 使用 js 实现登录请求逻辑
// 注意 XMLHttpRequest 是异步操作

//实现方式二，使用 Promise 来处理异步操作，使代码更具可读性和可维护性
function signIn(userName, password) {
    return new Promise((resolve, reject) => {
        //创建 XMLHttpRequest 对象
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://10.67.69.50:80/mpuaps/v1/auth/login", true); // 替换为你的 API 地址

        //设置请求头
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept-Language", "zh_CN");

        // 请求成功时的回调
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    // 处理服务器返回的数据
                    var response = JSON.parse(xhr.responseText);
                    // 解析成功，将结果传递给 resolve
                    resolve(response);
                } else {
                    // 解析失败，将错误信息传递给 reject
                    reject(xhr.statusText);
                }
            }
        };

        // 网络请求失败时的回调
        xhr.onerror = function () {
            console.error("网络请求失败");
            // 网络错误，将错误信息传递给 reject
            reject("网络请求失败");
        };

        // 发送登录请求
        var raw = JSON.stringify({
           "userName": userName,
           "password": password,
           "idKey": "1234567",
           "validateCode": "1234567",
           "loginType": 0
        });
        xhr.send(raw);
    });
}
