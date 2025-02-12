QMAKE=/home/junjun/RK3588_SDK/buildroot/output/host/bin/qmake

rm -rf build && mkdir build && cd build

$QMAKE ../../../kvmgui.pro

make
