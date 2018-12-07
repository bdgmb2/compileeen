#!/bin/bash

../../build/CompilEEEN test.mipl -o test
retCode=0

if [ $? -ne 0 ]; then
    exit 1
fi

if [ -f input.txt ]; then
    ./test < input.txt > out.txt
else
    ./test > out.txt
fi
diff -Z out.txt expected.txt
retCode=$?
rm test out.txt

exit $retCode