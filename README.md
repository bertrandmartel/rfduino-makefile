# RFduino Makefile


Build your RFduino project with a single Makefile instead of using Arduino IDE :

* setup your own project structure
* write a very simple Makefile to build your project
* control all the build process

## Prerequisites

* GNU Make (https://www.gnu.org/software/make)
* GNU Tar (https://www.gnu.org/software/tar)

## Compatibility

* Linux

## Integration

```
cd project_dir
git submodule add git://github.com/bertrandmartel/rfduino-makefile.git
git submodule update --init --recursive
```

Then create your root `Makefile` in `project_dir` like this :

```
OBJECTS=some_directory/src/main.o some_directory/src2/test2.o
HEADERS=-Isome_directory/header -Isome_directory/header2

export OBJECTS
export HEADERS

.PHONY: all

all:
	$(MAKE) -C rfduino-makefile

clean:
	$(MAKE) -C rfduino-makefile clean

distclean:
	$(MAKE) -C rfduino-makefile distclean

```

Change `OBJECTS` and `HEADERS` according to your requirements :

* `OBJECTS` contains list of object files `.o` that match your source
* `HEADERS` contains list of headers directory

Default usb port is set to `/dev/ttyUSB0` by default, if you want to override this, add this to your Makefile : 

```
PORT=/dev/<port>
export PORT
```

You have to provide a main function like this : 

```
#include "Arduino.h"

void setup() {   
}

void loop() {
}

int main() {

	init();
	setup();
	while(1)
		loop();
	return 0;
}

```

Also `#include "Arduino.h"` is necessary for using Arduino framework

Note that `init()` function must be called to correctly initialize RFduino module

Check <a href="https://gist.github.com/bertrandmartel/46be5d05a5635573063c">this gist</a> for a full example (led blink rfduino sample)

## RFduino libraries

If you want to use embedded RFduino libraries such as `RFduinoBLE` your Makefile will have : 

```
OBJECTS=rfduino-makefile/RFduino/libraries/RFduinoBLE/RFduinoBLE.o some_other_src.o
HEADERS=-Irfduino-makefile/RFduino/libraries/RFduinoBLE
```

The same apply for libraries :
* RFduinoBLE
* RFduinoGZLL
* RFduinoNonBLE
* Servo
* SPI
* Wire

## External projects

* <a href="https://github.com/RFduino/RFduino">the official RFduino project</a>

## Useful links

* https://www.ashleymills.com/node/327

## License

The MIT License (MIT) Copyright (c) 2016 Bertrand Martel
