
.SUFFIXES:


RGBASM  := rgbasm
RGBLINK := rgblink
RGBFIX  := rgbfix
RGBGFX  := rgbgfx


SRCS := $(wildcard src/*.asm)
OBJS := $(patsubst src/%.asm,obj/%.o,${SRCS})


all: bin/example.gb bin/example.dbg bin/example.gbs
.PHONY: all

clean:
	rm -rf obj bin
.PHONY: clean

bin/example.gb bin/example.sym bin/example.map: ${OBJS}
	@mkdir -p ${@D}
	${RGBLINK} -p 0xFF -d -m bin/example.map -n bin/example.sym -o bin/example.gb $^
	${RGBFIX} -p 0xFF -v bin/example.gb

bin/example.dbg:
	printf '@debugfile 1.0.0\n@include "../%s"\n' ${OBJS:.o=.dbg} >$@

obj/%.o obj/%.dbg: src/%.asm
	@mkdir -p ${@D}
	${RGBASM} -h -p 0xFF -i src/include/ -i src/fortISSimO/ -o obj/$*.o $< -DPRINT_DEBUGFILE >obj/$*.dbg

obj/music.o: src/fortISSimO/fortISSimO.asm src/fortISSimO/include/hUGE.inc


bin/example.gbs: gbs.asm obj/syms.asm bin/example.gb
	@mkdir -p ${@D}
	${RGBASM} $< -o - | ${RGBLINK} -x -o $@ -

obj/syms.asm: bin/example.sym
	@mkdir -p ${@D}
	sed -E 's/^\s*[0-9A-Fa-f]+:([0-9A-Fa-f]+)\s+([A-Za-z_][A-Za-z0-9_@#$.]*)\s*$$/DEF \2 equ $$\1/;t;d' $< >$@


obj/%.2bpp: src/%.flags src/%.png
	@mkdir -p ${@D}
	${RGBGFX} -o $@ @$^

obj/main.o: obj/chicago8x8.2bpp
