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

#include "config.h"
#include <iostream>

bool GlobalConfig::lexerVerbose = false;
bool GlobalConfig::parserVerbose = false;
bool GlobalConfig::ILVerbose = false;
bool GlobalConfig::printIL = false;
std::string GlobalConfig::targetArch = llvm::sys::getDefaultTargetTriple();;
std::string GlobalConfig::outputName = "a.out";

void GlobalConfig::printHelp() {
    std::cout <<
    "      ______                      _ _____________________   __\n" <<
    "     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /\n" <<
    "    / /   / __ \\/ __ `__ \\/ __ \\/ / / __/ / __/ / __/ /  |/ /\n" <<
    "   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /\n" <<
    "   \\____/\\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/\n" <<
    "                       /_/\n\n" <<
    "A Compiler for the MIPL language.\n" <<
    "USAGE:\nCompilEEEN [options] <input file>\n\n" <<
    "OPTIONS:\n" <<
    "-o <output>\tSpecify name of output binary\n" <<
    "-s <target>\tSpecify a triple for a custom architecture string (if installed)\n" <<
    "-lv\t\tPrints all lexer tokens when lexing input file\n" <<
    "-pv\t\tPrints all symbol table entries and grammar productions when parsing input file\n" <<
    "-iv\t\tPrints all IL generation verbose messages when creating LLVM IL code\n" <<
    "-p\t\tManually prints generated IL code and forgoes compilation" << std::endl;
}
