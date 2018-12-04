/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   A MIPL to x86-amd64 native compiler.
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

#include <iostream>
#include <cstring>
#include <llvm/IR/Module.h>
#include <llvm/Support/TargetRegistry.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/Target/TargetOptions.h>
#include "config.h"
#include "parse/parsefunctions.h"
#include "gen-parser.h"
#include "gen-lexer.h"
#include "ilgen/ilgen.h"

int main(int argc, char* argv[]) {
    std::string input = "";

    // Read in arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) { GlobalConfig::printHelp(); return 0; }
        else if (strcmp(argv[i], "-o") == 0) {
            if (i + 1 == argc) { std::cout << "Fatal error: must specify output filename." << std::endl; return 1; }
            GlobalConfig::outputName = argv[i + 1];
            i++;
        }
        else if (strcmp(argv[i], "-s") == 0) {
            if (i + 1 == argc) { std::cout << "Fatal error: must specify architecture triple." << std::endl; return 1; }
            GlobalConfig::targetArch = argv[i + 1];
            i++;
        }
        else if (strcmp(argv[i], "-lv") == 0)
            GlobalConfig::lexerVerbose = true;
        else if (strcmp(argv[i], "-pv") == 0)
            GlobalConfig::parserVerbose = true;
        else if (strcmp(argv[i], "-iv") == 0)
            GlobalConfig::ILVerbose = true;
        else if (strcmp(argv[i], "-p") == 0)
            GlobalConfig::printIL = true;
        else if (input == "" && argv[i][0] != '-')
            input = argv[i];
        else { std::cout << "Fatal error: Unrecognized option: \"" << argv[i] << "\"" << std::endl; return 1; }
    }

    if (input == "") {
        std::cout << "Fatal error: no input file. Use -h for help." << std::endl;
        return 1;
    }

    // Check compile target
    LLVMGen::setupTargetSystems();
    std::string err;
    auto targetDef = llvm::TargetRegistry::lookupTarget(GlobalConfig::targetArch, err);
    if (!targetDef) {
        std::cout << "Error when checking compiler target: " << err << std::endl;
        return 2;
    }

    // Generate LLVM IR output module
    LLVMGen::module = llvm::make_unique<llvm::Module>("MIPL", LLVMGen::context);
    LLVMGen::module->setTargetTriple(GlobalConfig::targetArch);

    // loop as long as there is anything to parse
    ParseObj::inputFile = fopen(input.c_str(), "r");
    if (ParseObj::inputFile == nullptr) { std::cout << "Cannot open \"" << input << "\": no such file or directory" << std::endl; return 2; }
    yyin = ParseObj::inputFile;
    do {
        yyparse();
    } while (!feof(ParseObj::inputFile));
    fclose(ParseObj::inputFile);

    llvm::TargetOptions opt;
    auto TargetMachine = targetDef->createTargetMachine(GlobalConfig::targetArch, "generic", "", opt, llvm::Optional<llvm::Reloc::Model>());
    LLVMGen::module->setDataLayout(TargetMachine->createDataLayout());

    ParseFunctions::cleanUp();
    return 0;
}