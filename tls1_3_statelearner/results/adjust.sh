#!/bin/bash


# Loop over all items in the current directory
for item in *; do
  # Check if the item is a directory
  if [ -d "$item" ]; then
    # Check if the directory contains the file learnedModel.dot
    if [ ! -f "$item/learnedModel.dot" ]; then
      # Print the name of the directory if the file is not found
        ./cleaner.sh $item/hypothesis_1.dot
        cp $item/hypothesis_1.dotnew.pdf results/$item.pdf
    else
        ./cleaner.sh $item/learnedModel.dot
        cp $item/learnedModel.dotnew.pdf results/$item.pdf
    fi
  fi
done
