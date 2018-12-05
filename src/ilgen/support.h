/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   This file declares the structure and items contained within the global parser symbol table.
   This includes both the symbol table itself as well as the definition of an entry within the symbol table.
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

#ifndef COMPILEEEN_SUPPORT_H
#define COMPILEEEN_SUPPORT_H

#include <llvm/IR/Instructions.h>
#include <llvm/IR/Value.h>
#include <memory>

struct PrintSupport {
    static llvm::Function* printfProto;
    static llvm::Constant *printChar, *printInt;

    static void init();
    static llvm::Constant* geti8StrVal(const std::string & str, llvm::Twine const& name);
};

#endif //COMPILEEEN_SUPPORT_H
