#!/bin/bash

source ~/anaconda3/etc/profile.d/conda.sh

rm -r weighty
rm -r tensy
rm -r specified_images


conda activate torcher
rm -r LLFF/scene
mkdir LLFF/scene
mkdir LLFF/scene/images
cp -r "$1"/* LLFF/scene/images
cd LLFF

python imgs2poses.py scene

cd ..
cp -r LLFF/scene .
cd scene


file=$(find . -type f -name "*hold=*" | head -n 1)
K=$(echo "$file" | grep -oP 'hold=\K\d+')

echo "Found K = $K"

# Create the images_test directory
mkdir -p images_test

# Copy images that meet the condition
for image in images/*.{png,jpg}; do
    if [[ -f "$image" ]]; then
        base_name=$(basename "$image")
        image_number=$(echo "$base_name" | grep -oP '^0*\K\d+(?=\.(?:png|jpg)$)')
        
        if [[ -n "$image_number" && ( "$image_number" -eq 0 || $(( image_number % K )) -eq 0 ) ]]; then
            cp "$image" images_test/
            echo "Copied $image to images_test/ ($image_number is divisible by $K)"
        fi
    fi
done

cd ..

mkdir specified_images
cp -r scene/images/* specified_images


echo "Process completed. Check the 'images_test' directory for copied images."

python train.py --config configs/cozy2room.txt
