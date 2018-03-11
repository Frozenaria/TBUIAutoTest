#!/bin/sh
# 使用方式："${SRCROOT}/build.sh"

build() {
# workspace的名称
WK_NAME=$1
# Target的名称
TARGET_NAME=$2
# 生成文件的类型 bundle或framework
PRODUCT_TYPE=$3
# project name为空，则使用SRCROOT的最后一个文件名
if [ ! -n "${TARGET_NAME}" ]
then
TARGET_NAME=${PROJECT}
echo "******${TARGET_NAME}"
fi
# 未传第二个参数（TargetType）时，默认为framework
if [ -z "${PRODUCT_TYPE}" ]
then
PRODUCT_TYPE="framework"
fi
# 指定framework的输出路径
INSTALL_DIR=${PWD}/Products/${TARGET_NAME}.${PRODUCT_TYPE}
# 命令执行路径，完成后删除
WRK_DIR=build/Build/Products
# 生成的framework的路径
DEVICE_DIR=${WRK_DIR}/Release-iphoneos/${TARGET_NAME}.${PRODUCT_TYPE}
SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator/${TARGET_NAME}.${PRODUCT_TYPE}
# -configuration ${CONFIGURATION}
# Clean and Building both architectures.

#xcodebuild -configuration "Release" -target ${TARGET_NAME} -sdk iphoneos clean build
xcodebuild -configuration Release clean build -project TBUIAutoTestDemo.xcodeproj -scheme ${TARGET_NAME} -sdk iphoneos -derivedDataPath build

if [ $? -ne 0 ]
then
exit 1
fi

# Cleaning the oldest.
if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi
mkdir -p "${INSTALL_DIR}"

cp -R "${DEVICE_DIR}/" "${INSTALL_DIR}/"
# 只有framework才需要进行模拟器的编译
if [[ ${PRODUCT_TYPE} == "framework" ]]
then

#xcodebuild -configuration "Release" -target ${TARGET_NAME} -sdk iphonesimulator clean build
xcodebuild PLATFORM_NAME=iphonesimulator -configuration Release clean build -project TBUIAutoTestDemo.xcodeproj -scheme ${TARGET_NAME} -sdk iphonesimulator -derivedDataPath build

if [ $? -ne 0 ]
then
exit 1
fi

# 合并device和simulator的framework
lipo -create "${DEVICE_DIR}/${TARGET_NAME}" "${SIMULATOR_DIR}/${TARGET_NAME}" -output "${INSTALL_DIR}/${TARGET_NAME}"
fi

RESOURCES_DIR=${PWD}/Resources
RESOURCES_INSTALL_DIR=${PWD}/Products

#copy resources
if [ -d "${RESOURCES_DIR}" ]
then
echo "copy resources..."
cp -R ${RESOURCES_DIR}/* ${RESOURCES_INSTALL_DIR}
fi

# 清理临时目录
rm -r "build"

}

# 清理pod依赖
pod deintegrate TBUIAutoTestDemo.xcodeproj
# 重构pod依赖
pod install
# 打包framework
build Main TBUIAutoTestKit framework
# 打包bundle
