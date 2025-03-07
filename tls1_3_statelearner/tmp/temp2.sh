#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <hexstring>"
  exit 1
fi

# Store the hex string argument
HEX_STRING=$1

# Convert the hex string to binary
echo "$HEX_STRING" | xxd -r -p > binaryinput.bin

# Generate the SHA-384 hash
HASH=$(openssl dgst -sha384 binaryinput.bin | awk '{print $2}')

# Clean up the binary file
rm binaryinput.bin

# Output the hash
echo $HASH
