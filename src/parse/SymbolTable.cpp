/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   This file implements the functions and objects specified in "SymbolTable.h"
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

#include "parse/SymbolTable.h"

bool SYMBOL_TABLE::addEntry(SYMBOL_TABLE_ENTRY x) {
    // Make sure there isn't already an entry with the same name
    std::map<std::string, SYMBOL_TABLE_ENTRY>::iterator itr;
    if ((itr = hashTable.find(x.getName())) == hashTable.end()) {
        hashTable.insert(make_pair(x.getName(), x));
        return true;
    }
    else return false;
}

TYPE_INFO SYMBOL_TABLE::findEntry(const std::string & theName) {
    TYPE_INFO info = {UNDEFINED, NOT_APPLICABLE, NOT_APPLICABLE, NOT_APPLICABLE};
    std::map<std::string, SYMBOL_TABLE_ENTRY>::iterator itr;
    if ((itr = hashTable.find(theName)) == hashTable.end())
        return(info);
    else return(itr->second.getTypeInfo());
}

void SYMBOL_TABLE::setScopeFunction(llvm::Function* theFunc) { funcDef = theFunc; }
llvm::Function* SYMBOL_TABLE::getScopeFunction() const { return funcDef; }

// Accessors
std::string SYMBOL_TABLE_ENTRY::getName() const { return name; }
TYPE_INFO SYMBOL_TABLE_ENTRY::getTypeInfo() const { return typeInfo; }
int SYMBOL_TABLE_ENTRY::getTypeCode() const { return typeInfo.type; }
int SYMBOL_TABLE_ENTRY::getStartIndex() const { return typeInfo.startIndex; }
int SYMBOL_TABLE_ENTRY::getEndIndex() const { return typeInfo.endIndex; }
int SYMBOL_TABLE_ENTRY::getBaseType() const { return typeInfo.baseType; }
llvm::Value* SYMBOL_TABLE_ENTRY::getVal() const { return typeInfo.val; }
