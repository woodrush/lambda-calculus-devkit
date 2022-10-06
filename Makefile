# This setting needs to be changed on a Mac to compile tromp.c (make ./bin/tromp, make test-blc-tromp, etc.).
# Please see README.md for details.
CC=cc

# Binary lambda calculus
BLC=./bin/Blc
UNI=./bin/uni
TROMP=./bin/tromp
UNIPP=./bin/uni++
UNID=./bin/unid
BLCAIT=./bin/blc-ait

# Universal lambda
CLAMB=./bin/clamb

# Lazy K
LAZYK=./bin/lazyk


# Tools
ASC2BIN=./bin/asc2bin
LAM2BIN=./bin/lam2bin

# Others
CABAL=cabal


run-repl: $(BLC) $(ASC2BIN)
	( cat $(target_blc) | $(ASC2BIN); cat ) | $(BLC)

run-repl-ulamb: $(ULAMB) $(ASC2BIN)
	( cat $(target_ulamb) | $(ASC2BIN); cat ) | $(ULAMB) -u

run-repl-lazyk: $(LAZYK) $(ASC2BIN)
	$(LAZYK) -u $(target_lazyk)

test: test-blc-uni test-compiler-hosting-blc-uni
test-all-nonlinux: interpreters-nonlinux test-blc-uni test-ulamb test-lazyk test-compiler-hosting-blc-uni test-blc-tromp
# On x86-64-Linux, the interpreter 'Blc' can be used.
test-all: interpreters test-blc-uni test-ulamb test-lazyk test-compiler-hosting-blc-uni test-blc-tromp test-blc test-compiler-hosting-blc

# Build all of the interpreters that support LambdaLisp
interpreters: uni clamb lazyk tromp blc asc2bin
interpreters-nonlinux: uni clamb lazyk tromp asc2bin



#================================================================
# Tests
#================================================================
# Each basic test compares LambdaLisp outputs with:
# - Outputs when executed on Common Lisp, for examples/*.cl, which run on both Common Lisp and LambdaLisp
# - Predefined expected output text in ./test/, for examples/*.lisp, which are LambdaLisp-exclusive programs
.PHONY: test-lisp-%
test-lisp-%: $(addsuffix .%-out.expected-diff, $(addprefix out/, $(notdir $(wildcard test/*.lisp.out))))
	@echo "\n    All LambdaLisp-exclusive tests have passed for $(interpreter-name-$*).\n"

.PHONY: test-sbclcmp-%
test-sbclcmp-%: $(addsuffix .%-out.sbcl-diff, $(addprefix out/, $(notdir $(wildcard examples/*.cl))))
	@echo "\n    All SBCL comparison tests have passed for $(interpreter-name-$*).\n"

.PHONY: test-%
test-%: test-sbclcmp-% test-lisp-%
	@echo "\n    All tests have passed for $(interpreter-name-$*).\n"
interpreter-name-blc="BLC with the interpreter 'Blc'"
interpreter-name-blc-tromp="BLC with the interpreter 'tromp'"
interpreter-name-blc-uni="BLC with the interpreter 'uni'"
interpreter-name-ulamb="Universal Lambda"
interpreter-name-lazyk="Lazy K"


# Compiler hosting test - execute the output of examples/lambdacraft.cl as a binary lambda calculus program
.PHONY: test-compiler-hosting-blc
test-compiler-hosting-blc: out/lambdacraft.cl.blc-out $(BLC) $(ASC2BIN) examples/lambdacraft.cl
# Remove non-01-characters and provide it to BLC
	cat $< | sed 's/[^0-9]*//g' | tr -d "\n" | $(ASC2BIN) | $(BLC) > out/$@.out
	printf 'A' > out/lambdacraft.cl.blc-expected
	diff out/$@.out out/lambdacraft.cl.blc-expected || ( rm out/$@.out; exit 1)
	@echo "\n    LambdaCraft-compiler-hosting-on-LambdaLisp test passed.\n"

.PHONY: test-compiler-hosting-blc-uni
test-compiler-hosting-blc-uni: out/lambdacraft.cl.blc-uni-out $(UNI) $(ASC2BIN) examples/lambdacraft.cl
# Remove non-01-characters and provide it to BLC
	cat $< | sed 's/[^0-9]*//g' | tr -d "\n" | $(ASC2BIN) | $(UNI) > out/$@.out
	printf 'A' > out/lambdacraft.cl.blc-expected
	diff out/$@.out out/lambdacraft.cl.blc-expected || ( rm out/$@.out; exit 1)
	@echo "\n    LambdaCraft-compiler-hosting-on-LambdaLisp test passed.\n"


# Self-hosting test - compile LambdaLisp's own source code written in Common Lisp using LambdaLisp (currently theoretical - requires a lot of time and memory)
.PHONY: test-self-host
test-self-host: $(BASE_SRCS) $(def_prelude) ./src/main.cl $(target_blc) $(BLC) $(ASC2BIN)
	mkdir -p ./test
	( echo '(defparameter **lambdalisp-suppress-repl** t)'; \
	  cat ./src/lambdacraft.cl ./src/build/def-prelude.cl ./src/lambdalisp.cl ./src/main.cl ) > ./out/lambdalisp-src-cat.cl
	( cat $(target_blc) | $(ASC2BIN); cat ./out/lambdalisp-src-cat.cl ) | $(BLC) > ./out/lambdalisp.cl.blc.repl.out
	cat ./out/lambdalisp.cl.blc.repl.out | sed -e '1s/> //' | ./out/lambdalisp.cl.blc.script.out
	diff ./out/lambdalisp.cl.blc.script.out $(target_blc) || (echo "The LambdaLisp output does not match with the Common Lisp output." && exit 1)
	@echo "\n    LambdaLisp self-hosting test passed.\n"


# How to execute the programs in each platform
.PRECIOUS: out/%.cl.sbcl-out
out/%.cl.sbcl-out: examples/%.cl
	mkdir -p ./out
	if [ -f "test/$*.cl.in" ]; then \
		cat test/$*.cl.in | $(SBCL) --script $< > $@.tmp; else \
		$(SBCL) --script $< > $@.tmp; fi
	mv $@.tmp $@

.PRECIOUS: out/%.blc-out
out/%.blc-out: examples/% $(target_blc) $(BLC) $(ASC2BIN)
	mkdir -p ./out
	if [ -f "test/$*.in" ]; then \
		( cat $(target_blc) | $(ASC2BIN); cat $< test/$*.in ) | $(BLC) > $@.tmp; else \
		( cat $(target_blc) | $(ASC2BIN); cat $< ) | $(BLC) > $@.tmp; fi
	mv $@.tmp $@

.PRECIOUS: out/%.blc-tromp-out
out/%.blc-tromp-out: examples/% $(target_blc) $(TROMP) $(ASC2BIN)
	mkdir -p ./out
	if [ -f "test/$*.in" ]; then \
		( cat $(target_blc) | $(ASC2BIN); cat $< test/$*.in) | $(TROMP) > $@.tmp; else \
		( cat $(target_blc) | $(ASC2BIN); cat $< ) | $(TROMP) > $@.tmp; fi
	mv $@.tmp $@

.PRECIOUS: out/%.blc-uni-out
out/%.blc-uni-out: examples/% $(target_blc) $(UNI) $(ASC2BIN)
	mkdir -p ./out
	if [ -f "test/$*.in" ]; then \
		( cat $(target_blc) | $(ASC2BIN); cat $< test/$*.in ) | $(UNI) > $@.tmp; else \
		( cat $(target_blc) | $(ASC2BIN); cat $< ) | $(UNI) > $@.tmp; fi
	mv $@.tmp $@

.PRECIOUS: out/%.ulamb-out
out/%.ulamb-out: examples/% $(target_ulamb) $(ULAMB) $(ASC2BIN)
	mkdir -p ./out
	if [ -f "test/$*.in" ]; then \
		( cat $(target_ulamb) | $(ASC2BIN); cat $< test/$*.in ) | $(ULAMB) -u > $@.tmp; else \
		( cat $(target_ulamb) | $(ASC2BIN); cat $< ) | $(ULAMB) -u > $@.tmp; fi
	mv $@.tmp $@

.PRECIOUS: out/%.lazyk-out
out/%.lazyk-out: examples/% $(target_lazyk) $(LAZYK)
	mkdir -p ./out
	if [ -f "test/$*.in" ]; then \
		cat $< $*.in | $(LAZYK) $(target_lazyk) -u > $@.tmp; else \
		cat $< | $(LAZYK) $(target_lazyk) -u > $@.tmp; fi
	mv $@.tmp $@


# SBCL comparison test - compare LambdaLisp outputs with Common Lisp outputs for examples/*.cl
out/%.blc-out.sbcl-diff: ./out/%.blc-out.cleaned ./out/%.sbcl-out
	diff $^ || exit 1

out/%.blc-tromp-out.sbcl-diff: ./out/%.blc-tromp-out.cleaned ./out/%.sbcl-out
	diff $^ || exit 1

out/%.blc-uni-out.sbcl-diff: ./out/%.blc-uni-out.cleaned ./out/%.sbcl-out
	diff $^ || exit 1

out/%.ulamb-out.sbcl-diff: ./out/%.ulamb-out.cleaned ./out/%.sbcl-out
	diff $^ || exit 1

out/%.lazyk-out.sbcl-diff: ./out/%.lazyk-out.cleaned ./out/%.sbcl-out
	diff $^ || exit 1

# Remove the initial '> ' printed by LambdaLisp's REPL when comparing with SBCL's output
out/%.cleaned: out/%
	cat $< | sed -e '1s/> //' > $<.cleaned


# Expected text comparison test - compare LambdaLisp outputs with a predefined expected output
out/%.blc-out.expected-diff: ./out/%.blc-out ./test/%.out
	diff $^ || exit 1

out/%.blc-tromp-out.expected-diff: ./out/%.blc-tromp-out ./test/%.out
	diff $^ || exit 1

out/%.blc-uni-out.expected-diff: ./out/%.blc-uni-out ./test/%.out
	diff $^ || exit 1

out/%.ulamb-out.expected-diff: ./out/%.ulamb-out ./test/%.out
	diff $^ || exit 1

out/%.lazyk-out.expected-diff: ./out/%.lazyk-out ./test/%.out
	diff $^ || exit 1






#================================================================
# Building the interpreters
#================================================================
.PHONY: uni++
uni++: $(UNIPP)
./build/binary-lambda-calculus/uni.cpp:
	mkdir -p ./build
	cd build; git clone https://github.com/melvinzhang/binary-lambda-calculus

$(UNIPP): ./build/binary-lambda-calculus/uni.cpp
	cd build/binary-lambda-calculus && make uni
	mv ./build/binary-lambda-calculus/uni $(UNIPP)

.PHONY: unid
unid: $(UNID)
$(UNID): ./build/binary-lambda-calculus/uni.cpp
	cd build/binary-lambda-calculus && make unid
	mv ./build/binary-lambda-calculus/unid $(UNID)

.PHONY: clamb
clamb: $(CLAMB)
./build/clamb/clamb.c:
	mkdir -p ./build
	cd build; git clone https://github.com/irori/clamb

$(CLAMB): ./build/clamb/clamb.c
	cd build/clamb; $(CC) -O2 clamb.c -o clamb
	mv build/clamb/clamb ./bin
	chmod 755 $(CLAMB)


.PHONY: lazyk
lazyk: $(LAZYK)
./build/lazyk/lazyk.c:
	mkdir -p ./build
	cd build; git clone https://github.com/irori/lazyk

$(LAZYK): ./build/lazyk/lazyk.c
	cd build/lazyk; $(CC) -O2 lazyk.c -o lazyk
	mv build/lazyk/lazyk ./bin
	chmod 755 $(LAZYK)


.PHONY: blc
blc: $(BLC)
build/Blc.S:
	mkdir -p ./build
	wget https://justine.lol/lambda/Blc.S?v=2
	mv Blc.S?v=2 ./build/Blc.S

build/flat.lds:
	mkdir -p ./build
	wget https://justine.lol/lambda/flat.lds
	mv flat.lds ./build

$(BLC): build/Blc.S build/flat.lds
	# Extend the maximum memory limit to execute large programs
	# Make TERMS configurable
	cd build; cat Blc.S | sed -e 's/#define.*TERMS.*//' > Blc.ext.S
	# Compile with the option -DTERMS=50000000 (larger than the original -DTERMS=5000000) to execute large programs
	cd build; $(CC) -c -DTERMS=50000000 -o Blc.o Blc.ext.S
	cd build; ld.bfd -o Blc Blc.o -T flat.lds
	mv build/Blc ./bin
	chmod 755 $(BLC)


build/tromp.c:
	mkdir -p ./build
	wget http://www.ioccc.org/2012/tromp/tromp.c
	mv tromp.c ./build

.PHONY: tromp
tromp: $(TROMP)
$(TROMP): ./build/tromp.c
	# Compile with the option -DA=9999999 (larger than the original -DM=999999) to execute large programs
	cd build; $(CC) -Wall -W -std=c99 -O2 -m64 -DInt=long -DA=9999999 -DX=8 tromp.c -o tromp
	mv build/tromp ./bin
	chmod 755 $(TROMP)

build/uni.c:
	mkdir -p ./build
	wget https://tromp.github.io/cl/uni.c
	mv uni.c ./build

.PHONY: uni
uni: $(UNI)
$(UNI): ./build/uni.c
	# Compile with the option -DA=9999999 (larger than the original -DM=999999) to execute large programs
	cd build; $(CC) -Wall -W -O2 -std=c99 -m64 -DM=9999999 uni.c -o uni
	mv build/uni ./bin
	chmod 755 $(UNI)

./build/AIT:
	mkdir -p ./build
	cd build; git clone https://github.com/tromp/AIT

.PHONY: blc-ait
blc-ait: $(BLCAIT)
$(BLCAIT): ./build/AIT ./build/AIT/AIT.lhs ./build/AIT/Lambda.lhs ./build/AIT/Main.lhs
	# Install Haskell dependencies
	$(CABAL) install dlist --lib
	$(CABAL) install mtl-2.2.2 --lib
	cd ./build/AIT; make blc
	mv ./build/AIT/blc ./bin/blc-ait


.PHONY: asc2bin
asc2bin: $(ASC2BIN)
$(ASC2BIN): ./src/asc2bin.c
	cd build; $(CC) ../src/asc2bin.c -O2 -o asc2bin
	mv build/asc2bin ./bin
	chmod 755 $(ASC2BIN)


.PHONY: lam2bin
lam2bin: $(LAM2BIN)

build/lam2bin.c:
	mkdir -p ./build
	wget https://justine.lol/lambda/lam2bin.c
	mv lam2bin.c ./build

build/lam2bin_ext.c: build/lam2bin.c
	# Extend the maximum term limit to execute large programs
	cd build; cat lam2bin.c | sed 's/int args\[1024\];/int args\[16777216\];/' > lam2bin_ext.c

$(LAM2BIN): build/lam2bin_ext.c
	cd build; $(CC) -O2 -o lam2bin lam2bin_ext.c
	mv build/lam2bin ./bin
	chmod 755 $(LAM2BIN)

