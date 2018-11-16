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
#include "parsefunctions.h"
#include "gen-parser.h"
#include "gen-lexer.h"

int main() {
    // loop as long as there is anything to parse
    do {
        yyparse();
    } while (!feof(yyin));

    ParseFunctions::cleanUp();
    return 0;
}