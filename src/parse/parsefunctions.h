/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   This file declares functions and objects (all static) shared amongst the lexer and parser.
   These are used to detect and report grammar production success/failure.
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

#ifndef MIPLNATIVE_PARSEFUNC_H
#define MIPLNATIVE_PARSEFUNC_H

#define MAX_INT	"2147483647"

#include "SymbolTable.h"
#include <llvm/IR/Module.h>
#include <string>
#include <stack>
#include <list>

typedef char Cstring[256];
const Cstring ERR_MSG[] = {
        "Expression must be of type boolean",
        "Expression must be of type integer",
        "Indexed variable must be of array type",
        "Cannot make assignment to an array",
        "Procedure/variable mismatch",
        "Expression must be of same type as variable",
        "Expressions must both be int, or both char, or both boolean",
        "Index expression must be of type integer",
        "Input variable must be of type integer or char",
        "Output expression must be of type integer or char",
        "Multiply defined identifier",
        "Start index must be less than or equal to end index of array",
        "Undefined identifier"
};

struct ParseFunctions {
    static int checkInteger(char *text);
    static char getNextCharacter();
    static void ignoreComments();
    static void throwError(const char* message);
    static void throwError(const int errMessageNum);
    static void printRule(const char*, const char*);
    static void printTokenInfo(const char* tokenType, const char* lexeme);
    static void printSymbolTableAddition(const std::string & identName, const TYPE_INFO* typeInfo);
    static void beginScope();
    static void endScope();
    static void cleanUp();
    static TYPE_INFO findEntryInAnyScope(const std::string & theName);
};

struct ParseObj {
    static std::stack<SYMBOL_TABLE> scopeStack;     // stack of scope hashtables
    static std::list<std::string> variableNames;		    // list of declared variables
    static int lineNum;

    static FILE* inputFile;
    static std::stack<llvm::Value*> valStack;
};

#endif //MIPLNATIVE_PARSEFUNC_H
