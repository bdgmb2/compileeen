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

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <map>
#include <string>

#define UNDEFINED  			-1   // Type codes
#define PROCEDURE			0
#define INT				1
#define CHAR				2
#define INT_OR_CHAR			3
#define BOOL				4
#define INT_OR_BOOL			5
#define CHAR_OR_BOOL			6
#define INT_OR_CHAR_OR_BOOL		7
#define ARRAY				8
#define INDEX_RANGE			9
#define PROGRAM				10

#define NOT_APPLICABLE 		-1

typedef struct {
    int type;        // one of the above type codes
    int startIndex;  // if array, starting index
    int endIndex;    //           ending index
    int baseType;    //           base type (one of above codes)
} TYPE_INFO;

class SYMBOL_TABLE_ENTRY {
private:
    // Member variables
    std::string name;
    TYPE_INFO typeInfo;

public:
    // Constructors
    SYMBOL_TABLE_ENTRY() {
        name = "";
        typeInfo.type = UNDEFINED;
        typeInfo.startIndex = UNDEFINED;
        typeInfo.endIndex = UNDEFINED;
        typeInfo.baseType = UNDEFINED;
    }

    SYMBOL_TABLE_ENTRY(const std::string theName, const int theType, const int theStart, const int theEnd,
        const int theBaseType) {
        name = theName;
        typeInfo.type = theType;
        typeInfo.startIndex = theStart;
        typeInfo.endIndex = theEnd;
        typeInfo.baseType = theBaseType;
    }

    SYMBOL_TABLE_ENTRY(const std::string theName, const TYPE_INFO info) {
        name = theName;
        typeInfo.type = info.type;
        typeInfo.startIndex = info.startIndex;
        typeInfo.endIndex = info.endIndex;
        typeInfo.baseType = info.baseType;
    }

    // Accessors
    std::string getName() const;
    TYPE_INFO getTypeInfo() const;
    int getTypeCode() const;
    int getStartIndex() const;
    int getEndIndex() const;
    int getBaseType() const;
};


class SYMBOL_TABLE {
private:
  std::map<std::string, SYMBOL_TABLE_ENTRY> hashTable;

public:

  SYMBOL_TABLE() = default;

  // Add SYMBOL_TABLE_ENTRY x to this symbol table.
  // If successful, return true; otherwise, return false.
  bool addEntry(SYMBOL_TABLE_ENTRY x);

  // If a symbol table entry with name theName is
  // found in this symbol table, then return its token type
  // info; otherwise, return token info with type UNDEFINED.
  TYPE_INFO findEntry(const std::string & theName);

};

#endif  // SYMBOL_TABLE_H
