# Lambda Calculus Development Toolkit

This repo is a collection of tools for writing programs in lambda calculus and SKI combinator calculus, written by various authors.

This repo is designed and intended to be used as a dependency manager for projects related to lambda calculus programming.

This repo includes tools and interpreters for the following lambda-calculus-based languages:

- [Binary Lambda Calculus](https://tromp.github.io/cl/cl.html)
- [Universal Lambda](http://www.golfscript.com/lam/)
- [Lazy K](https://tromp.github.io/cl/lazy-k.html)


## Dependency Graph
![Lambda calculus language dependency graph](./bin/graph.png)

## Supported Interpreters and Tools

Interpreters

- [Blc](https://justine.lol/lambda/): Written by [Justine Tunney](https://github.com/jart). SectorLambda, a [521-byte lambda calculus interpreter](https://justine.lol/lambda/)
- [tromp](https://www.ioccc.org/2012/tromp/hint.html): Written by [John Tromp](https://github.com/tromp). The [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) interpreter
  (its [source](https://www.ioccc.org/2012/tromp/tromp.c) is in the shape of a λ)
- [uni](https://tromp.github.io/cl/cl.html): Written by [John Tromp](https://github.com/tromp). An unobfuscated version of `tromp`
- [uni++](https://github.com/melvinzhang/binary-lambda-calculus): Written by [Melvin Zhang](https://github.com/melvinzhang). A fast binary lambda calculus interpreter written in C++, featuring many speed and memory optimizations.
  - A rewrite of `uni`. Originally named `uni`. Named `uni++` in this repo to distinguish from `uni`
- [UniObf](https://github.com/tromp/AIT/blob/master/UniObf.hs): Written by [John Tromp](https://github.com/tromp). A bitwise BLC interpreter written in obfuscated-style Haskell
- [lazyk](https://github.com/irori/lazyk): Written by [Kunihiko Sakamoto](https://github.com/irori). A fast [Lazy K](https://tromp.github.io/cl/lazy-k.html) interpreter
- [clamb](https://github.com/irori/clamb): Written by [Kunihiko Sakamoto](https://github.com/irori). A fast [Universal Lambda](http://www.golfscript.com/lam/) interpreter

Tools

- [asc2bin](src/asc2bin.c): Written by [Hikaru Ikuta](https://github.com/woodrush). Packs 0/1 ASCII bit streams to byte streams. Used for BLC interpreters
- [lam2bin](https://justine.lol/lambda/): Written by [Justine Tunney](https://github.com/jart). Parses plaintext lambda terms such as `\x.x` to BLC notation
- [blc-ait](https://github.com/tromp/AIT): Written by [John Tromp](https://github.com/tromp). A multi-functional tool for binary lambda calculus, binary combinator calculus, etc. Includes a head normal form optimizer for lambda terms and many more features.
  - Originally named `blc`. Named `blc-ait` in this repo to distinguish between `Blc`

## Other Tools
Not included in this repo, but related to lambda calculus programming:

- [LambdaCraft](https://github.com/woodrush/lambdacraft): Written by Written by [Hikaru Ikuta](https://github.com/woodrush). A Common Lisp DSL for building untyped lambda calculus terms. Compilable with BLC notation and SKI combinator calculus notation, for programming in BLC, UL, and Lazy K.


## Lambda Calculus Interpreter Details
Below is a summary of the supported lambda calculus interpreters.
Each interpreter uses a slightly different I/O encoding, classified below as languages.


| Language                                                             | Extension       | Engine                  | Program Format               |
|----------------------------------------------------------------------|-----------------|-------------------------|------------------------------|
| [Binary Lambda Calculus](https://tromp.github.io/cl/cl.html)         | *.blc           | Untyped Lambda Calculus | Binary (asc2bin can be used) |
| [Bitwise Binary Lambda Calculus](https://tromp.github.io/cl/cl.html) | *.blc, *.bitblc | Untyped Lambda Calculus | ASCII                        |
| [Universal Lambda](http://www.golfscript.com/lam/)                   | *.ulamb         | Untyped Lambda Calculus | Binary (asc2bin can be used) |
| [Lazy K](https://tromp.github.io/cl/lazy-k.html)                     | *.lazy          | SKI Combinator Calculus | ASCII                        |

| Interpreter                                                     | Language                       | Platforms    | Build Command | Author                                         | Notes                                                                                                                                                                                |
|-----------------------------------------------------------------|--------------------------------|--------------|---------------|------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Blc](https://justine.lol/lambda/)                              | Binary Lambda Calculus         | x86-64-Linux | `make blc`    | [@jart](https://github.com/jart)               | [521-byte interpreter](https://justine.lol/lambda/)                                                                                                                                  |
| [tromp](https://www.ioccc.org/2012/tromp/hint.html)             | Binary Lambda Calculus         | Any          | `make tromp`  | [@tromp](https://github.com/tromp)             | [IOCCC](https://www.ioccc.org/) 2012 ["Most functional"](https://www.ioccc.org/2012/tromp/hint.html) - the [source](https://www.ioccc.org/2012/tromp/tromp.c) is in the shape of a λ |
| [uni](https://tromp.github.io/cl/cl.html)                       | Binary Lambda Calculus         | Any          | `make uni`    | [@tromp](https://github.com/tromp)             | Unobfuscated version of `tromp`                                                                                                                                                      |
| [uni++](https://github.com/melvinzhang/binary-lambda-calculus)  | Binary Lambda Calculus         | Any          | `make uni++`  | [@melvinzhang](https://github.com/melvinzhang) | Fast binary lambda calculus interpreter written in C++, featuring many speed and memory optimizations. A rewrite of `uni`. Originally named `uni`                                    |
| [UniObf](https://github.com/tromp/AIT/blob/master/UniObf.hs)    | Bitwise Binary Lambda Calculus | Any          | `make UniObf` | [@tromp](https://github.com/tromp)             | Features optimizations included in `uni++`. Written in obfuscated-style Haskell                                                                                                      |
| [clamb](https://github.com/irori/clamb)                         | Universal Lambda               | Any          | `make clamb`  | [@irori](https://github.com/irori)             | Fast UL interpreter                                                                                                                                                                  |
| [lazyk](https://github.com/irori/lazyk)                         | Lazy K                         | Any          | `make lazyk`  | [@irori](https://github.com/irori)             | Fast Lazy K interpreter                                                                                                                                                              |


## Building the Interpreters and Tools
To build all interpreters:

```sh
make blc tromp uni uni++ UniObf clamb lazyk
```

Several notes about the interpreters:

- The BLC intepreter `Blc` runs only on x86-64-Linux systems.
- The BLC interpreter `tromp` may not compile on a Mac with the defualt gcc (which is actually an alias of clang). Details are provided below.

To build all tools:

```sh
make asc2bin lam2bin blc-ait
```

### Building `tromp` on a Mac
Mac has `gcc` installed by default or via Xcode Command Line Tools.
However, `gcc` is actually installed as an alias to `clang`, which is a different compiler that doesn't compile `tromp`.
This is confirmable by running `gcc --version`. On my Mac, running it shows:

```sh
$ gcc --version
Configured with: --prefix=/Applications/Xcode.app/Contents/Developer/usr --with-gxx-include-dir=/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/c++/4.2.1
Apple clang version 12.0.0 (clang-1200.0.32.29)
Target: x86_64-apple-darwin19.6.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

A workaround for this is to use `uni` instead, which is an unobfuscated version of `tromp` compilable with clang.
To build `tromp`, first install gcc via [Homebrew](https://brew.sh/):

```sh
brew install gcc
```

Currently, this should install the command `gcc-11`.
After installing gcc, check the command it has installed.

Then, edit the `Makefile`'s `CC` configuration:

```diff
- CC=cc
+ CC=gcc-11
```

Then, running
```sh
make tromp
```
will compile `tromp`.


## Usage
Please see the "Running LambdaLisp" section in my other project [LambdaLisp](https://github.com/woodrush/lambdalisp#running-lambdalisp) for details.
