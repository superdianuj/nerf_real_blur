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

mkdir specified_images
cp -r scene/images/* specified_images
python run_nerf.py --config configs/demo_blurball.txt


