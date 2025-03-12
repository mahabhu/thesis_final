#!/bin/bash

# Define the input and output directories
INPUT_DIR="./TLS12 client"  # Directory containing the input files
OUTPUT_DIR="./TLS12 new client"  # Directory where output files will be saved

# Define the Python script to run
PYTHON_SCRIPT="processdotFile.py"

# Check if the input directory exists
if [ ! -d "$INPUT_DIR" ]; then
  echo "Input directory $INPUT_DIR does not exist."
  exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Iterate over all files in the input directory
for file in "$INPUT_DIR"/*; do
  if [ -f "$file" ]; then
    # Extract the filename from the full path
    filename=$(basename "$file")
    # Define the output file path
    output_file="$OUTPUT_DIR/$filename"
    echo "Processing file: $file"
    # Run the Python script and direct output to the corresponding file in OUTPUT_DIR
    python3 "$PYTHON_SCRIPT" "$file" "$output_file"
  else
    echo "$file is not a regular file. Skipping."
  fi
done

echo "All files have been processed."
