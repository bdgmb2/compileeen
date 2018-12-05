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
#include <llvm/IR/Module.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Value.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/Support/Host.h>
#include <llvm/Support/TargetRegistry.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/Target/TargetOptions.h>
#include <memory>
#include <iostream>
#include "ilgen.h"
#include "parse/SymbolTable.h"

llvm::LLVMContext LLVMGen::context;
llvm::IRBuilder<> LLVMGen::Builder(LLVMGen::context);
std::unique_ptr<llvm::Module> LLVMGen::module;
std::map<std::string, llvm::Value*> LLVMGen::namedVals;

void LLVMGen::setupTargetSystems() {
    llvm::InitializeAllTargetInfos();
    llvm::InitializeAllTargets();
    llvm::InitializeAllTargetMCs();
    llvm::InitializeAllAsmParsers();
    llvm::InitializeAllAsmPrinters();
}

llvm::Value* LLVMGen::createAlloc(llvm::Function* theFunc, unsigned int type, std::string & varName) {
    llvm::IRBuilder<> temporary(&theFunc->getEntryBlock(), theFunc->getEntryBlock().end());
    llvm::Type* theType;
    if (type == INT) {
        theType = llvm::Type::getInt32Ty(context);
    } else if (type == CHAR || type == BOOL) {
        theType = llvm::Type::getInt8Ty(context);
    } else {
        std::cout << "Incorrect type passed to IR generation!" << std::endl;
        exit(2);
    }
    return temporary.CreateAlloca(theType, 0, nullptr, varName.c_str());
}