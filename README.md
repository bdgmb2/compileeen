```
      ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/
```
A MIPL to any-arch native compiler.

Ben Giles, CS5500 Compilers, Missouri S&T

## To Compile:
Before cloning and compiling this project, you'll need:
- CMake (3.5 or newer)
- Clang
- LLVM 6
- Flex
- Bison

The following commands will configure and build the compiler for your host architecture:
1. `mkdir build && cd build`
2. `cmake ..`
3. `make -j [num threads]`
4. `./CompilEEEN file.mipl -o output_exec`

To build for another architecture (such as armhf), use a CMake cross-compile toolchain file in conjunction with this project.

To run tests, use `make test`. To view generated LLVM code, run `./CompilEEEN -p`. To see all compiler-supported options, run `./CompilEEEN --help`.

## Notes For Grader:
This project _should_ work out of the box on any campus CSLinux machine. If it does not, contact me immediately at bdgmb2@mst.edu

I seriously misunderestimated the scope of adding LLVM translation to the MIPL language when taking on this project, and as such only a few constructs work. This project would have been better suited to take the entire semester.

Most development time went into getting a proper build system working, as I spent quite a bit of time changing the provided Flex and Bison files to be compatible with CMake (or any build system for that matter). Another obstacle was creating the actual executable - I soon found out that LLVM is a compiler infrastructure, **not** a linker. This is why Clang _must_ be installed to work, as compiled machine code output needs to be piped through Clang (or any linker, really) to produce an actual executable. I considered using [LLD](https://lld.llvm.org/) (LLVM's own linker), but it is not documented at all and figured piping through Clang would be easier.

To compare CompilEEEN's LLVM output with a similar C++ program in Clang, run:
`./CompilEEEN -p input.mipl` to see a printout of the MIPL-sourced LLVM
`clang -S -emit-llvm input.cpp` to get a file named `input.ll` containing Clang-sourced LLVM

The following MIPL constructs have been implemented. A question mark denotes a working construct under specific conditions. If these conditions are not met, the resulting program may not work as expected.
| | |
| --- | --- |
| ✓ | Constant Variable Assignment |
| ✓ | printf() equivalent (as extern call) |
| ✓ | scanf() equivalent (as extern call) |
| ✓ | Other C-supported extern calls |
| ✓ | Variable-to-variable assignment |
| ? | If Statements |
| ? | Expression Arithmetic |
| X | While Statements |
| X | Procedures |
| X | MIPL Arrays |