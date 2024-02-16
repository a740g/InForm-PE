#!/bin/bash
# InForm for QB64-PE Setup script

# Check if QB64-PE directory path is provided as an argument
if [ -n "$1" ]; then
    QB64PE_PATHS=("$1" "../qb64pe/" "../QB64pe/")
else
    QB64PE_PATHS=("../QB64pe/" "../qb64pe/")
fi

cd "$(dirname "$0")"

echo "Compiling InForm..."

# Loop through each QB64-PE path
for path in "${QB64PE_PATHS[@]}"; do
    make -f makefile.inform clean OS=lnx QB64PE_PATH="$path"
    make -f makefile.inform OS=lnx QB64PE_PATH="$path"
    if [ $? -eq 0 ]; then
        break  # If build succeeds, exit loop
    fi
    echo "Build failed with QB64-PE path: $path"
done
