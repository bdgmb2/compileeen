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

#include "ilgen/support.h"
#include "ilgen/ilgen.h"
#include <llvm/IR/Instructions.h>
#include <llvm/IR/TypeBuilder.h>
#include <llvm/IR/Value.h>
#include <iostream>
#include <vector>

llvm::Constant* PrintSupport::printChar = nullptr;
llvm::Constant* PrintSupport::printInt = nullptr;
llvm::Function* PrintSupport::printfProto = nullptr;

llvm::Function* constructPrintfProto() {
    std::vector<llvm::Type*> printf_arg_types;
    printf_arg_types.push_back(llvm::Type::getInt8PtrTy(LLVMGen::context));

    llvm::FunctionType* printf_type = llvm::FunctionType::get(llvm::Type::getInt32Ty(LLVMGen::context), printf_arg_types, true);
    llvm::Function *func = llvm::Function::Create(printf_type, llvm::Function::ExternalLinkage, llvm::Twine("printf"), LLVMGen::module.get());
    func->setCallingConv(llvm::CallingConv::C);
    return func;
}

void PrintSupport::init() {
    printChar = PrintSupport::geti8StrVal("%c", "printchar");
    printInt = PrintSupport::geti8StrVal("%d", "printint");
    printfProto = constructPrintfProto();
}

llvm::Constant* PrintSupport::geti8StrVal(const std::string & str, llvm::Twine const& name) {
    llvm::Constant* strConstant = llvm::ConstantDataArray::getString(LLVMGen::context, str);
    llvm::GlobalVariable* GVStr = new llvm::GlobalVariable(*LLVMGen::module, strConstant->getType(), true, llvm::GlobalValue::InternalLinkage, strConstant, name);
    llvm::Constant* zero = llvm::Constant::getNullValue(llvm::IntegerType::getInt32Ty(LLVMGen::context));
    llvm::Constant* indices[] = { zero, zero };
    llvm::Constant* strVal = llvm::ConstantExpr::getGetElementPtr(strConstant->getType(), GVStr, indices, true);
    return strVal;
}