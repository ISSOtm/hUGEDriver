
.SUFFIXES:


RGBASM  := rgbasm
RGBLINK := rgblink
RGBFIX  := rgbfix
RGBGFX  := rgbgfx

teNOR := src/fortISSimO/target/release/teNOR


SRCS := $(wildcard src/*.asm) obj/demo_song.asm
OBJS := $(patsubst %.asm,obj/%.o,$(notdir ${SRCS}))


roms: bin/fO_demo.gb bin/fO_demo.dbg \
	bin/fO_demo.ch1.gb bin/fO_demo.ch2.gb bin/fO_demo.ch3.gb bin/fO_demo.ch4.gb
gbs: bin/fO_demo.gbs
all: roms gbs
.PHONY: roms gbs all

clean:
	rm -rf obj bin
.PHONY: clean


bin/%.gb:
	@mkdir -p ${@D}
	${RGBLINK} -p 0xFF -d ${AUXFILES} -o bin/$*.gb $^
	${RGBFIX} -p 0xFF -v bin/$*.gb

bin/fO_demo.dbg:
	@mkdir -p ${@D}
	printf '@debugfile 1.0.0\n@include "../%s"\n' ${OBJS:.o=.dbg} >$@

bin/fO_demo.ch1.gb bin/fO_demo.ch2.gb bin/fO_demo.ch3.gb bin/fO_demo.ch4.gb: \
	bin/fO_demo.ch%.gb: ${OBJS} obj/nr51_mask.%.o
bin/fO_demo.gb bin/fO_demo.sym bin/fO_demo.map: ${OBJS} obj/nr51_mask.f.o
bin/fO_demo.sym bin/fO_demo.map: bin/fO_demo.gb
bin/fO_demo.gb: AUXFILES = -m bin/$*.map -n bin/$*.sym


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

obj/nr51_mask.%.o: nr51_mask.asm
	@mkdir -p ${@D}
	${RGBASM} -Wall -Wextra -h -p 0xFF -o $@ $< -DNR51_MASK=\$$$*$*


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
src/fortISSimO/target/release/teNOR: src/fortISSimO/Cargo.toml src/fortISSimO/Cargo.lock $(shell find src/fortISSimO/teNOR/src -name '*.rs')
	env -C src/fortISSimO cargo build -rq
