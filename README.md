# Lambda Calculus Development Toolkit

This repo is a collection of tools for writing programs in lambda calculus and SKI combinator calculus, written by various authors.

This repo is designed and intended to be used as a dependency manager for projects related lambda calculus programming.


## Dependency Graph
![Lambda calculus language dependency graph](./bin/graph.png)

## Supported Interpreters and Tools

Interpreters

- [Blc](https://justine.lol/lambda/): Written by [Justine Tunney](https://github.com/jart). SectorLambda, a [521-byte lambda calculus interpreter](https://justine.lol/lambda/)
- [tromp](https://www.ioccc.org/2012/tromp/hint.html): Written by [John Tromp](https://github.com/tromp). The [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) interpreter
  (the [source](https://www.ioccc.org/2012/tromp/tromp.c) is in the shape of a λ)
- [uni](https://tromp.github.io/cl/cl.html): Written by [John Tromp](https://github.com/tromp). An unobfuscated version of `tromp`
- [uni++](https://github.com/melvinzhang/binary-lambda-calculus): Written by [Melvin Zhang](https://github.com/melvinzhang). Fast binary lambda calculus interpreter written in C++, featuring many speed and memory optimizations.
  - A rewrite of `uni`. Originally named `uni`. Named `uni++` in this repo to distinguish from `uni`
- [lazyk](https://github.com/irori/lazyk): Written by [Kunihiko Sakamoto](https://github.com/irori). A fast [Lazy K](https://tromp.github.io/cl/lazy-k.html) interpreter
- [clamb](https://github.com/irori/clamb): Written by [Kunihiko Sakamoto](https://github.com/irori). A fast [Universal Lambda](http://www.golfscript.com/lam/) interpreter

Tools

- asc2bin: Written by [Hikaru Ikuta](https://github.com/woodrush). Pack 0/1 ASCII bit streams to byte streams. Used for BLC interpreters
- [lam2bin](https://justine.lol/lambda/): Written by [Justine Tunney](https://github.com/jart). Parses plaintext lambda terms such as `\x.x` to BLC notation
- [blc-ait](https://github.com/tromp/AIT): Written by [John Tromp](https://github.com/tromp). A multi-functional tool for binary lambda calculus, binary combinator calculus, etc.
  - Originally named `blc`. Named `blc-ait` in this repo to distinguish between `Blc`

## Other Tools
Not included in this repo, but related to lambda calculus programming:

- [LambdaCraft](https://github.com/woodrush/lambdacraft): Written by Written by [Hikaru Ikuta](https://github.com/woodrush). A Common Lisp DSL for building untyped lambda calculus terms. Compilable with BLC notation and SKI combinator calculus notation, for programming in BLC, UL, and Lazy K.


## Lambda Calculus Interpreter Details
Below is a summary of the supported lambda calculus interpreters.
Each interpreter uses a slightly different I/O encoding, classified below as languages.


| Language                                                     | Extension | Engine                  | Program Format               |
|--------------------------------------------------------------|-----------|-------------------------|------------------------------|
| [Binary Lambda Calculus](https://tromp.github.io/cl/cl.html) | *.blc     | Untyped Lambda Calculus | Binary (asc2bin can be used) |
| [Universal Lambda](http://www.golfscript.com/lam/)           | *.ulamb   | Untyped Lambda Calculus | Binary (asc2bin can be used) |
| [Lazy K](https://tromp.github.io/cl/lazy-k.html)             | *.lazy    | SKI Combinator Calculus | ASCII                        |

| Interpreter                                                     | Language               | Platforms    | Build Command | Author                                         | Notes                                                                                                                                                                                |
|-----------------------------------------------------------------|------------------------|--------------|---------------|------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Blc](https://justine.lol/lambda/)                              | Binary Lambda Calculus | x86-64-Linux | `make blc`    | [@jart](https://github.com/jart)               | [521-byte interpreter](https://justine.lol/lambda/)                                                                                                                                  |
| [tromp](https://www.ioccc.org/2012/tromp/hint.html)             | Binary Lambda Calculus | Any          | `make tromp`  | [@tromp](https://github.com/tromp)             | [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) - the [source](https://www.ioccc.org/2012/tromp/tromp.c) is in the shape of a λ |
| [uni](https://tromp.github.io/cl/cl.html)                       | Binary Lambda Calculus | Any          | `make uni`    | [@tromp](https://github.com/tromp)             | Unobfuscated version of `tromp`                                                                                                                                                      |
| [uni++](https://github.com/melvinzhang/binary-lambda-calculus)  | Binary Lambda Calculus | Any          | `make uni++`  | [@melvinzhang](https://github.com/melvinzhang) | Fast binary lambda calculus interpreter written in C++, featuring many speed and memory optimizations. A rewrite of `uni`. Originally named `uni`                                    |
| [clamb](https://github.com/irori/clamb)                         | Universal Lambda       | Any          | `make clamb`  | [@irori](https://github.com/irori)             | Fast UL interpreter                                                                                                                                                                  |
| [lazyk](https://github.com/irori/lazyk)                         | Lazy K                 | Any          | `make lazyk`  | [@irori](https://github.com/irori)             | Fast Lazy K interpreter                                                                                                                                                              |

### Building the Lambda Calculus Interpreters
Several notes about the interpreters:

- The BLC intepreter `Blc` runs only on x86-64-Linux systems.
- The BLC interpreter `tromp` may not compile on a Mac with the defualt gcc (which is actually an alias of clang). Details are provided below.

<!-- - The most reliably compilable BLC interpreter is `uni`, which compiles and runs on both Linux and Mac. -->
<!-- - The interpreters for Universal Lambda and Lazy K, `clamb` and `lazyk`, can be built and run on both of these systems. -->

<!-- To build all interpreters:

```sh
make interpreters
```

Or, to build them individually:
```sh
make blc tromp uni lambda clamb lazyk asc2bin
```

Here, asc2bin is a utility that packs ASCII 0/1 bitstreams to a byte stream, the format accepted by the BLC and UL interpreters.

The interpreters' source codes are obtained from external locations.
When the make recipe is run, each recipe obtains these external source codes using the following commands:

- `blc`:
  - `Blc.S`: `wget https://justine.lol/lambda/Blc.S?v=2`
  - `flat.lds`: `wget https://justine.lol/lambda/flat.lds`
- `lambda`:
  - Various files from `https://justine.lol/lambda/`
- `uni`: `wget https://tromp.github.io/cl/uni.c`
- `tromp`: `wget http://www.ioccc.org/2012/tromp/tromp.c`
- `clamb`: `git clone https://github.com/irori/clamb`
- `lazyk`: `git clone https://github.com/irori/lazyk` -->
