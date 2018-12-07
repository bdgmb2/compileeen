/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   BISON Specification file for the MIPL (Mini-Pascal) Language
   This file specifies valid grammar productions for the MIPL language.
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

%{

#include <cstdlib>
#include <iostream>
#include <string>
#include <cstring>
#include <stack>
#include <list>
#include <llvm/Support/raw_ostream.h>
#include "parse/SymbolTable.h"
#include "parse/parsefunctions.h"
#include "ilgen/ilgen.h"
#include "ilgen/support.h"
#include "gen-lexer.h"

using std::string;

extern "C" {
    int yyerror(const char* message) { ParseFunctions::throwError(message); }
    int yywrap() { return 1; }
    char yyinput() { return ParseFunctions::getNextCharacter(); }
}

#define LOGICAL_OP    100
#define ARITHMETIC_OP 101

#define POSITIVE		1
#define NEGATIVE		-1
#define NO_SIGN		0

#define ERR_EXPR_MUST_BE_BOOL				0
#define ERR_EXPR_MUST_BE_INT				1 
#define ERR_INDEX_VAR_MUST_BE_ARRAY			2 
#define ERR_CANNOT_ASSIGN_TO_ARRAY			3 
#define ERR_PROCEDURE_VAR_MISMATCH			4
#define ERR_EXPR_MUST_BE_SAME_AS_VAR			5
#define ERR_EXPRS_MUST_BOTH_BE_SAME_TYPE		6
#define ERR_INDEX_EXPR_MUST_BE_INT			7
#define ERR_INPUT_VAR_MUST_BE_INT_OR_CHAR		8
#define ERR_OUTPUT_VAR_MUST_BE_INT_OR_CHAR		9
#define ERR_MULTIPLY_DEFINED_IDENT			10
#define ERR_START_INDEX_MUST_BE_LE_END_INDEX	11
#define ERR_UNDEFINED_IDENT					12
#define ERR_CANNOT_COMPARE_CHAR 13

#define GT 1
#define LT 2
#define EQ 3
#define NE 4
#define GE 5
#define LE 6

unsigned int globalCounter = 0;
llvm::Function* mainFunction = nullptr; // All code goes in here
llvm::BasicBlock* endif = nullptr; // This is probably bad
bool isConst = false;

%}

%union {
  char* text;
  char ch;
  int num;
  bool boolean;
  TYPE_INFO typeInfo;
};

// Token declarations - N_* for rules, T_* for tokens.
%token      T_LPAREN    T_RPAREN    T_MULT	    T_PLUS
%token      T_COMMA     T_MINUS     T_DOT       T_DOTDOT
%token      T_COLON     T_ASSIGN    T_SCOLON    T_LT
%token      T_LE        T_NE        T_EQ        T_GT
%token      T_GE        T_LBRACK    T_RBRACK    T_DO
%token      T_AND       T_ARRAY     T_BEGIN     T_BOOL
%token      T_CHAR      T_CHARCONST T_DIV 	     T_END       
%token      T_FALSE     T_IDENT	    T_IF        T_INT
%token 	 T_INTCONST 
%token      T_NOT       T_OF        T_OR        T_PROC
%token      T_PROG      T_READ      T_TRUE      
%token      T_VAR       T_WHILE     T_WRITE     T_UNKNOWN

%token      ST_EOF

%type <num> N_IDX T_INTCONST N_ADDOP N_MULTOP N_SIGN N_INTCONST N_RELOP
%type <text> T_IDENT N_IDENT T_CHARCONST
%type <typeInfo> N_ARRAY N_BOOLCONST N_CONST 
%type <typeInfo> N_ENTIREVAR N_ARRAYVAR
%type <typeInfo> N_VARIDENT N_FACTOR N_TERM N_VARIABLE N_INPUTVAR
%type <typeInfo> N_IDXRANGE N_EXPR N_SIMPLE N_SIMPLEEXPR N_TYPE
%type <typeInfo> N_PROCIDENT N_IDXVAR

// Eliminate Ambiguities
%nonassoc   T_THEN
%nonassoc   T_ELSE

// Start Symbol
%start      N_START

// Translation Rules
%%
N_START         : N_PROG
                  {
			        ParseFunctions::printRule("N_START", "N_PROG");
			        return 0;
                  }
                ;
N_ADDOP         : N_ADDOP_LOGICAL
                  {
			  ParseFunctions::printRule("N_ADDOP", "N_ADDOP_LOGICAL");
			  $$ = LOGICAL_OP;
                  }
                | N_ADDOP_ARITH
                  {
			  ParseFunctions::printRule("N_ADDOP", "N_ADDOP_ARITH");
			  $$ = ARITHMETIC_OP;
                  }
                ;
N_ADDOP_LOGICAL : T_OR
			  {
			  ParseFunctions::printRule("N_ADDOP_LOGICAL", "T_OR");
			  }
                ;
N_ADDOP_ARITH   : T_PLUS
			  {
			  ParseFunctions::printRule("N_ADDOP_ARITH", "T_PLUS");
			  }
                | T_MINUS
			  {
			  ParseFunctions::printRule("N_ADDOP_ARITH", "T_MINUS");
			  }
                ;
N_ADDOPLST      : /* epsilon */
			  {
			  ParseFunctions::printRule("N_ADDOPLST", "epsilon");
			  }
                | N_ADDOP N_TERM N_ADDOPLST
			  {
			  ParseFunctions::printRule("N_ADDOPLST", 
			         "N_ADDOP N_TERM N_ADDOPLST");
			  if (($1 == LOGICAL_OP) && ($2.type != BOOL)) 
			  {
			    ParseFunctions::throwError(ERR_EXPR_MUST_BE_BOOL);
			    return(0);
			  }
			  else if (($1 == ARITHMETIC_OP) &&
				      ($2.type != INT)) 
			  {
			    ParseFunctions::throwError(ERR_EXPR_MUST_BE_INT);
			    return(0);
			  }
			  }
                ;
N_ARRAY         : T_ARRAY T_LBRACK N_IDXRANGE T_RBRACK T_OF
			  N_SIMPLE
                  {
                  ParseFunctions::printRule("N_ARRAY",
                	         "T_ARRAY T_LBRACK N_IDXRANGE T_RBRACK T_OF N_SIMPLE");
			  $$.type = ARRAY; 
                	  $$.startIndex = $3.startIndex;
               	  $$.endIndex = $3.endIndex;
		     	  $$.baseType = $6.type;
                  }
                ;
N_ARRAYVAR      : N_ENTIREVAR
                  {
                	  ParseFunctions::printRule("N_ARRAYVAR", "N_ENTIREVAR");
			  $$.type = $1.type; 
                	  $$.startIndex = $1.startIndex;
                	  $$.endIndex = $1.endIndex;
		    	  $$.baseType = $1.baseType;
			  if ($1.type != ARRAY) 
			  {
               	    ParseFunctions::throwError(ERR_INDEX_VAR_MUST_BE_ARRAY);
             	    return(0);
              	  }
                  }
                ;
N_ASSIGN      : N_VARIABLE T_ASSIGN N_EXPR
              {
                ParseFunctions::printRule("N_ASSIGN", "N_VARIABLE T_ASSIGN N_EXPR");
                if ($1.type == ARRAY) {
                    ParseFunctions::throwError(ERR_CANNOT_ASSIGN_TO_ARRAY);
              	    return(0);
                }
			    else if ($1.type == PROCEDURE) {
			        ParseFunctions::throwError(ERR_PROCEDURE_VAR_MISMATCH);
                    return(0);
			    }
			    else if ($3.type != $1.type) {
                    ParseFunctions::throwError(ERR_EXPR_MUST_BE_SAME_AS_VAR);
               	    return(0);
                }
				if (isConst) {
					// The corresponding alloca
                	if ($3.val != nullptr)
                    LLVMGen::Builder.CreateStore($3.val, $1.val);
					isConst = false;
				} else {
					llvm::Value* loaded = LLVMGen::Builder.CreateLoad(llvm::Type::getInt32Ty(LLVMGen::context), $3.val);
					LLVMGen::Builder.CreateStore(loaded, $1.val);
				}
                
              }
              ;
N_BLOCK       : N_VARDECPART N_PROCDECPART N_STMTPART
              {
                ParseFunctions::printRule("N_BLOCK", "N_VARDECPART N_PROCDECPART N_STMTPART");
                ParseFunctions::endScope();
              }
              ;
N_BOOLCONST   : T_TRUE
              {
                ParseFunctions::printRule("N_BOOLCONST", "T_TRUE");
                $$.type = BOOL;
                $$.startIndex = NOT_APPLICABLE;
			    $$.endIndex = NOT_APPLICABLE;
		   	    $$.baseType = NOT_APPLICABLE;
		   	    $$.val = llvm::ConstantInt::get(LLVMGen::context, llvm::APInt(8, 0));
				isConst = true;
              }
              | T_FALSE
              {
                ParseFunctions::printRule("N_BOOLCONST", "T_FALSE");
			    $$.type = BOOL;
                $$.startIndex = NOT_APPLICABLE;
                $$.endIndex = NOT_APPLICABLE;
		        $$.baseType = NOT_APPLICABLE;
		        $$.val = llvm::ConstantInt::get(LLVMGen::context, llvm::APInt(8, 1));
				isConst = true;
              }
              ;
N_COMPOUND    : T_BEGIN N_STMT N_STMTLST T_END
              {
                ParseFunctions::printRule("N_COMPOUND", "T_BEGIN N_STMT N_STMTLST T_END");
              }
              ;
N_CONDITION   : T_IF N_EXPR T_THEN {
				llvm::BasicBlock* tru = llvm::BasicBlock::Create(LLVMGen::context, "iftrue", mainFunction);
				endif = llvm::BasicBlock::Create(LLVMGen::context, "endif", mainFunction);
				LLVMGen::Builder.CreateCondBr($2.val, tru, endif);
				LLVMGen::Builder.SetInsertPoint(tru);
			  } N_STMT
              {
                ParseFunctions::printRule("N_CONDITION", "T_IF N_EXPR T_THEN N_STMT [N_ELS]");
			    if ($2.type != BOOL) {
			        ParseFunctions::throwError(ERR_EXPR_MUST_BE_BOOL);
			        return(0);
			    }
              } N_ELS
              ;
N_ELS         : /* epsilon */ {
				LLVMGen::Builder.CreateBr(endif);
				LLVMGen::Builder.SetInsertPoint(endif);
			  }
              | T_ELSE {
				  llvm::BasicBlock* elsetru = llvm::BasicBlock::Create(LLVMGen::context, "elsetrue", mainFunction);
				  LLVMGen::Builder.SetInsertPoint(elsetru);
			  } N_STMT
			  {
				ParseFunctions::printRule("N_ELS", "T_ELSE N_STMT");
				LLVMGen::Builder.CreateBr(endif);
				LLVMGen::Builder.SetInsertPoint(endif);
			  }
			  ;
N_CONST       : N_INTCONST
              {
                ParseFunctions::printRule("N_CONST", "N_INTCONST");
			    $$.type = INT;
               	$$.startIndex = NOT_APPLICABLE;
              	$$.endIndex = NOT_APPLICABLE;
		    	$$.baseType = NOT_APPLICABLE;
		    	$$.val = llvm::ConstantInt::get(LLVMGen::context, llvm::APInt(32, $1));
				isConst = true;
              }
              | T_CHARCONST
              {
                ParseFunctions::printRule("N_CONST", "T_CHARCONST");
			    $$.type = CHAR;
                $$.startIndex = NOT_APPLICABLE;
               	$$.endIndex = NOT_APPLICABLE;
		     	$$.baseType = NOT_APPLICABLE;
		     	std::string tst = $1;
		     	if (tst == "'\\n'")
		     	    tst = "'\n'";
		     	else if (tst == "'\\t'")
		     	    tst = "'\t'";
		     	//$$.val = PrintSupport::geti8StrVal(tst, tst + std::to_string(globalCounter));
		     	//globalCounter++
		     	$$.val = llvm::ConstantInt::get(LLVMGen::context, llvm::APInt(8, static_cast<int>(tst[1])));
				isConst = true;
              }
              | N_BOOLCONST
              {
                ParseFunctions::printRule("N_CONST", "N_BOOLCONST");
			    $$.type = BOOL;
                $$.startIndex = NOT_APPLICABLE;
            	$$.endIndex = NOT_APPLICABLE;
		     	$$.baseType = NOT_APPLICABLE;
		     	// $$.val is in N_BOOLCONST
              }
              ;
N_ENTIREVAR   : N_VARIDENT
              {
                ParseFunctions::printRule("N_ENTIREVAR", "N_VARIDENT");
                $$.type = $1.type;
                $$.startIndex = $1.startIndex;
                $$.endIndex = $1.endIndex;
                $$.baseType = $1.baseType;
                $$.val = $1.val;
                //std::cout << "Val is " << $$.val->getName().str() << std::endl;
                //std::cout << "Finished with EntireVar" << std::endl;
              }
              ;
N_EXPR        : N_SIMPLEEXPR
              {
                ParseFunctions::printRule("N_EXPR", "N_SIMPLEEXPR");
                $$.type = $1.type;
               	$$.startIndex = $1.startIndex;
               	$$.endIndex = $1.endIndex;
		    	$$.baseType = $1.baseType;
		    	$$.val = $1.val;
              }
              | N_SIMPLEEXPR N_RELOP N_SIMPLEEXPR
              {
                ParseFunctions::printRule("N_EXPR", "N_SIMPLEEXPR N_RELOP N_SIMPLEEXPR");
                if ($1.type != $3.type) {
			        ParseFunctions::throwError(ERR_EXPRS_MUST_BOTH_BE_SAME_TYPE);
			        return 0;
			    }
                $$.type = BOOL;
               	$$.startIndex = NOT_APPLICABLE;
              	$$.endIndex = NOT_APPLICABLE;
		    	$$.baseType = NOT_APPLICABLE;
				if ($1.type == INT || $1.type == BOOL) {
					switch ($2) {
						// LLVM thinks i32* and i32* are different types. I'm out of time to fix this, commenting out.
						case GT:
							//LLVMGen::Builder.CreateICmpUGT($1.val, $3.val);
							break;
						case LT:
							//LLVMGen::Builder.CreateICmpULT($1.val, $3.val);
							break;
						case EQ:
							//LLVMGen::Builder.CreateICmpEQ($1.val, $3.val);
							break;
						case NE:
							//LLVMGen::Builder.CreateICmpNE($1.val, $3.val);
							break;
						case GE:
							//LLVMGen::Builder.CreateICmpUGE($1.val, $3.val);
							break;
						case LE:
							//LLVMGen::Builder.CreateICmpULE($1.val, $3.val);
							break;
					}
				} else if ($1.type == CHAR) {
					ParseFunctions::throwError(ERR_CANNOT_COMPARE_CHAR);
					return 0;
				}
              }
              ;
N_FACTOR      : N_SIGN N_VARIABLE
              {
                ParseFunctions::printRule("N_FACTOR", "N_SIGN N_VARIABLE");
			    if (($1 != NO_SIGN) && ($2.type != INT)) {
			        ParseFunctions::throwError(ERR_EXPR_MUST_BE_INT);
			        return(0);
			    }
      		    $$.type = $2.type;
                $$.startIndex = $2.startIndex;
                $$.endIndex = $2.endIndex;
		   	    $$.baseType = $2.baseType;
		   	    if ($1 == NEGATIVE) {
                    // Subtract the variable from 0, and we get the variable negated!
                    $$.val = LLVMGen::Builder.CreateSub(llvm::ConstantInt::get(LLVMGen::context, llvm::APInt(32, 0)), $2.val);
		   	    } else {
		   	        $$.val = $2.val;
		   	    }
              }
              | N_CONST
              {
                ParseFunctions::printRule("N_FACTOR", "N_CONST");
			    $$.type = $1.type;
                $$.startIndex = $1.startIndex;
                $$.endIndex = $1.endIndex;
		   	    $$.baseType = $1.baseType;
		   	    $$.val = $1.val;
           	  }
              | T_LPAREN N_EXPR T_RPAREN
              {
                ParseFunctions::printRule("N_FACTOR", "T_LPAREN N_EXPR T_RPAREN");
			    $$.type = $2.type;
                $$.startIndex = $2.startIndex;
                $$.endIndex = $2.endIndex;
		   	    $$.baseType = $2.baseType;
		   	    $$.val = $2.val;
              }
              | T_NOT N_FACTOR
              {
                ParseFunctions::printRule("N_FACTOR", "T_NOT N_FACTOR");
			    if ($2.type != BOOL) {
			        ParseFunctions::throwError(ERR_EXPR_MUST_BE_BOOL);
			        return(0);
			    }
			    $$.type = BOOL;
                $$.startIndex = NOT_APPLICABLE;
                $$.endIndex = NOT_APPLICABLE;
                $$.baseType = NOT_APPLICABLE;
                $$.val = $2.val;
              }
              ;
N_IDENT       : T_IDENT
              {
                ParseFunctions::printRule("N_IDENT", "T_IDENT");
                $$ = $1;
              }
              ;
N_IDENTLST      : /* epsilon */
              	  {
              	  ParseFunctions::printRule("N_IDENTLST", "epsilon");
               	  }
                | T_COMMA N_IDENT N_IDENTLST
               	  {
               	  ParseFunctions::printRule("N_IDENTLST", 
                	         "T_COMMA N_IDENT N_IDENTLST");
			  std::string varName = string($2);
			  ParseObj::variableNames.push_front(varName);
              	  }
                ;
N_IDX           : N_INTCONST
              	  {
              	  ParseFunctions::printRule("N_IDX", "N_INTCONST");
               	  $$ = $1;
               	  }
                ;
N_IDXRANGE      : N_IDX T_DOTDOT N_IDX
             	  {
               	  ParseFunctions::printRule("N_IDXRANGE", "N_IDX T_DOTDOT N_IDX");
		     	  $$.type = INDEX_RANGE; 
                	  $$.startIndex = $1;
               	  $$.endIndex = $3;
		    	  $$.baseType = NOT_APPLICABLE;
               	  }
                ;
N_IDXVAR        : N_ARRAYVAR T_LBRACK N_EXPR T_RBRACK
               	  {
               	  ParseFunctions::printRule("N_IDXVAR", 
              	         "N_ARRAYVAR T_LBRACK N_EXPR T_RBRACK");
	    		  if ($3.type != INT) 
			  {
          		    ParseFunctions::throwError(ERR_INDEX_EXPR_MUST_BE_INT);
               	    return(0);
              	  }
			  $$.type = $1.baseType; 
			  $$.startIndex = NOT_APPLICABLE;
			  $$.endIndex = NOT_APPLICABLE;
			  $$.baseType = NOT_APPLICABLE;
              	  }
                ;
N_INPUTLST    : /* epsilon */
			  {
           	  	ParseFunctions::printRule("N_INPUTLST", "epsilon");
			  }
			  | T_COMMA N_INPUTVAR N_INPUTLST
			  {
				ParseFunctions::printRule("N_INPUTLST", "T_COMMA N_INPUTVAR N_INPUTLST");
			  }
              ;
N_INPUTVAR    : N_VARIABLE
			  {
				ParseFunctions::printRule("N_INPUTVAR", "N_VARIABLE");
			  	if (($1.type != INT) && ($1.type != CHAR)) {
					ParseFunctions::throwError(ERR_INPUT_VAR_MUST_BE_INT_OR_CHAR);
              	    return 0;
				}
				$$.type = $1.type; 
				$$.startIndex = $1.startIndex;
				$$.endIndex = $1.endIndex;
				$$.baseType = $1.baseType;
				llvm::ArrayRef<llvm::Value*> ref = { $1.type == CHAR ? PrintSupport::useChar : PrintSupport::useInt, LLVMGen::Builder.CreateIntToPtr($1.val, llvm::Type::getInt32PtrTy(LLVMGen::context)) };
				LLVMGen::Builder.CreateCall(PrintSupport::scanfProto, ref, "readin");
			  }
			  ;
N_INTCONST    : N_SIGN T_INTCONST
              {
                ParseFunctions::printRule("N_INTCONST", "N_SIGN T_INTCONST");
			  	if ($1 == NO_SIGN)
			    	$$ = $2;
			  	else $$ = $1 * $2;
			  }
              ;
N_MULTOP        : N_MULTOP_LOGICAL
             	  {
             	  ParseFunctions::printRule("N_MULTOP", "N_MULTOP_LOGICAL");
			  $$ = LOGICAL_OP;
                	  }
                | N_MULTOP_ARITH
             	  {
             	  ParseFunctions::printRule("N_MULTOP", "N_MULTOP_ARITH");
			  $$ = ARITHMETIC_OP;
              	  }
                ;
N_MULTOP_LOGICAL : T_AND
              	  {
               	  ParseFunctions::printRule("N_MULTOP_LOGICAL", "T_AND");
                	  }
                ;
N_MULTOP_ARITH  : T_MULT
                	  {
                	  ParseFunctions::printRule("N_MULTOP_ARITH", "T_MULT");
               	  }
                | T_DIV
               	  {
                	  ParseFunctions::printRule("N_MULTOP_ARITH", "T_DIV");
                	  }
                ;
N_MULTOPLST     : /* epsilon */
             	  {
              	  ParseFunctions::printRule("N_MULTOPLST", "epsilon");
               	  }
                | N_MULTOP N_FACTOR N_MULTOPLST
              	  {
              	  ParseFunctions::printRule("N_MULTOPLST", 
               	         "N_MULTOP N_FACTOR N_MULTOPLST");
			  if (($1 == LOGICAL_OP) && ($2.type != BOOL))
 			  {
			    ParseFunctions::throwError(ERR_EXPR_MUST_BE_BOOL);
			    return(0);
			  }
			  else if (($1 == ARITHMETIC_OP) &&
			           ($2.type != INT)) 
			  {
			    ParseFunctions::throwError(ERR_EXPR_MUST_BE_INT);
			    return(0);
			  }
             	  }
                ;
N_OUTPUT      : N_EXPR
              {
                ParseFunctions::printRule("N_OUTPUT", "N_EXPR");
                if (($1.type != INT) && ($1.type != CHAR)) {
              	    ParseFunctions::throwError(ERR_OUTPUT_VAR_MUST_BE_INT_OR_CHAR);
             	    return(0);
                }
				llvm::ArrayRef<llvm::Value*> ref;
				if (isConst)
					ref = { ($1.type == CHAR ? PrintSupport::useChar : PrintSupport::useInt), $1.val };
				else {
					llvm::Value* loaded = LLVMGen::Builder.CreateLoad(llvm::Type::getInt32Ty(LLVMGen::context), $1.val);
					ref = { ($1.type == CHAR ? PrintSupport::useChar : PrintSupport::useInt), loaded };
				}
				isConst = false;
				
                LLVMGen::Builder.CreateCall(PrintSupport::printfProto, ref, "writeout");
              }
              ;
N_OUTPUTLST   : /* epsilon */
              {
                ParseFunctions::printRule("N_OUTPUTLST", "epsilon");
              }
              | T_COMMA N_OUTPUT N_OUTPUTLST
             	{
            	ParseFunctions::printRule("N_OUTPUTLST", "T_COMMA N_OUTPUT N_OUTPUTLST");
              }
              ;
N_PROCDEC       : N_PROCHDR N_BLOCK
             	  {
              	  ParseFunctions::printRule("N_PROCDEC", "N_PROCHDR N_BLOCK");
             	  }
                ;
N_PROCHDR       : T_PROC T_IDENT T_SCOLON
             	  {
                	  ParseFunctions::printRule("N_PROCHDR",
			         "T_PROC T_IDENT T_SCOLON");
			  std::string lexeme = string($2);
			  TYPE_INFO info = {PROCEDURE, NOT_APPLICABLE,
		                          NOT_APPLICABLE,
		                          NOT_APPLICABLE};
			  ParseFunctions::printSymbolTableAddition(lexeme, &info);
            	  bool success = ParseObj::scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(lexeme,info));
             	  if (! success) {
            	    ParseFunctions::throwError(ERR_MULTIPLY_DEFINED_IDENT);
               	    return(0);
               	  }

			  ParseFunctions::beginScope();
                  }
                ;
N_PROCDECPART   : /* epsilon */
             	  {
               	  ParseFunctions::printRule("N_PROCDECPART", "epsilon");
               	  }
                | N_PROCDEC T_SCOLON N_PROCDECPART
               	  {
               	  ParseFunctions::printRule("N_PROCDECPART",
               	         "N_PROCDEC T_SCOLON N_PROCDECPART");
              	  }
                ;
N_PROCIDENT     : T_IDENT
              	  {
              	  ParseFunctions::printRule("N_PROCIDENT", "T_IDENT");
			  string ident = string($1);
                	  TYPE_INFO typeInfo = 
			              ParseFunctions::findEntryInAnyScope(ident);
               	  if (typeInfo.type == UNDEFINED) 
			  {
                	    ParseFunctions::throwError(ERR_MULTIPLY_DEFINED_IDENT);
                	    return(0);
               	  }
			  $$.type = typeInfo.type;
			  $$.startIndex = typeInfo.startIndex;
			  $$.endIndex = typeInfo.endIndex;
			  $$.baseType = typeInfo.baseType;
               	  }
                ;
N_PROCSTMT      : N_PROCIDENT
               	  {
               	  ParseFunctions::printRule("N_PROCSTMT", "N_PROCIDENT");
			  if ($1.type != PROCEDURE) 
			  {
			    ParseFunctions::throwError(ERR_PROCEDURE_VAR_MISMATCH);
			    return(0);
			  }
              	  }
                ;
N_PROG        : N_PROGLBL T_IDENT T_SCOLON
                {
             	    ParseFunctions::printRule("N_PROG", "N_PROGLBL T_IDENT T_SCOLON N_BLOCK T_DOT");
			        string lexeme = string($2);
			        TYPE_INFO info = { PROGRAM, NOT_APPLICABLE, NOT_APPLICABLE, NOT_APPLICABLE };
			        ParseFunctions::printSymbolTableAddition(lexeme, &info);

			        // IR Generation
                    llvm::FunctionType* funcT = llvm::FunctionType::get(LLVMGen::Builder.getInt32Ty(), false);
                    mainFunction = llvm::Function::Create(funcT, llvm::Function::ExternalLinkage, "main", LLVMGen::module.get());
                    llvm::BasicBlock* mainBlk = llvm::BasicBlock::Create(LLVMGen::context, "entrypoint", mainFunction);
                    LLVMGen::Builder.SetInsertPoint(mainBlk);
               	    bool success = ParseObj::scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(lexeme, info));
               	    ParseObj::scopeStack.top().setScopeFunction(mainFunction);
			    }
			    N_BLOCK T_DOT
		    	{
		    	    LLVMGen::Builder.CreateRet(llvm::ConstantInt::get(LLVMGen::context, llvm::APInt(32, 0)));
		    	}
                ;
N_PROGLBL     : T_PROG
            	{
            	    ParseFunctions::printRule("N_PROGLBL", "T_PROG");
			        ParseFunctions::beginScope();
                }
                ;
N_READ          : T_READ T_LPAREN N_INPUTVAR N_INPUTLST T_RPAREN
              	{
               	  ParseFunctions::printRule("N_READ", "T_READ T_LPAREN N_INPUTVAR N_INPUTLST T_RPAREN");
			    }
                ;
N_RELOP         : T_LT
                {
					$$ = LT;
                  	ParseFunctions::printRule("N_RELOP", "T_LT");
                }
                | T_GT
                {
					$$ = GT;
                  	ParseFunctions::printRule("N_RELOP", "T_GT");
                }
                | T_LE
                {
					$$ = LE;
                  ParseFunctions::printRule("N_RELOP", "T_LE");
                }
                | T_GE
               	{
					$$ = GE;
               	  ParseFunctions::printRule("N_RELOP", "T_GE");
                }
                | T_EQ
               	{
					$$ = EQ;
					ParseFunctions::printRule("N_RELOP", "T_EQ");
				}
                | T_NE
				{
					$$ = NE;
					ParseFunctions::printRule("N_RELOP", "T_NE");
				}
                ;
N_SIGN          : /* epsilon */
              	  {
               	  ParseFunctions::printRule("N_SIGN", "epsilon");
			  $$ = NO_SIGN;
               	  }
                | T_PLUS
               	  {
               	  ParseFunctions::printRule("N_SIGN", "T_PLUS");
			  $$ = POSITIVE;
               	  }
                | T_MINUS
              	  {
               	  ParseFunctions::printRule("N_SIGN", "T_MINUS");
			  $$ = NEGATIVE;
               	  }
                ;
N_SIMPLE        : T_INT
               	  {
               	  ParseFunctions::printRule("N_SIMPLE", "T_INT");
			  $$.type = INT; 
                	  $$.startIndex = NOT_APPLICABLE;
                	  $$.endIndex = NOT_APPLICABLE;
		     	  $$.baseType = NOT_APPLICABLE;
                	  }
                | T_CHAR
                	  {
                	  ParseFunctions::printRule("N_SIMPLE", "T_CHAR");
			  $$.type = CHAR; 
               	  $$.startIndex = NOT_APPLICABLE;
                	  $$.endIndex = NOT_APPLICABLE;
		     	  $$.baseType = NOT_APPLICABLE;
                	  }
                | T_BOOL
               	  {
                	  ParseFunctions::printRule("N_SIMPLE", "T_BOOL");
			  $$.type = BOOL; 
                	  $$.startIndex = NOT_APPLICABLE;
                	  $$.endIndex = NOT_APPLICABLE;
		    	  $$.baseType = NOT_APPLICABLE;
                	  }
                ;
N_SIMPLEEXPR  : N_TERM N_ADDOPLST
              {
                ParseFunctions::printRule("N_SIMPLEEXPR", "N_TERM N_ADDOPLST");
			    $$.type = $1.type;
                $$.startIndex = $1.startIndex;
                $$.endIndex = $1.endIndex;
                $$.baseType = $1.baseType;
                $$.val = $1.val;
              }
              ;
N_STMT        : N_ASSIGN
              {
                ParseFunctions::printRule("N_STMT", "N_ASSIGN");
              }
              | N_PROCSTMT
              {
                ParseFunctions::printRule("N_STMT", "N_PROCSTMT");
              }
                | N_READ
                	  {
                	  ParseFunctions::printRule("N_STMT", "N_READ");
                	  }
                | N_WRITE
               	  {
                	  ParseFunctions::printRule("N_STMT", "N_WRITE");
                	  }
                | N_CONDITION
               	  {
                	  ParseFunctions::printRule("N_STMT", "N_CONDITION");
                	  }
                | N_WHILE
               	  {
                	  ParseFunctions::printRule("N_STMT", "N_WHILE");
                	  }
                | N_COMPOUND
               	  {
                	  ParseFunctions::printRule("N_STMT", "N_COMPOUND");
                	  }
                ;
N_STMTLST       : /* epsilon */
               	  {
                	  ParseFunctions::printRule("N_STMTLST", "epsilon");
                	  }
                | T_SCOLON N_STMT N_STMTLST
                	  {
                   ParseFunctions::printRule("N_STMTLST", 
			          "T_SCOLON N_STMT N_STMTLST");
               	  }
                ;
N_STMTPART      : N_COMPOUND
			  {
              	  ParseFunctions::printRule("N_STMTPART", "N_COMPOUND");
               	  }
                ;
N_TERM        : N_FACTOR N_MULTOPLST
              {
                ParseFunctions::printRule("N_TERM", "N_FACTOR N_MULTOPLST");
			    $$.type = $1.type;
                $$.startIndex = $1.startIndex;
                $$.endIndex = $1.endIndex;
                $$.baseType = $1.baseType;
                $$.val = $1.val;
              }
              ;
N_TYPE        : N_SIMPLE
              {
                ParseFunctions::printRule("N_TYPE", "N_SIMPLE");
                $$.type = $1.type;
                $$.startIndex = $1.startIndex;
                $$.endIndex = $1.endIndex;
                $$.baseType = $1.baseType;
                $$.val = $1.val;
              }
              | N_ARRAY
              {
                ParseFunctions::printRule("N_TYPE", "N_ARRAY");
                $$.type = $1.type;
                $$.startIndex = $1.startIndex;
                $$.endIndex = $1.endIndex;
                $$.baseType = $1.baseType;
              }
              ;
N_VARDEC      : N_IDENT N_IDENTLST T_COLON N_TYPE
              {
                ParseFunctions::printRule("N_VARDEC", "N_IDENT N_IDENTLST T_COLON N_TYPE");
			    string varName = string($1);
			    ParseObj::variableNames.push_front(varName);
			    for (std::list<string>::iterator it = ParseObj::variableNames.begin(); it != ParseObj::variableNames.end(); it++) {
			        string varName = string(*it);
			        ParseFunctions::printSymbolTableAddition(varName, &$4);
			        $4.val = LLVMGen::createAlloc(ParseObj::scopeStack.top().getScopeFunction(), $4.type, varName);
             	    bool success = ParseObj::scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(varName, $4));
              	    if (!success) {
               	        ParseFunctions::throwError(ERR_MULTIPLY_DEFINED_IDENT);
             	        return(0);
               	    }
               	    if ($4.type == ARRAY && $4.startIndex > $4.endIndex) {
             	        ParseFunctions::throwError(ERR_START_INDEX_MUST_BE_LE_END_INDEX);
                        return(0);
                    }
			    }
                ParseObj::variableNames.clear();
              }
              ;
N_VARDECLST   : /* epsilon */
              {
                ParseFunctions::printRule("N_VARDECLST", "epsilon");
              }
              | N_VARDEC T_SCOLON N_VARDECLST
              {
                ParseFunctions::printRule("N_VARDECLST", "N_VARDEC T_SCOLON N_VARDECLST");
              }
              ;
N_VARDECPART  : /* epsilon */
              {
                ParseFunctions::printRule("N_VARDECPART", "epsilon");
              }
              | T_VAR N_VARDEC T_SCOLON N_VARDECLST
              {
                ParseFunctions::printRule("N_VARDECPART", "T_VAR N_VARDEC T_SCOLON N_VARDECLST");
              }
              ;
N_VARIABLE    : N_ENTIREVAR
              {
                //std::cout << "At N_VARIABLE" << std::endl;
                ParseFunctions::printRule("N_VARIABLE", "N_ENTIREVAR");
			    $$.type = $1.type;
			    $$.startIndex = $1.startIndex;
			    $$.endIndex = $1.endIndex;
			    $$.baseType = $1.baseType;
			    $$.val = $1.val;
              }
              | N_IDXVAR
              {
                ParseFunctions::printRule("N_VARIABLE", "N_IDXVAR");
			    $$.type = $1.type;
			    $$.startIndex = $1.startIndex;
			    $$.endIndex = $1.endIndex;
			    $$.baseType = $1.baseType;
			    $$.val = $1.val;
              }
              ;
N_VARIDENT    : T_IDENT
              {
                ParseFunctions::printRule("N_VARIDENT", "T_IDENT");
			    string ident = string($1);
                TYPE_INFO typeInfo = ParseFunctions::findEntryInAnyScope(ident);
                if (typeInfo.type == UNDEFINED) {
                    ParseFunctions::throwError(ERR_UNDEFINED_IDENT);
             	    return(0);
                }
			    if (typeInfo.type == PROCEDURE) {
			        ParseFunctions::throwError(ERR_PROCEDURE_VAR_MISMATCH);
                    return(0);
			    }
			    $$.type = typeInfo.type;
			    $$.startIndex = typeInfo.startIndex;
			    $$.endIndex = typeInfo.endIndex;
			    $$.baseType = typeInfo.baseType;
			    $$.val = typeInfo.val;
			  }
              ;
N_WHILE       : T_WHILE N_EXPR
              {
                ParseFunctions::printRule("N_WHILE", "T_WHILE N_EXPR T_DO N_STMT");
                if ($2.type != BOOL) {
			        ParseFunctions::throwError(ERR_EXPR_MUST_BE_BOOL);
			        return(0);
                }
              }
			  T_DO N_STMT
			  { }
              ;
N_WRITE       : T_WRITE T_LPAREN N_OUTPUT N_OUTPUTLST T_RPAREN
              {
                ParseFunctions::printRule("N_WRITE", "T_WRITE T_LPAREN N_OUTPUT N_OUTPUTLST T_RPAREN");
                // The write call is in N_OUTPUT
              }
              ;
%%
