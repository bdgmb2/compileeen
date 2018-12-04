cmake_minimum_required(VERSION 3.8)
project(CompilEEEN CXX)

set(CMAKE_CXX_STANDARD 14)

# FLEX / BISON
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/genheaders)
BISON_TARGET(MIPLParser ${CMAKE_SOURCE_DIR}/src/parse/mipl.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/genheaders/gen-parser.h)
FLEX_TARGET(MIPLLexer ${CMAKE_SOURCE_DIR}/src/parse/mipl.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/genheaders/gen-lexer.h)
ADD_FLEX_BISON_DEPENDENCY(MIPLLexer MIPLParser)

# HEADER FILES
include_directories(${CMAKE_SOURCE_DIR}/src)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/genheaders)

# LLVM
find_package(LLVM REQUIRED CONFIG)
MESSAGE(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

# COMPILER
file(GLOB_RECURSE SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_executable(CompilEEEN ${SRCS} ${BISON_MIPLParser_OUTPUTS} ${FLEX_MIPLLexer_OUTPUTS} src/ilgen/ilgen.h src/ilgen/ilgen.cpp src/config.cpp)
target_link_libraries(CompilEEEN "-lLLVM-6.0 -lz -lpthread")