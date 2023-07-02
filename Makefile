
.SUFFIXES:


RGBASM  := rgbasm
RGBLINK := rgblink
RGBFIX  := rgbfix
RGBGFX  := rgbgfx

teNOR := src/fortISSimO/teNOR/target/release/teNOR


SRCS := $(wildcard src/*.asm) obj/demo_song.asm
OBJS := $(patsubst %.asm,obj/%.o,$(notdir ${SRCS}))


rom: bin/fO_demo.gb bin/fO_demo.dbg
gbs: bin/fO_demo.gbs
all: rom gbs
.PHONY: rom gbs all

clean:
	rm -rf obj bin
.PHONY: clean

bin/fO_demo.gb bin/fO_demo.sym bin/fO_demo.map: ${OBJS}
	@mkdir -p ${@D}
	${RGBLINK} -p 0xFF -d -m bin/fO_demo.map -n bin/fO_demo.sym -o bin/fO_demo.gb $^
	${RGBFIX} -p 0xFF -v bin/fO_demo.gb

bin/fO_demo.dbg:
	printf '@debugfile 1.0.0\n@include "../%s"\n' ${OBJS:.o=.dbg} >$@

define assemble
obj/$2.o obj/$2.dbg: $1
	@mkdir -p $${@D}
	$${RGBASM} -Wall -Wextra -h -p 0xFF -I src/include/ -I src/fortISSimO/include/ -o obj/$2.o $$< -DPRINT_DEBUGFILE >obj/$2.dbg
endef
$(foreach asm_file,${SRCS},$(eval $(call assemble,${asm_file},$(basename $(notdir ${asm_file})))))

obj/demo_song.o: src/fortISSimO/include/fortISSimO.inc
obj/music_driver.o: src/fortISSimO/fortISSimO.asm src/fortISSimO/include/fortISSimO.inc

obj/demo_song.asm: ${teNOR} src/demo_song.uge
	@mkdir -p ${@D}
	$^ $@ --section-type ROMX --song-descriptor DemoSong


bin/fO_demo.gbs: gbs.asm obj/syms.asm bin/fO_demo.gb
	@mkdir -p ${@D}
	${RGBASM} $< -o - | ${RGBLINK} -x -o $@ -

obj/syms.asm: bin/fO_demo.sym
	@mkdir -p ${@D}
	sed -E 's/^\s*[0-9A-Fa-f]+:([0-9A-Fa-f]+)\s+([A-Za-z_][A-Za-z0-9_@#$.]*)\s*$$/DEF \2 equ $$\1/;t;d' $< >$@


obj/%.2bpp: src/%.flags src/%.png
	@mkdir -p ${@D}
	${RGBGFX} -o $@ @$^

obj/main.o: obj/chicago8x8.2bpp


# That one *must* be hardcoded; it's only meant to allow the default setting of `${teNOR}` to work.
src/fortISSimO/teNOR/target/release/teNOR: src/fortISSimO/teNOR/Cargo.toml src/fortISSimO/teNOR/Cargo.lock $(shell find src/fortISSimO/teNOR/src -name '*.rs')
	env -C src/fortISSimO/teNOR cargo build --release
