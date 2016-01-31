############################################################################
# The MIT License (MIT)
#
# Copyright (c) 2016 Bertrand Martel
#
############################################################################
#title         : Makefile
#author        : Bertrand Martel
#date          : 31/01/2015
#description   : Makefile for RFduino
############################################################################
RFDUINO_DIR=./RFduino
TOOLCHAIN_DIR=./toolchain/gcc-arm-none-eabi-4.8.3-2014q1
TOOLCHAIN_BINDIR=$(TOOLCHAIN_DIR)/bin
CXX=$(TOOLCHAIN_BINDIR)/arm-none-eabi-g++
CC=$(TOOLCHAIN_BINDIR)/arm-none-eabi-gcc
AR=$(TOOLCHAIN_BINDIR)/arm-none-eabi-ar
ELF=$(CXX)
ELF2HEX=$(TOOLCHAIN_BINDIR)/arm-none-eabi-objcopy

FREQ_CPU=16000000
MCU=cortex-m0
CXX_FLAGS=-c -g -Os -w -ffunction-sections -fdata-sections -fno-rtti -fno-exceptions -fno-builtin -MMD
CC_FLAGS=-c -g -Os -w -ffunction-sections -fdata-sections -fno-builtin -MMD
ELF_FLAGS=-Wl,--gc-sections --specs=nano.specs

EXTRA_FLAGS=-mthumb -D__RFduino__
RFDUINO_PATH=RFduino/cores/arduino
VARIANT_PATH=./RFduino/variants/RFduino
LINKER_SCRIPT=$(VARIANT_PATH)/linker_scripts/gcc/RFduino.ld

ifndef PORT
PORT=/dev/ttyUSB0
endif

CORE_LIB=core.a

OBJECTS_SRC:=$(patsubst %,../%,$(OBJECTS))
DEPENDS_SRC:=$(patsubst %.o,../%.d,$(OBJECTS))
HEADERS_SRC:=$(patsubst -I%,-I../%,$(HEADERS))

INCLUDES=-I./RFduino/cores/arduino \
		 -I./RFduino/variants/RFduino \
		 -I./RFduino/system/RFduino \
		 -I./RFduino/system/RFduino/include \
		 -I./RFduino/system/CMSIS/CMSIS/Include \
		 $(HEADERS_SRC)

LIB_OBJECTS= $(RFDUINO_PATH)/Print.o $(RFDUINO_PATH)/RingBuffer.o $(RFDUINO_PATH)/Stream.o $(RFDUINO_PATH)/Tone.o \
		$(RFDUINO_PATH)/UARTClass.o $(RFDUINO_PATH)/wiring_pulse.o $(RFDUINO_PATH)/WMath.o $(RFDUINO_PATH)/WString.o \
		$(RFDUINO_PATH)/hooks.o $(RFDUINO_PATH)/itoa.o $(RFDUINO_PATH)/Memory.o $(RFDUINO_PATH)/syscalls.o $(RFDUINO_PATH)/WInterrupts.o \
		$(RFDUINO_PATH)/wiring_analog.o $(RFDUINO_PATH)/wiring.o $(RFDUINO_PATH)/wiring_digital.o $(RFDUINO_PATH)/wiring_shift.o \ $(VARIANT_PATH)/variant.o

$(shell bash init.sh>&2)

default: rfduino_lib build upload

rfduino_lib: $(LIB_OBJECTS)
	$(AR) rcs $(CORE_LIB) $^

build: target.hex

upload: 
	./RFduino/RFDLoader_linux -q $(PORT) target.hex

clean:
	@echo "cleaning"
	$(shell rm $(OBJECTS_SRC) 2> /dev/null)
	$(shell rm $(DEPENDS_SRC) 2> /dev/null)
	$(shell rm *.elf 2> /dev/null)
	$(shell rm *.hex 2> /dev/null)
	$(shell rm *.map 2> /dev/null)
	$(shell rm *.d 2> /dev/null)
	$(shell rm *.o 2> /dev/null)
	$(shell rm *.a 2> /dev/null)
	$(shell rm $(RFDUINO_PATH)/*.o 2> /dev/null)
	$(shell rm $(VARIANT_PATH)/*.o 2> /dev/null)

distclean:
	@echo "complete cleaning"
	$(shell rm -rf $(TOOLCHAIN_DIR))

%.o: %.cpp
	$(CXX) $(CXX_FLAGS) -mcpu=$(MCU) -DF_CPU=$(FREQ_CPU) $(EXTRA_FLAGS) $(INCLUDES) $< -o $@

%.o: %.c
	$(CC) $(CC_FLAGS) -mcpu=$(MCU) -DF_CPU=$(FREQ_CPU) $(EXTRA_FLAGS) $(INCLUDES) $< -o $@

target.hex: target.elf
	$(ELF2HEX) -O ihex $< $@

target.elf: $(OBJECTS_SRC)
	$(ELF) $(ELF_FLAGS) -mcpu=$(MCU) $(EXTRA_FLAGS) \
		-T$(LINKER_SCRIPT) -Wl,-Map,target.map \
		-Wl,--cref -o target.elf -L. -Wl,--warn-common -Wl,--warn-section-align -Wl,--start-group \
		./$(RFDUINO_PATH)/syscalls.o $(OBJECTS_SRC) $(VARIANT_PATH)/libRFduinoSystem.a $(VARIANT_PATH)/libRFduino.a  $(VARIANT_PATH)/libRFduinoBLE.a \
		$(VARIANT_PATH)/libRFduinoGZLL.a ./core.a -Wl,--end-group