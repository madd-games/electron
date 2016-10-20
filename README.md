# Electron
This repository contains the source code for Electron development tools (compiler, standard library, etc) as well as specifications of the language.

## Index
The `specs` directory contains formal specifications of the programming language and ABI.

The `compiler` direcotry contains the Electron compiler, written in Electron itself. An older version of the compiler is necessary to build the compiler itself. The compiler parses Electron source file and outputs Electron Intermediate Representation (EIR) files.

The `bin` directory contains pre-compiled binaries of the EDK, for x86_64 Debian, as a `.deb` package. This is because that is required to build the compiler in the first place.

The `generator` directory contains the generator, which converts EIR files to assembly for a specific architecture, in accordance with the EGBI. Currently, only the `x86_64` target is supported.

The `libelec` directory contains the Electron standard library and runtime.
