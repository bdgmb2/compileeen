/*    ______                      _ _____________________   __
     / ____/___  ____ ___  ____  (_) / ____/ ____/ ____/ | / /
    / /   / __ \/ __ `__ \/ __ \/ / / __/ / __/ / __/ /  |/ /
   / /___/ /_/ / / / / / / /_/ / / / /___/ /___/ /___/ /|  /
   \____/\____/_/ /_/ /_/ .___/_/_/_____/_____/_____/_/ |_/
                       /_/

   FLEX Specification file for the MIPL (Mini-Pascal) Language
   This file specifies valid and invalid tokens in the MIPL language.
   ------------------------------------------------------------
   Benjamin Giles, CS5500
*/

/*
 *	Constant definitions are now in leopoldj.y
 */
%{
    #include "parsefunctions.h"
    #include "gen-parser.h"
%}

/*
 *	Definitions of regular expressions
 */
QUOTE			'
UNDERSCORE		_

WSPACE		[ \t\r]+
NEWLINE          \n

SIGN			[+-]
COUNT_DIGIT	[1-9]
DIGIT			0|{COUNT_DIGIT}

LO_ALPHA		[a-z]
HI_ALPHA		[A-Z]
ALPHA			{LO_ALPHA}|{HI_ALPHA}

ALPHANUM		{ALPHA}|{DIGIT}

VALIDINT		(0*{COUNT_DIGIT}{DIGIT}{0,8})|(0*)
MAYBEINT		0*{COUNT_DIGIT}{DIGIT}{9,9}
INVALINT		0*{COUNT_DIGIT}{DIGIT}*

IDENT			({UNDERSCORE}|{ALPHA})({ALPHANUM}|{UNDERSCORE})*

CHARCONST		{QUOTE}.{QUOTE}
BADCHARCONST	{QUOTE}|{QUOTE}{QUOTE}

/*
 *	Tokens
 */
%%

"(*"			{
				/* checking for comment; if so, skip it */
				ParseFunctions::ignoreComments();
			}
"("			{
				ParseFunctions::printTokenInfo("T_LPAREN", yytext);
				return T_LPAREN;
			}
")"			{
				ParseFunctions::printTokenInfo("T_RPAREN", yytext);
				return T_RPAREN;
			}
"*"			{
				ParseFunctions::printTokenInfo("T_MULT", yytext);
				return T_MULT;
			}
"+"			{
				ParseFunctions::printTokenInfo("T_PLUS", yytext);
				return T_PLUS;
			}
","			{
				ParseFunctions::printTokenInfo("T_COMMA", yytext);
				return T_COMMA;
			}
"-"			{
				ParseFunctions::printTokenInfo("T_MINUS", yytext);
				return T_MINUS;
			}
".."			{
				ParseFunctions::printTokenInfo("T_DOTDOT", yytext);
				return T_DOTDOT;
			}
"."			{
				ParseFunctions::printTokenInfo("T_DOT", yytext);
				return T_DOT;
			}
":"			{
				ParseFunctions::printTokenInfo("T_COLON", yytext);
				return T_COLON;
			}
":="			{
				ParseFunctions::printTokenInfo("T_ASSIGN", yytext);
				return T_ASSIGN;
			}
";"			{
				ParseFunctions::printTokenInfo("T_SCOLON", yytext);
				return T_SCOLON;
			}
"<"			{
				ParseFunctions::printTokenInfo("T_LT", yytext);
				return T_LT;
			}
"<="			{
				ParseFunctions::printTokenInfo("T_LE", yytext);
				return T_LE;
			}
"<>"			{
				ParseFunctions::printTokenInfo("T_NE", yytext);
				return T_NE;
			}
"="			{
				ParseFunctions::printTokenInfo("T_EQ", yytext);
				return T_EQ;
			}
">"			{
				ParseFunctions::printTokenInfo("T_GT", yytext);
				return T_GT;
			}
">="			{
				ParseFunctions::printTokenInfo("T_GE", yytext);
				return T_GE;
			}
"["			{
				ParseFunctions::printTokenInfo("T_LBRACK", yytext);
				return T_LBRACK;
			}
"]"			{
				ParseFunctions::printTokenInfo("T_RBRACK", yytext);
				return T_RBRACK;
			}
"and"			{
				ParseFunctions::printTokenInfo("T_AND", yytext);
				return T_AND;
			}
"array"		{
				ParseFunctions::printTokenInfo("T_ARRAY", yytext);
				return T_ARRAY;
			}
"begin"		{
				ParseFunctions::printTokenInfo("T_BEGIN", yytext);
				return T_BEGIN;
			}
"boolean"		{
				ParseFunctions::printTokenInfo("T_BOOL", yytext);
				return T_BOOL;
			}
"char"		{
				ParseFunctions::printTokenInfo("T_CHAR", yytext);
				return T_CHAR;
			}
"div"			{
				ParseFunctions::printTokenInfo("T_DIV", yytext);
				return T_DIV;
			}
"do"			{
				ParseFunctions::printTokenInfo("T_DO", yytext);
				return T_DO;
			}
"else"		{
				ParseFunctions::printTokenInfo("T_ELSE", yytext);
				return T_ELSE;
			}
"end"			{
				ParseFunctions::printTokenInfo("T_END", yytext);
				return T_END;
			}
"false"		{
				ParseFunctions::printTokenInfo("T_FALSE", yytext);
				return T_FALSE;
			}
"if"			{
				ParseFunctions::printTokenInfo("T_IF", yytext);
				return T_IF;
			}
"integer"		{
				ParseFunctions::printTokenInfo("T_INT", yytext);
				return T_INT;
			}
"not"			{
				ParseFunctions::printTokenInfo("T_NOT", yytext);
				return T_NOT;
			}
"of"			{
				ParseFunctions::printTokenInfo("T_OF", yytext);
				return T_OF;
			}
"or"			{
				ParseFunctions::printTokenInfo("T_OR", yytext);
				return T_OR;
			}
"procedure"	{
				ParseFunctions::printTokenInfo("T_PROC", yytext);
				return T_PROC;
			}
"program"		{
				ParseFunctions::printTokenInfo("T_PROG", yytext);
				return T_PROG;
			}
"read"		{
				ParseFunctions::printTokenInfo("T_READ", yytext);
				return T_READ;
			}
"then"		{
				ParseFunctions::printTokenInfo("T_THEN", yytext);
				return T_THEN;
			}
"true"		{
				ParseFunctions::printTokenInfo("T_TRUE", yytext);
				return T_TRUE;
			}
"var"			{
				ParseFunctions::printTokenInfo("T_VAR", yytext);
				return T_VAR;
			}
"while"		{
				ParseFunctions::printTokenInfo("T_WHILE", yytext);
				return T_WHILE;
			}
"write"		{
				ParseFunctions::printTokenInfo("T_WRITE", yytext);
				return T_WRITE;
			}
{VALIDINT}		{
				ParseFunctions::printTokenInfo("T_INTCONST", yytext);
                      yylval.num = atoi(yytext);
				return T_INTCONST;
			}
{MAYBEINT}		{
				if (ParseFunctions::checkInteger(yytext))
				{
				printf("**** Invalid integer constant: %s\n", 
				       yytext);
				return T_UNKNOWN;
				}
				else
				{
				ParseFunctions::printTokenInfo("T_INTCONST", yytext);
                      yylval.num = atoi(yytext);
				return T_INTCONST;
				}
			}
{INVALINT}		{
				printf("**** Invalid integer constant: %s\n", 
				       yytext);
				return T_UNKNOWN;
			}
{IDENT}		{
				ParseFunctions::printTokenInfo("T_IDENT", yytext);
                      yylval.text = strdup(yytext);
				return T_IDENT;
			}
{BADCHARCONST}	{
				printf("**** Invalid character constant: %s\n", 
				       yytext);
				return T_UNKNOWN;
			}
{CHARCONST}	{
				ParseFunctions::printTokenInfo("T_CHARCONST", yytext);
                      yylval.ch = yytext[1];
				return T_CHARCONST;
			}
{NEWLINE}   	{
                		++ParseObj::lineNum;
            	}
{WSPACE}		{ }
.			{
				ParseFunctions::printTokenInfo("T_UNKNOWN", yytext);
				return T_UNKNOWN;
			}

%%
