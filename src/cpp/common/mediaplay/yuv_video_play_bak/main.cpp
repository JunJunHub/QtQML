/**
 * 参考资料：
 * [qt采用opengl显示yuv视频数据](https://blog.csdn.net/su_vast/article/details/52214642)
 * [Qt 创建定时器](https://blog.csdn.net/weixin_38416696/article/details/92838813)
 *
 * 生成YUV视频文件：
 * ffmpeg -i h264aac_1s.mp4 -ss 00:00:00 -t 1 -s 128x96 -pix_fmt yuv420p 003_yuv_video_play.yuv
 *
 * 播放YUV文件：
 * ffplay -video_size 128x96 -i 003_yuv_video_play.yuv
 *
 * 使用 Qt5.15.2、Qt6.0.4 和 Qt6.2.3 都测试通过
 * 嵌入式环境基于 OpenGL ES 测试通过
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
