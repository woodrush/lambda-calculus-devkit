# This setting needs to be changed on a Mac to compile tromp.c (make ./bin/tromp, make test-blc-tromp, etc.).
# Please see README.md for details.
CC=cc

# Binary lambda calculus
BLC=./bin/Blc
UNI=./bin/uni
TROMP=./bin/tromp
UNIPP=./bin/uni++
UNID=./bin/unid
UNIOBF=./bin/UniObf
BLCAIT=./bin/blc-ait

# Universal lambda
CLAMB=./bin/clamb

# Lazy K
LAZYK=./bin/lazyk


# Tools
ASC2BIN=./bin/asc2bin
ASC2BIT=./bin/asc2bit
LAM2BIN=./bin/lam2bin
BCL2SKI=./bin/bcl2ski

# Others
CABAL=cabal


all: interpreters tools
interpreters: blc tromp uni uni++ UniObf clamb lazyk
tools: asc2bin lam2bin blc-ait



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

.PHONY: UniObf
UniObf: $(UNIOBF)
$(UNIOBF): ./build/AIT ./build/AIT/UniObf.hs
	# Install Haskell dependencies
	$(CABAL) install dlist --lib
	$(CABAL) install mtl-2.2.2 --lib
	$(CABAL) install --lib parsec-3.1.14.0
	cd ./build/AIT; ghc UniObf.hs
	mv ./build/AIT/UniObf ./bin


.PHONY: asc2bin
asc2bin: $(ASC2BIN)
$(ASC2BIN): ./src/asc2bin.c
	mkdir -p build
	cd build; $(CC) ../src/asc2bin.c -O2 -o asc2bin
	mv build/asc2bin ./bin
	chmod 755 $(ASC2BIN)

.PHONY: asc2bit
asc2bin: $(ASC2BIT)
$(ASC2BIT): ./src/asc2bit.c
	mkdir -p build
	cd build; $(CC) ../src/asc2bit.c -O2 -o asc2bit
	mv build/asc2bit ./bin
	chmod 755 $@

.PHONY: bcl2ski
bcl2ski: $(BCL2SKI)
$(BCL2SKI): ./src/bcl2ski.c
	mkdir -p build
	cd build; $(CC) ../src/bcl2ski.c -O2 -o bcl2ski
	mv build/bcl2ski ./bin
	chmod 755 $(BCL2SKI)


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

