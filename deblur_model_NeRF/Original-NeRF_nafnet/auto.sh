#!/bin/bash

source ~/anaconda3/etc/profile.d/conda.sh

rm -r weighty
rm -r scene
rm -r tensy
rm -r specified_images
rm -r LLFF/scene
mkdir LLFF/scene
mkdir LLFF/scene/images
cp -r "$1/*" "LLFF/scene/images"
mkdir specified_images
cp -r "$1/*" "specified_images"
cd LLFF && python imgs2poses.py scene && cd ..
mv LLFF/scene .
conda activate deblur_nerf
python run_nerf.py --config configs/demo_blurball.txt


