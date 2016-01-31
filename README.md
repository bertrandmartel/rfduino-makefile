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
git submodule add git://github.com/akinaru/rfduino-makefile.git
git submodule update --recursive

```

Then create your root `Makefile` in `project_dir` like this :

```
OBJECTS=some_directory/src/test.o some_directory/src2/test2.o
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

## Useful links

* https://www.ashleymills.com/node/327

## License

The MIT License (MIT) Copyright (c) 2016 Bertrand Martel
