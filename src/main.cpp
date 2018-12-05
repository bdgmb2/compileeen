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
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/TargetRegistry.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/Target/TargetOptions.h>
#include "config.h"
#include "parse/parsefunctions.h"
#include "gen-parser.h"
#include "gen-lexer.h"
#include "ilgen/ilgen.h"
#include "ilgen/support.h"

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
    LLVMGen::module = llvm::make_unique<llvm::Module>(input, LLVMGen::context);
    PrintSupport::init();

    // loop as long as there is anything to parse
    ParseObj::inputFile = fopen(input.c_str(), "r");
    if (ParseObj::inputFile == nullptr) { std::cout << "Cannot open \"" << input << "\": no such file or directory" << std::endl; return 2; }
    yyin = ParseObj::inputFile;
    do {
        yyparse();
    } while (!feof(ParseObj::inputFile));
    fclose(ParseObj::inputFile);

    ParseFunctions::cleanUp();

    // Generate machine code to file or printout
    LLVMGen::module->setTargetTriple(GlobalConfig::targetArch);
    if (GlobalConfig::printIL) {
        LLVMGen::module->print(llvm::outs(), nullptr);
    } else {
        // Set LLVM target options and configure
        llvm::TargetOptions opt;
        auto RM = llvm::Optional<llvm::Reloc::Model>();
        auto TargetMachine = targetDef->createTargetMachine(GlobalConfig::targetArch, "generic", "", opt, RM);
        LLVMGen::module->setDataLayout(TargetMachine->createDataLayout());

        // Write out to file
        std::error_code fileOutErr;
        llvm::raw_fd_ostream outputFile(GlobalConfig::outputName + ".tmp", fileOutErr, llvm::sys::fs::F_None);
        if (fileOutErr) { std::cout << "Fatal error: " << fileOutErr.message() << std::endl; return 3; }
        llvm::legacy::PassManager pass;
        if (TargetMachine->addPassesToEmitFile(pass, outputFile, llvm::TargetMachine::CGFT_ObjectFile))
        { std::cout << "Fatal error: CompilEEEN cannot emit an object file with this architecture." << std::endl; return 4; }
        pass.run(*LLVMGen::module);
        outputFile.flush();
        outputFile.close();

        // Now that the file is generated, we need to link it to create an executable. I found out recently that this
        // is a giant pain without a flagship compiler like GCC or Clang, so we find either one of those and use that.
        // We're gonna make a WILD assumption that this is a UNIX-like system and either gcc or clang is in "/usr/bin"
        std::string command = std::string("/usr/bin/clang ") + GlobalConfig::outputName + std::string(".tmp -o ") + GlobalConfig::outputName;
        system(command.c_str());
        system((std::string("rm ") + GlobalConfig::outputName + ".tmp").c_str());
    }

    return 0;
}