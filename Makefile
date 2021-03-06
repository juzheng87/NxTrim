CXX ?= g++
CC ?= gcc


CXXFLAGS ?= -O3
LFLAGS = -lz

all: nxtrim

debug: CXXFLAGS += -Wall -g
debug: all

GIT_HASH := $(shell git describe --abbrev=4 --always )

VERSION = v0.4.2
GIT_VERSION =
ifneq "$(wildcard .git)" ""
GIT_VERSION = -$(shell git describe --always)
endif
version.h:
	echo '#define VERSION "$(VERSION)$(GIT_VERSION)"' > $@

unit_test: test.cpp fastqlib.o utilityfunc.o matepair.o
	$(CXX) $(CXXFLAGS) test.cpp fastqlib.o utilityfunc.o matepair.o -o unit_test   $(LFLAGS)
nxtrim: nxtrim.cpp fastqlib.o utilityfunc.o matepair.o fastqlib.o version.h 
	$(CXX) $(CXXFLAGS) nxtrim.cpp fastqlib.o utilityfunc.o matepair.o  -o nxtrim  $(LFLAGS)
matepair.o: matepair.cpp matepair.h fastqlib.h
	$(CXX) $(CXXFLAGS) -c matepair.cpp
fastqlib.o: fastqlib.cpp fastqlib.h utilityfunc.h
	$(CXX) $(CXXFLAGS) -c fastqlib.cpp
utilityfunc.o:  utilityfunc.cpp utilityfunc.h
	$(CXX) $(CXXFLAGS) -c utilityfunc.cpp
test: nxtrim
	bash -e example/run_test.sh
ecmg: nxtrim
	cd test/;bash -e ecmg.sh
clean:
	rm *.o nxtrim test version.h
	rm -rf test/output_dir/
	rm test/*bam test/*pe.fastq.gz test/*mp.fastq.gz  test/*unknown.fastq.gz
