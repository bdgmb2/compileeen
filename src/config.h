/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   Thie file declares global flags used across the whole compiler.
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

#ifndef MIPLNATIVE_CONFIG_H
#define MIPLNATIVE_CONFIG_H

#include <string>
#include <llvm/Support/Host.h>

struct GlobalConfig {
    static bool lexerVerbose, parserVerbose, ILVerbose;
    static bool printIL;
    static std::string targetArch;
    static std::string outputName;

    static void printHelp();
};

#endif //MIPLNATIVE_CONFIG_H
