RFDUINO_DIR=./RFduino
TOOLCHAIN_DIR=./toolchain/gcc-arm-none-eabi-4.8.3-2014q1

build.system.path=./RFduino/system
runtime.tools.arm-none-eabi-gcc.path=${TOOLCHAIN_DIR}

ARDUINO_PATH=RFduino/cores/arduino
RFduino.build.variant.path=./RFduino/variants/RFduino
RFduino.build.ldscript=linker_scripts/gcc/RFduino.ld
PORT=/dev/ttyUSB0

LIBNAME=libarduino.a
INCLUDE_DIR=include
LIB_DIR=lib

includes=-I${RFduino.build.variant.path} -I./${ARDUINO_PATH}

RES:=$(shell bash init.sh >&2)

hex_filename=target

include boards.txt
include platform.txt

libs_objects= ${ARDUINO_PATH}/Print.o ${ARDUINO_PATH}/RingBuffer.o ${ARDUINO_PATH}/Stream.o ${ARDUINO_PATH}/Tone.o \
		${ARDUINO_PATH}/UARTClass.o ${ARDUINO_PATH}/wiring_pulse.o ${ARDUINO_PATH}/WMath.o ${ARDUINO_PATH}/WString.o \
		${ARDUINO_PATH}/hooks.o ${ARDUINO_PATH}/itoa.o ${ARDUINO_PATH}/Memory.o ${ARDUINO_PATH}/syscalls.o ${ARDUINO_PATH}/WInterrupts.o \
		${ARDUINO_PATH}/wiring_analog.o ${ARDUINO_PATH}/wiring.o ${ARDUINO_PATH}/wiring_digital.o ${ARDUINO_PATH}/wiring_shift.o \ ${RFduino.build.variant.path}/variant.o

source_obj=test.o

default: arduino_lib build upload

arduino_lib: ${libs_objects}
	${compiler.path}${compiler.ar.cmd} ${compiler.ar.flags} $(LIBNAME) $^
	mkdir -p $(INCLUDE_DIR)
	mkdir -p ${LIB_DIR}
	cp ${ARDUINO_PATH}/*.h ./$(INCLUDE_DIR)/
	cp ${RFduino.build.variant.path}/*.h ./$(INCLUDE_DIR)/
	cp -r ${ARDUINO_PATH}/avr ./$(INCLUDE_DIR)/
	mv $(LIBNAME) ./${LIB_DIR}

build: ${hex_filename}.hex

upload: 
	./RFduino/${tools.RFDLoader.cmd.linux} -q ${PORT} ${hex_filename}.hex

clean:
	@echo "cleaning"
	$(shell rm *.elf 2> /dev/null)
	$(shell rm *.hex 2> /dev/null)
	$(shell rm *.map 2> /dev/null)
	$(shell rm *.d 2> /dev/null)
	$(shell rm *.o 2> /dev/null)
	$(shell rm ${ARDUINO_PATH}/*.o 2> /dev/null)
	$(shell rm ${RFduino.build.variant.path}/*.o 2> /dev/null)
	$(shell rm -rf $(INCLUDE_DIR))
	$(shell rm -rf $(LIB_DIR))

distclean:
	@echo "complete cleaning"
	$(shell rm -rf boards.txt platform.txt)
	$(shell rm -rf ${TOOLCHAIN_DIR})

%.o: %.cpp
	${compiler.path}${compiler.cpp.cmd} ${compiler.cpp.flags} -mcpu=${RFduino.build.mcu} -DF_CPU=${RFduino.build.f_cpu} -mthumb -D__RFduino__ ${includes} ${RFduino.build.variant_system_include} $< -o $@

%.o: %.c
	source_file=$<
	object_file=$@
	${compiler.path}${compiler.c.cmd} ${compiler.c.flags} -mcpu=${RFduino.build.mcu} -DF_CPU=${RFduino.build.f_cpu} -mthumb -D__RFduino__ ${includes} ${RFduino.build.variant_system_include} $< -o $@

${hex_filename}.hex: ${hex_filename}.elf
	${compiler.path}${compiler.size.cmd} -A $<
	${compiler.path}${compiler.elf2hex.cmd} ${compiler.elf2hex.flags} $< $@

#${hex_filename}.elf: test.cpp
#	${compiler.path}${compiler.c.elf.cmd} ${compiler.c.elf.flags} -mcpu=${RFduino.build.mcu} -DF_CPU=${RFduino.build.f_cpu} -mthumb -D__RFduino__ ${includes} ${RFduino.build.variant_system_include} $< \
#		-o $@ -L ${RFduino.build.variant.path}/${RFduino.build.variant_system_lib} ${RFduino.build.variant.path}/libRFduino.a ${RFduino.build.variant.path}/libRFduinoBLE.a  \
#		${RFduino.build.variant.path}/libRFduinoGZLL.a ./${LIB_DIR}/${LIBNAME}

${hex_filename}.elf: ${source_obj}
	${compiler.path}${compiler.c.elf.cmd} ${compiler.c.elf.flags} -mcpu=${RFduino.build.mcu} \
		-T${RFduino.build.variant.path}/${RFduino.build.ldscript} -Wl,-Map,target.map \
		-Wl,--cref -o ${hex_filename}.elf -L. -Wl,--warn-common -Wl,--warn-section-align -Wl,--start-group \
		./${ARDUINO_PATH}/syscalls.o test.o ${RFduino.build.variant.path}/${RFduino.build.variant_system_lib} ${RFduino.build.variant.path}/libRFduino.a  ${RFduino.build.variant.path}/libRFduinoBLE.a \
		${RFduino.build.variant.path}/libRFduinoGZLL.a -Wl,--end-group