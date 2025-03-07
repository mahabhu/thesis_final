#!/bin/bash

# g++ fix.cpp -o process_dot 
./process_dot $1 $1"new.dot"
dot -Tpdf -Gratio=1.0 -o $1"new.pdf" $1"new.dot" 