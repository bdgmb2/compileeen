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

#ifndef MIPLNATIVE_ILGEN_H
#define MIPLNATIVE_ILGEN_H

#include <llvm/IR/Module.h>
#include <llvm/IR/Value.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <memory>
#include <string>

struct LLVMGen {
    // Generate LLVM IR
    static llvm::LLVMContext context;
    static llvm::IRBuilder<> Builder;
    static std::unique_ptr<llvm::Module> module;
    static std::map<std::string, llvm::Value*> namedVals;

    static void setupTargetSystems();
};

#endif //MIPLNATIVE_ILGEN_H
