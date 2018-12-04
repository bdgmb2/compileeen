/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   This file implements the functions and objects specified in "Parsefunctions.h"
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

#include "parsefunctions.h"
#include "gen-lexer.h"
#include "config.h"
#include <iostream>
#include <cstring>
#include <stack>
#include <list>

int ParseObj::lineNum = 1;
FILE* ParseObj::inputFile;
std::stack<SYMBOL_TABLE> ParseObj::scopeStack;
std::list<std::string> ParseObj::variableNames;

char ParseFunctions::getNextCharacter() {
    return fgetc(ParseObj::inputFile);
    //return getchar();
}

int ParseFunctions::checkInteger(char* text) {
    char *ptr = text;
    int	rc = 0;

    /* ignore sign and leading zeroes */
    if (*ptr == '-' || *ptr == '+')
        ++ptr;
    while (*ptr == '0')
        ++ptr;

    switch (*ptr) {
        case '1':	/* ALL are valid */
            break;

        case '2':	/* it depends */
            if (strcmp(MAX_INT, ptr) < 0)
                rc = 1;
            break;

        default:	     /* ALL are invalid */
            rc = 1;
            break;
    }
    return rc;
}

void ParseFunctions::ignoreComments() {
    char c, pc = 0;

    // read and ignore input until you get "*)"
    while (((c = getNextCharacter()) != ')' || pc != '*') && c != 0) {
        pc = c;
        if (c == '\n') ParseObj::lineNum++;
    }
}

TYPE_INFO ParseFunctions::findEntryInAnyScope(const std::string & theName) {
    TYPE_INFO info = { UNDEFINED, NOT_APPLICABLE, NOT_APPLICABLE, NOT_APPLICABLE };
    if (ParseObj::scopeStack.empty( )) return(info);
    info = ParseObj::scopeStack.top().findEntry(theName);
    if (info.type != UNDEFINED)
        return(info);
    else { // check in "next higher" scope
        SYMBOL_TABLE symbolTable = ParseObj::scopeStack.top();
        ParseObj::scopeStack.pop();
        info = findEntryInAnyScope(theName);
        ParseObj::scopeStack.push(symbolTable); // restore the stack
        return(info);
    }
}

void ParseFunctions::printTokenInfo(const char* tokenType, const char* lexeme) {
    if (GlobalConfig::lexerVerbose)
        std::cout << "TOKEN: " << tokenType << " LEXEME: " << lexeme << std::endl;
}

void ParseFunctions::beginScope() {
    ParseObj::scopeStack.push(SYMBOL_TABLE());
    if (GlobalConfig::parserVerbose)
        std::cout << "\n___Entering new scope...\n" << std::endl;
}

void ParseFunctions::endScope() {
    ParseObj::scopeStack.pop();
    if (GlobalConfig::parserVerbose)
        std::cout << "\n___Exiting scope...\n" << std::endl;
}

void ParseFunctions::cleanUp() {
    if (ParseObj::scopeStack.empty())
        return;
    else {
        ParseObj::scopeStack.pop();
        cleanUp();
    }
}

void ParseFunctions::printRule(const char *lhs, const char *rhs) {
    if (GlobalConfig::parserVerbose)
        std::cout << lhs << " -> " << rhs << std::endl;
}

void ParseFunctions::throwError(const int errMessageNum) {
    printf("Line %d: %s\n", ParseObj::lineNum, ERR_MSG[errMessageNum]);
    ParseFunctions::cleanUp();
    exit(3);
}
void ParseFunctions::throwError(const char *message) {
    printf("Line %d: %s\n", ParseObj::lineNum, message);
    ParseFunctions::cleanUp();
    exit(3);
}

void ParseFunctions::printSymbolTableAddition(const std::string & identName, const TYPE_INFO* typeInfo) {
    if (GlobalConfig::parserVerbose)
    {
        char *cstr = new char[identName.length() + 1];
        strcpy(cstr, identName.c_str());
        printf("___Adding %s to symbol table with type ", cstr);
        delete [] cstr;
        switch (typeInfo->type) {
            case PROGRAM	: printf("PROGRAM\n");
                break;
            case PROCEDURE	: printf("PROCEDURE\n");
                break;
            case INT		: printf("INTEGER\n");
                break;
            case CHAR		: printf("CHAR\n");
                break;
            case BOOL		: printf("BOOLEAN\n");
                break;
            case ARRAY		: printf("ARRAY ");
                printf("%d .. %d OF ",
                       typeInfo->startIndex,
                       typeInfo->endIndex);
                switch (typeInfo->baseType) {
                    case INT : printf("INTEGER\n");
                        break;
                    case CHAR: printf("CHAR\n");
                        break;
                    case BOOL: printf("BOOLEAN\n");
                        break;
                    default : printf("UNKNOWN\n");
                        break;
                }
                break;
            default 		: printf("UNKNOWN\n");
                break;
        }
    }
}