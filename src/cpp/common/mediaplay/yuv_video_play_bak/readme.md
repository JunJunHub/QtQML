# Qt6.2.3播放YUV视频，使用QOpenGLWidget  

|作者|将狼才鲸|
|---|---|
|创建日期|2022-03-30|

* 工程Gitee源码地址：[qt_gui_simple2complex/ source / 004_MultiMedia_VideoAudio / 003_yuv_video_play](https://gitee.com/langcai1943/qt_gui_simple2complex/tree/develop/source/004_MultiMedia_VideoAudio/003_yuv_video_play)  
* CSDN文章阅读地址：[Qt6.2.3播放YUV视频，使用QOpenGLWidget](https://blog.csdn.net/qq582880551/article/details/123858465)  
* 视频讲解地址（待完成）：[才鲸嵌入式](https://space.bilibili.com/106424039)  

* 参考资料：
[qt采用opengl显示yuv视频数据](https://blog.csdn.net/su_vast/article/details/52214642)
[Qt 创建定时器](https://blog.csdn.net/weixin_38416696/article/details/92838813)

* 该工程在Qt5.15.2、Qt6.0.4和Qt6.2.3下都测试通过。  
* 为什么要在QOpenGLWidget中播放原始YUV视频：  
当前版本没找到Qt不用OpenGL，自己显示YUV视频帧的方法（好像以后Qt会支持），所以还是需要使用QOpenGLWidget。  
可以将YUV转成RGB，然后用QImage逐帧显示，但是这样占CPU资源，没有使用QOpenGL有效率。  

---

## 一、实现原理  

* 使用方法：  
1、新建一个类继承于QOpenGLWidget；  
2、使用定时器，按帧率调用QOpenGLWidget::update();
3、update()被调用后，QOpenGLWidget::paintGL()会自动被调用，在里面进行显示；  
4、使用QOpenGLFunctions::glTexImage2D传入一帧数据进行显示；  

## 二、效果与源码展示  

* 效果：  
![image](https://gitee.com/langcai1943/qt_gui_simple2complex/raw/develop/source/004_MultiMedia_VideoAudio/003_yuv_video_play/documents/003_yuv_video_play.gif)  

* cplaywidget.cpp  

```cpp
#include "cplaywidget.h"
#include <QOpenGLTexture>
#include <QOpenGLBuffer>
#include <QMouseEvent>
#include <QTimer>

CPlayWidget::CPlayWidget(QWidget *parent) : QOpenGLWidget(parent)
{
    textureUniformY = 0;
    textureUniformU = 0;
    textureUniformV = 0;
    id_y = 0;
    id_u = 0;
    id_v = 0;
    m_pBufYuv420p = NULL;
    m_pVSHader = NULL;
    m_pFSHader = NULL;
    m_pShaderProgram = NULL;
    m_pTextureY = NULL;
    m_pTextureU = NULL;
    m_pTextureV = NULL;
    m_pYuvFile = NULL;
    m_nVideoH = 0;
    m_nVideoW = 0;
}

CPlayWidget::~CPlayWidget()
{
}

void CPlayWidget::PlayOneFrame()
{
    // 函数功能读取一张yuv图像数据进行显示，每进入一次，就显示一张图片
    if (NULL == m_pYuvFile)
    {
        // 打开yuv视频文件 注意修改文件路径
        // 可以自行将fopen改为QFile中最新的文件操作接口
        m_pYuvFile = fopen("../003_yuv_video_play/003_yuv_video_play.yuv", "rb");

        // 根据yuv视频数据的分辨率设置宽高，demo当中是128下6，这个地方要注意跟实际数据分辨率对应上
        m_nVideoW = 128;
        m_nVideoH = 96;
    }

    // 申请内存存一帧yuv图像数据，其大小为分辨率的1.5倍
    int nLen = m_nVideoW * m_nVideoH * 3 / 2;
    if (NULL == m_pBufYuv420p)
    {
        m_pBufYuv420p = new unsigned char[nLen];
        qDebug("CPlayWidget::PlayOneFrame new data memory. Len=%d width=%d height=%d\n",
               nLen, m_nVideoW, m_nVideoW);
    }

    // 将一帧yuv图像读到内存中
    if(NULL == m_pYuvFile)
    {
        qFatal("read yuv file err.may be path is wrong!\n");
        return;
    }

    // 读一帧数据
    if (fread(m_pBufYuv420p, 1, nLen, m_pYuvFile) != nLen)
    {
        // 关闭文件，并准备重新循环打开播放
        fclose(m_pYuvFile);
        m_pYuvFile = NULL;
    }

    // 刷新界面,触发paintGL接口
    update();

    return;
}

void CPlayWidget::initializeGL()
{
    initializeOpenGLFunctions();
    glEnable(GL_DEPTH_TEST);

    // opengl渲染管线依赖着色器来处理传入的数据
    // 着色器：就是使用openGL着色语言(OpenGL Shading Language, GLSL)编写的一个小函数,
    //       GLSL是构成所有OpenGL着色器的语言,具体的GLSL语言的语法需要读者查找相关资料
    // 初始化顶点着色器、对象
    m_pVSHader = new QOpenGLShader(QOpenGLShader::Vertex, this);

    // 顶点着色器源码
    const char *vsrc = "attribute vec4 vertexIn; \
    attribute vec2 textureIn; \
    varying vec2 textureOut;  \
    void main(void)           \
    {                         \
        gl_Position = vertexIn; \
        textureOut = textureIn; \
    }";

    // 编译顶点着色器程序
    bool bCompile = m_pVSHader->compileSourceCode(vsrc);
    if(!bCompile)
    {
    }

    // 初始化片段着色器功能gpu中yuv转换成rgb
    m_pFSHader = new QOpenGLShader(QOpenGLShader::Fragment, this);

    // 片段着色器源码
    const char *fsrc = "varying vec2 textureOut; \
    uniform sampler2D tex_y; \
    uniform sampler2D tex_u; \
    uniform sampler2D tex_v; \
    void main(void) \
    { \
        vec3 yuv; \
        vec3 rgb; \
        yuv.x = texture2D(tex_y, textureOut).r; \
        yuv.y = texture2D(tex_u, textureOut).r - 0.5; \
        yuv.z = texture2D(tex_v, textureOut).r - 0.5; \
        rgb = mat3( 1,       1,         1, \
                    0,       -0.39465,  2.03211, \
                    1.13983, -0.58060,  0) * yuv; \
        gl_FragColor = vec4(rgb, 1); \
    }";

    // 将glsl源码送入编译器编译着色器程序
    bCompile = m_pFSHader->compileSourceCode(fsrc);
    if(!bCompile)
    {
    }

#define PROGRAM_VERTEX_ATTRIBUTE 0
#define PROGRAM_TEXCOORD_ATTRIBUTE 1
    // 创建着色器程序容器
    m_pShaderProgram = new QOpenGLShaderProgram;
    // 将片段着色器添加到程序容器
    m_pShaderProgram->addShader(m_pFSHader);
    // 将顶点着色器添加到程序容器
    m_pShaderProgram->addShader(m_pVSHader);
    // 绑定属性vertexIn到指定位置ATTRIB_VERTEX,该属性在顶点着色源码其中有声明
    m_pShaderProgram->bindAttributeLocation("vertexIn", ATTRIB_VERTEX);
    // 绑定属性textureIn到指定位置ATTRIB_TEXTURE,该属性在顶点着色源码其中有声明
    m_pShaderProgram->bindAttributeLocation("textureIn", ATTRIB_TEXTURE);
    // 链接所有所有添入到的着色器程序
    m_pShaderProgram->link();
    // 激活所有链接
    m_pShaderProgram->bind();

    // 读取着色器中的数据变量tex_y, tex_u, tex_v的位置,这些变量的声明可以在
    // 片段着色器源码中可以看到
    textureUniformY = m_pShaderProgram->uniformLocation("tex_y");
    textureUniformU = m_pShaderProgram->uniformLocation("tex_u");
    textureUniformV = m_pShaderProgram->uniformLocation("tex_v");

    // 顶点矩阵
    static const GLfloat vertexVertices[] = {
        -1.0f, -1.0f,
         1.0f, -1.0f,
         -1.0f, 1.0f,
         1.0f, 1.0f,
    };

    // 纹理矩阵
    static const GLfloat textureVertices[] = {
        0.0f,  1.0f,
        1.0f,  1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };

    // 设置属性ATTRIB_VERTEX的顶点矩阵值以及格式
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, vertexVertices);
    // 设置属性ATTRIB_TEXTURE的纹理矩阵值以及格式
    glVertexAttribPointer(ATTRIB_TEXTURE, 2, GL_FLOAT, 0, 0, textureVertices);
    // 启用ATTRIB_VERTEX属性的数据,默认是关闭的
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    // 启用ATTRIB_TEXTURE属性的数据,默认是关闭的
    glEnableVertexAttribArray(ATTRIB_TEXTURE);

    // 分别创建y,u,v纹理对象
    m_pTextureY = new QOpenGLTexture(QOpenGLTexture::Target2D);
    m_pTextureU = new QOpenGLTexture(QOpenGLTexture::Target2D);
    m_pTextureV = new QOpenGLTexture(QOpenGLTexture::Target2D);
    m_pTextureY->create();
    m_pTextureU->create();
    m_pTextureV->create();

    // 获取返回y分量的纹理索引值
    id_y = m_pTextureY->textureId();
    // 获取返回u分量的纹理索引值
    id_u = m_pTextureU->textureId();
    // 获取返回v分量的纹理索引值
    id_v = m_pTextureV->textureId();
    glClearColor(0.3,0.3,0.3,0.0); // 设置背景色
//    qDebug("addr=%x id_y = %d id_u=%d id_v=%d\n", this, id_y, id_u, id_v);

    // 启动定时器
    QTimer *ti = new QTimer(this);
    connect(ti, SIGNAL(timeout()), this, SLOT(PlayOneFrame()));
    ti->start(40);
}
void CPlayWidget::resizeGL(int w, int h)
{
    if (h == 0) // 防止被零除
    {
        h = 1;  // 将高设为1
    }

    // 设置视口
    glViewport(0, 0, w, h);
}

 void CPlayWidget::paintGL()
 {
    // 加载y数据纹理
    // 激活纹理单元GL_TEXTURE0
    glActiveTexture(GL_TEXTURE0);

    // 使用来自y数据生成纹理
    glBindTexture(GL_TEXTURE_2D, id_y);

    // 使用内存中m_pBufYuv420p数据创建真正的y数据纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, m_nVideoW, m_nVideoH, 0, GL_RED, GL_UNSIGNED_BYTE, m_pBufYuv420p);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // 加载u数据纹理
    glActiveTexture(GL_TEXTURE1); // 激活纹理单元GL_TEXTURE1
    glBindTexture(GL_TEXTURE_2D, id_u);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, m_nVideoW / 2, m_nVideoH / 2, 0, GL_RED,
                 GL_UNSIGNED_BYTE, (char *)m_pBufYuv420p + m_nVideoW * m_nVideoH);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // 加载v数据纹理
    glActiveTexture(GL_TEXTURE2); // 激活纹理单元GL_TEXTURE2
    glBindTexture(GL_TEXTURE_2D, id_v);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, m_nVideoW / 2, m_nVideoH / 2, 0, GL_RED,
                 GL_UNSIGNED_BYTE, (char *)m_pBufYuv420p + m_nVideoW * m_nVideoH * 5 / 4);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // 指定y纹理要使用新值 只能用0,1,2等表示纹理单元的索引，这是opengl不人性化的地方
    // 0对应纹理单元GL_TEXTURE0 1对应纹理单元GL_TEXTURE1 2对应纹理的单元
    glUniform1i(textureUniformY, 0);
    // 指定u纹理要使用新值
    glUniform1i(textureUniformU, 1);
    // 指定v纹理要使用新值
    glUniform1i(textureUniformV, 2);
    // 使用顶点数组方式绘制图形
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    return;
 }
```

* cplaywidget.h  

```cpp
#ifndef CPLAYWIDGET_H
#define CPLAYWIDGET_H

#include <QOpenGLWidget>
#include <QOpenGLShaderProgram>
#include <QOpenGLFunctions>
#include <QOpenGLTexture>
#include <QFile>

#define ATTRIB_VERTEX 3
#define ATTRIB_TEXTURE 4

class CPlayWidget : public QOpenGLWidget, protected QOpenGLFunctions
{
    Q_OBJECT

public:
    CPlayWidget(QWidget* parent = nullptr);
    ~CPlayWidget();

public slots:
    void PlayOneFrame();

protected:
    void initializeGL() Q_DECL_OVERRIDE;
    void resizeGL(int w, int h) Q_DECL_OVERRIDE;
    void paintGL() Q_DECL_OVERRIDE;

private:
    /**
     * 纹理是一个2D图片，它可以用来添加物体的细节（贴图），纹理可以各种变形后
     * 贴到不同形状的区域内。这里直接用纹理显示视频帧
     */
    GLuint textureUniformY; // y纹理数据位置
    GLuint textureUniformU; // u纹理数据位置
    GLuint textureUniformV; // v纹理数据位置
    GLuint id_y; // y纹理对象ID
    GLuint id_u; // u纹理对象ID
    GLuint id_v; // v纹理对象ID
    QOpenGLTexture *m_pTextureY;  // y纹理对象
    QOpenGLTexture *m_pTextureU;  // u纹理对象
    QOpenGLTexture *m_pTextureV;  // v纹理对象
    /* 着色器：控制GPU进行绘制 */
    QOpenGLShader *m_pVSHader;  // 顶点着色器程序对象
    QOpenGLShader *m_pFSHader;  // 片段着色器对象
    QOpenGLShaderProgram *m_pShaderProgram; // 着色器程序容器
    int m_nVideoW; // 视频分辨率宽
    int m_nVideoH; // 视频分辨率高
    unsigned char *m_pBufYuv420p;
    FILE *m_pYuvFile;
};

#endif /* CPLAYWIDGET_H */
```

* main.cpp  

```cpp
/**
 * 参考资料：
 * [qt采用opengl显示yuv视频数据](https://blog.csdn.net/su_vast/article/details/52214642)
 * [Qt 创建定时器](https://blog.csdn.net/weixin_38416696/article/details/92838813)
 *
 * 生成YUV视频文件：
 * ffmpeg -i h264aac_1s.mp4 -ss 00:00:00 -t 1 -s 128x96 -pix_fmt yuv420p 003_yuv_video_play.yuv
 * 播放YUV文件：
 * ffplay -video_size 128x96 -i 003_yuv_video_play.yuv
 *
 * 使用Qt5.15.2、Qt6.0.4和Qt6.2.3都测试通过
 */

#include "cplaywidget.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    CPlayWidget w;
    w.show();

    return a.exec();
}
```

* yuv_video_play.pro  

```makefile
QT       += core gui
QT       += opengl openglwidgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    cplaywidget.cpp \
    main.cpp

HEADERS += \
    cplaywidget.h

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
```

* 003_yuv_video_play.yuv  

```cpp
	// 提供测试用的源视频文件
```

## 三、参考知识  

* OpenGL是一个开源的2D/3D图形API，是一个底层图形库，跨平台的，另外一个Windows的图形库是DirectX。一些概念有：顶点、纹理、着色、贴图。  
* QOpenGLWidget是一个虚类，使用时需要新建一个类继承于它。  

*参考网址：*  
[qt实现opengl播放yuv视频](https://blog.csdn.net/qq_43627907/article/details/123295253)  
[OpenGL 开放图形技术规范](https://www.oschina.net/p/opengl)  
[OpenGL(一) OpenGL入门](https://www.jianshu.com/p/92208a75283d)  
[20分钟让你了解OpenGL——OpenGL全流程详细解读](https://zhuanlan.zhihu.com/p/56693625) [OpenGL Window Example](https://doc.qt.io/qt-6/qtopengl-openglwindow-example.html)  
[Qt OpenGL](https://doc.qt.io/qt-6/qtopengl-index.html)  
[Qt OpenGL C++ Classes](https://doc.qt.io/qt-6/qtopengl-module.html)  
[Qt QOpenGLWidget类讲解](https://www.cnblogs.com/ybqjymy/p/13395139.html)  
[Qt QML VideoOutput 显示自定义的 YUV420P 数据流](https://cloud.tencent.com/developer/article/1564858)  
[FFmpeg4入门系列教程8：软解并使用QWidget播放视频（YUV420P转RGB32）](https://zhuanlan.zhihu.com/p/388018364)  
[OpenGL 图形库使用（五） —— 纹理](https://www.jianshu.com/p/d861577901c8)  
[OpenGL着色器的简单介绍](https://www.jianshu.com/p/ed667ead53fe)  
