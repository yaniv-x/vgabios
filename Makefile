SHELL = /bin/sh

CC      = gcc
CFLAGS  = -g -O2 -Wall -Wstrict-prototypes
LDFLAGS = 

GCC = gcc
BCC = bcc
AS86 = as86

RELEASE = `pwd | sed "s-.*/--"`
RELDATE = `date '+%d %b %Y'`
RELVERS = `pwd | sed "s-.*/--" | sed "s/vgabios//" | sed "s/-//"`

VGABIOS_DATE = "-DVGABIOS_DATE=\"$(RELDATE)\""

all: bios

bios: biossums vgabios.bin vgabios.debug.bin

clean:
	/bin/rm -f  biossums vbetables-gen vbetables.h *.o *.s *.ld86 \
          temp.awk.* vgabios*.orig _vgabios_* _vgabios-debug_* core vgabios*.bin vgabios*.txt $(RELEASE).bin *.bak

dist-clean: clean

release: 
	VGABIOS_VERS=\"-DVGABIOS_VERS=\\\"$(RELVERS)\\\"\" make bios cirrus-bios
	/bin/rm -f  *.o *.s *.ld86 \
          temp.awk.* vgabios.*.orig _vgabios_.*.c core *.bak .#*
	cp VGABIOS-lgpl-latest.bin ../$(RELEASE).bin
	cp VGABIOS-lgpl-latest.debug.bin ../$(RELEASE).debug.bin
	cp VGABIOS-lgpl-latest.cirrus.bin ../$(RELEASE).cirrus.bin
	cp VGABIOS-lgpl-latest.cirrus.debug.bin ../$(RELEASE).cirrus.debug.bin
	tar czvf ../$(RELEASE).tgz --exclude CVS -C .. $(RELEASE)/

vgabios.bin: vgabios.c vgabios.h vgafonts.h vgatables.h vbe.h vbe.c vbetables.h
	rm -f VGABIOS-lgpl-latest.bin
	$(GCC) -E -P vgabios.c $(VGABIOS_VERS) -DVBE $(VGABIOS_DATE) > _vgabios_.c
	$(BCC) -o vgabios.s -C-c -D__i86__ -S -0 _vgabios_.c
	sed -e 's/^\.text//' -e 's/^\.data//' vgabios.s > _vgabios_.s
	$(AS86) _vgabios_.s -b vgabios.bin -u -w- -g -0 -j -O -l vgabios.txt
	rm -f _vgabios_.s _vgabios_.c vgabios.s
	mv vgabios.bin VGABIOS-lgpl-latest.bin
	./biossums VGABIOS-lgpl-latest.bin
	ls -l VGABIOS-lgpl-latest.bin

vgabios.debug.bin: vgabios.c vgabios.h vgafonts.h vgatables.h vbe.h vbe.c vbetables.h
	$(GCC) -E -P vgabios.c $(VGABIOS_VERS) -DVBE -DDEBUG $(VGABIOS_DATE) > _vgabios-debug_.c
	$(BCC) -o vgabios-debug.s -C-c -D__i86__ -S -0 _vgabios-debug_.c
	sed -e 's/^\.text//' -e 's/^\.data//' vgabios-debug.s > _vgabios-debug_.s
	$(AS86) _vgabios-debug_.s -b vgabios.debug.bin -u -w- -g -0 -j -O -l vgabios.debug.txt
	rm -f _vgabios-debug_.s _vgabios-debug_.c vgabios-debug.s
	mv vgabios.debug.bin VGABIOS-lgpl-latest.debug.bin
	./biossums VGABIOS-lgpl-latest.debug.bin
	ls -l VGABIOS-lgpl-latest.debug.bin

biossums: biossums.c
	$(CC) -o biossums biossums.c

vbetables-gen: vbetables-gen.c
	$(CC) -o vbetables-gen vbetables-gen.c

vbetables.h: vbetables-gen
	./vbetables-gen > $@
