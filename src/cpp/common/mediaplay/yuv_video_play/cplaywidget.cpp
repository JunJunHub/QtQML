#include "cplaywidget.h"
#include <QOpenGLFramebufferObject>
#include <QOpenGLTexture>
#include <QOpenGLBuffer>
#include <QMouseEvent>
#include <QTimer>

CPlayWidget::CPlayWidget(QQuickItem *parent) : QQuickFramebufferObject(parent)
{
    textureUniformY = 0;
    textureUniformU = 0;
    textureUniformV = 0;
    id_y = 0;
    id_u = 0;
    id_v = 0;
    m_pBufYuv420p = nullptr;
    m_pVShader = nullptr;
    m_pFShader = nullptr;
    m_pShaderProgram = nullptr;
    m_pTextureY = nullptr;
    m_pTextureU = nullptr;
    m_pTextureV = nullptr;
    m_pYuvFile = nullptr;
    m_nVideoH = 0;
    m_nVideoW = 0;
}

CPlayWidget::~CPlayWidget()
{
}

QQuickFramebufferObject::Renderer* CPlayWidget::createRenderer() const
{
    //初始化渲染器
    QQuickFramebufferObject::Renderer* pRenderer = new CPlayWidgetRenderer(const_cast<CPlayWidget*>(this));
    return pRenderer;
}

void CPlayWidget::Play() {
    // 启动定时器，定时读取一帧数据
    m_tiPlay = new QTimer();
    connect(m_tiPlay, SIGNAL(timeout()), this, SLOT(PlayOneFrame()));
    m_tiPlay->start(40); //25 帧
    //ti->start(66); //15 帧
}

void CPlayWidget::Stop() {
    m_tiPlay->stop();
}


//读取一帧 YUV 数据，并绘制出来
void CPlayWidget::PlayOneFrame()
{
    // 函数功能读取一帧 yuv 图像数据进行显示，每进入一次，就显示一张图片
    if (nullptr == m_pYuvFile)
    {
        // 打开 yuv 视频文件，注意修改文件路径
        // 可以自行将 fopen 改为 QFile 中最新的文件操作接口

        m_pYuvFile = fopen("F:/project/QtProject/KVMGUI/src/cpp/common/mediaplay/yuv_video_play_bak/003_yuv_video_play.yuv", "rb");
        if(nullptr == m_pYuvFile)
        {
            qFatal("read yuv file err. may be path is wrong!\n");
            return;
        }

        // 根据yuv视频数据的分辨率设置宽高，demo当中是128*96，这个地方要注意跟实际数据分辨率对应上
        m_nVideoW = 128;
        m_nVideoH = 96;
    }

    // 申请内存存一帧 yuv 图像数据，其大小为分辨率的 1.5 倍
    size_t nLen = m_nVideoW * m_nVideoH * 3 / 2;
    if (nullptr == m_pBufYuv420p)
    {
        m_pBufYuv420p = new unsigned char[nLen];
        qDebug("CPlayWidget::PlayOneFrame new data memory. Len=%lld width=%d height=%d\n",
               nLen, m_nVideoW, m_nVideoW);
    }

    // 将一帧yuv图像读到内存中
    // 读一帧数据
    if (fread(m_pBufYuv420p, 1, nLen, m_pYuvFile) != nLen)
    {
        // 关闭文件，并准备重新循环打开播放
        fclose(m_pYuvFile);
        m_pYuvFile = nullptr;
    }

    // 刷新界面,触发 paintGL 接口
    update();

    return;
}


//Qt Quick YUV Player Renderer
 CPlayWidgetRenderer::CPlayWidgetRenderer(CPlayWidget* widget) : m_widget(widget)
 {
     //初始化OpenGL
     initializeOpenGLFunctions();
     glEnable(GL_DEPTH_TEST);

     // 现代 OpenGL 渲染管线依赖着色器来处理传入的数据
     // 着色器：就是使用 OpenGL 着色语言(OpenGL Shading Language - GLSL)编写的一个小函数
     //       GLSL 是构成所有 OpenGL 着色器的语言,具体的 GLSL 语言的语法需要读者查找相关资料

     // 初始化顶点着色器
     m_widget->m_pVShader = new QOpenGLShader(QOpenGLShader::Vertex, this->m_widget);

     // 顶点着色器源码
     //
     // 嵌入式设备上基于 OpenGL ES 运行程序报错：3:1: S0032: no default precision defined for variable 'textureOut'
     // 是由于在 OpenGL ES 着色器中（RK3588 通常使用 OpenGL ES），对于片段着色器中的变量，如果没有指定默认的精度，就会报错。
     // 在桌面版 OpenGL 中，默认精度是存在的，但在 OpenGL ES 中需要显式指定：precision mediump float;
     const char *vsrc = "precision mediump float; \
         attribute vec4 vertexIn; \
         attribute vec2 textureIn; \
         varying vec2 textureOut;  \
         void main(void)           \
     {                         \
             gl_Position = vertexIn; \
             textureOut = textureIn; \
     }";

         // 编译顶点着色器程序
         if(!m_widget->m_pVShader->compileSourceCode(vsrc)) {
         qWarning() << "Vertex shader compilation failed:" << m_widget->m_pVShader->log();
         return;
     }

     // 初始化片段着色器功能(GPU中YUV转换成RGB)
     m_widget->m_pFShader = new QOpenGLShader(QOpenGLShader::Fragment, this->m_widget);

     // 片段着色器源码
     const char *fsrc = "precision mediump float; \
         varying vec2 textureOut; \
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

         // 编译器编译着色器程序
         if(!m_widget->m_pFShader->compileSourceCode(fsrc)) {
         qWarning() << "Fragment shader compilation failed:" << m_widget->m_pFShader->log();
         return;
     }

     // 创建着色器程序容器
     m_widget->m_pShaderProgram = new QOpenGLShaderProgram;
     // 将片段着色器添加到程序容器
     m_widget->m_pShaderProgram->addShader(m_widget->m_pFShader);
     // 将顶点着色器添加到程序容器
     m_widget->m_pShaderProgram->addShader(m_widget->m_pVShader);

     // 绑定属性 vertexIn 到指定位置 ATTRIB_VERTEX, 该属性在顶点着色源码其中有声明
     m_widget->m_pShaderProgram->bindAttributeLocation("vertexIn", ATTRIB_VERTEX);
     // 绑定属性 textureIn 到指定位置 ATTRIB_TEXTURE，该属性在顶点着色源码其中有声明
     m_widget->m_pShaderProgram->bindAttributeLocation("textureIn", ATTRIB_TEXTURE);

     // 链接所有所有添入到容器的着色器程序
     if (!m_widget->m_pShaderProgram->link()) {
         qDebug() << "Shader program linking failed:" << m_widget->m_pShaderProgram->log();
         return;
     }
     // 激活所有链接
     m_widget->m_pShaderProgram->bind();

     // 读取着色器中的数据变量 tex_y, tex_u, tex_v 的位置，这些变量的声明可以在片段着色器源码中可以看到
     m_widget->textureUniformY = m_widget->m_pShaderProgram->uniformLocation("tex_y");
     m_widget->textureUniformU = m_widget->m_pShaderProgram->uniformLocation("tex_u");
     m_widget->textureUniformV = m_widget->m_pShaderProgram->uniformLocation("tex_v");

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

     // 设置属性 ATTRIB_VERTEX 的顶点矩阵值以及格式
     glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, vertexVertices);
     // 设置属性 ATTRIB_TEXTURE 的纹理矩阵值以及格式
     glVertexAttribPointer(ATTRIB_TEXTURE, 2, GL_FLOAT, 0, 0, textureVertices);
     // 启用 ATTRIB_VERTEX 属性的数据,默认是关闭的
     glEnableVertexAttribArray(ATTRIB_VERTEX);
     // 启用 ATTRIB_TEXTURE 属性的数据,默认是关闭的
     glEnableVertexAttribArray(ATTRIB_TEXTURE);

     // 分别创建 y,u,v 纹理对象
     m_widget->m_pTextureY = new QOpenGLTexture(QOpenGLTexture::Target2D);
     m_widget->m_pTextureU = new QOpenGLTexture(QOpenGLTexture::Target2D);
     m_widget->m_pTextureV = new QOpenGLTexture(QOpenGLTexture::Target2D);
     m_widget->m_pTextureY->create();
     m_widget->m_pTextureU->create();
     m_widget->m_pTextureV->create();

     // 获取返回 y,u,v 分量的纹理索引值
     m_widget->id_y = m_widget->m_pTextureY->textureId();
     m_widget->id_u = m_widget->m_pTextureU->textureId();
     m_widget->id_v = m_widget->m_pTextureV->textureId();
     glClearColor(0.3, 0.3, 0.3, 0.0); // 设置背景色
     qDebug("addr=%p id_y=%d id_u=%d id_v=%d\n", this, m_widget->id_y, m_widget->id_u, m_widget->id_v);
 }

 CPlayWidgetRenderer::~CPlayWidgetRenderer()
 {
 }

 //渲染逻辑
 void CPlayWidgetRenderer::render()
 {
     // 这里将原 paintGL 的代码移动过来
     if (m_widget->m_pBufYuv420p == nullptr)
         return;

     // 加载y数据纹理
     glActiveTexture(GL_TEXTURE0);       // 激活纹理单元 GL_TEXTURE0
     glBindTexture(GL_TEXTURE_2D, m_widget->id_y); // 使用来自y数据生成纹理
     // 使用内存中 m_pBufYuv420p 数据创建真正的y数据纹理
     glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, m_widget->m_nVideoW, m_widget->m_nVideoH, 0, GL_RED, GL_UNSIGNED_BYTE, m_widget->m_pBufYuv420p);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

     // 加载u数据纹理
     glActiveTexture(GL_TEXTURE1);       // 激活纹理单元 GL_TEXTURE1
     glBindTexture(GL_TEXTURE_2D, m_widget->id_u); // 使用来自u数据生成纹理
     glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, m_widget->m_nVideoW / 2, m_widget->m_nVideoH / 2, 0, GL_RED, GL_UNSIGNED_BYTE, (char *)m_widget->m_pBufYuv420p + m_widget->m_nVideoW * m_widget->m_nVideoH);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

     // 加载v数据纹理
     glActiveTexture(GL_TEXTURE2); // 激活纹理单元GL_TEXTURE2
     glBindTexture(GL_TEXTURE_2D, m_widget->id_v);
     glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, m_widget->m_nVideoW / 2, m_widget->m_nVideoH / 2, 0, GL_RED, GL_UNSIGNED_BYTE, (char *)m_widget->m_pBufYuv420p + m_widget->m_nVideoW * m_widget->m_nVideoH * 5 / 4);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

     // 指定y纹理要使用新值 只能用 0,1,2 等表示纹理单元的索引，这是 OpenGL 不人性化的地方
     // 0对应纹理单元 GL_TEXTURE0 1对应纹理单元 GL_TEXTURE1 2对应纹理的单元 GL_TEXTURE2
     glUniform1i(m_widget->textureUniformY, 0);
     // 指定u纹理要使用新值
     glUniform1i(m_widget->textureUniformU, 1);
     // 指定v纹理要使用新值
     glUniform1i(m_widget->textureUniformV, 2);
     // 使用顶点数组方式绘制图形
     glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

     return;
 }


 QOpenGLFramebufferObject *CPlayWidgetRenderer::createFramebufferObject(const QSize &size)
 {
     QOpenGLFramebufferObjectFormat format;
     format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);

     return new QOpenGLFramebufferObject(size, format);
 }
