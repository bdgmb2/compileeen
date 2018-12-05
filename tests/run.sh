#!/bin/bash

../../build/CompilEEEN test.mipl -o test
retCode=0

if [ $? -ne 0 ]; then
    exit 1
fi

./test > out.txt
diff -Z out.txt expected.txt
retCode=$?
rm test out.txt

exit $retCode