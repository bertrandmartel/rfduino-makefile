#!/bin/bash

function check_exists {

	if [ ! -f "$1" ]; then
		echo -ne "\x1B[31m"
		echo "[ ERROR ] $1 is missing"
		echo -ne "\x1B[0m"
		exit 1
	fi
}

echo -ne "\x1B[0m"
echo "extracting build vars..."

RFDUINO_DIR=./RFduino
TOOLCHAIN_DIR=./toolchain/gcc-arm-none-eabi-4.8.3-2014q1
TOOLCHAIN_BIN_DIR=${TOOLCHAIN_DIR}/bin
TOOLCHAIN_AR=./toolchain/gcc-arm-none-eabi-4.8.3-2014q1-linux64.tar.gz

if [ ! -d ${RFDUINO_DIR} ]; then
	echo -ne "\x1B[31m"
	echo "[ ERROR ] RFduino directory is missing"
	echo -ne "\x1B[0m"
	exit 1
fi

if [ ! -f ${RFDUINO_DIR}/boards.txt ]; then
	echo -ne "\x1B[31m"
	echo "[ ERROR ] boards.txt missing"
	echo "[ ERROR ] execute > git submodule update"
	echo -ne "\x1B[0m"
	exit 1
fi

if [ ! -f ${RFDUINO_DIR}/platform.txt ]; then
	echo -ne "\x1B[31m"
	echo "[ ERROR ] platform.txt missing"
	echo "[ ERROR ] execute > git submodule update"
	echo -ne "\x1B[0m"
	exit 1
fi

if [ ! -f boards.txt ]; then
	cp ${RFDUINO_DIR}/boards.txt .
	sed -i 's/{/${/g' boards.txt
fi

if [ ! -f platform.txt ]; then
	cp ${RFDUINO_DIR}/platform.txt .
	sed -i 's/{/${/g' platform.txt
	sed -i 's/build./RFduino.build./g' platform.txt
fi

echo -ne "\x1B[01;32m"
echo "[OK] build vars successfully extracted"
echo -ne "\x1B[0m"

echo "checking toolchain"

if [ ! -d ${TOOLCHAIN_DIR} ]; then

	if [ ! -f ${TOOLCHAIN_AR} ]; then
		echo -ne "\x1B[31m"
		echo "[ ERROR ] toolchain archive is missing"
		echo "[ ERROR ] execute > wget -P ./toolchain http://downloads.arduino.cc/gcc-arm-none-eabi-4.8.3-2014q1-linux64.tar.gz"
		echo -ne "\x1B[0m"
		exit 1
	else
		echo "extracting toolchain"
		tar -xvzf ${TOOLCHAIN_AR} -C ./toolchain/ 
	fi
fi

GCC=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-gcc
ELF2HEX=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-g++
GXX=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-g++
AR=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-ar
OBJCOPY=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-objcopy
ELF2HEX_COPY=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-objcopy
SIZE=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-size
LOADER=${RFDUINO_DIR}/RFDLoader_linux

check_exists ${GCC}
check_exists ${ELF2HEX}
check_exists ${GXX}
check_exists ${AR}
check_exists ${OBJCOPY}
check_exists ${ELF2HEX_COPY}
check_exists ${SIZE}
check_exists ${LOADER}