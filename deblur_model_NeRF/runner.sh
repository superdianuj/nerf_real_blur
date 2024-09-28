#!/bin/bash

source ~/anaconda3/etc/profile.d/conda.sh

rm -r LLFF/scene
mkdir LLFF/scene
mkdir LLFF/scene/images
cp -r "$1"/* LLFF/scene/images
rm -r "$1"
cd LLFF

python imgs2poses.py scene

cd ..
cp -r LLFF/scene .

mv scene "$1"


rm -rf NAFNet/tobedeblurred
rm -rf Real-ESRGAN/tobedeblurred
mkdir NAFNet/tobedeblurred
mkdir Real-ESRGAN/tobedeblurred
rm -rf Original-NeRF_nafnet/specified_images
rm -rf Original-NeRF_nafnet_realesrgan/specified_images
rm -rf Original-NeRF_realesrgan/specified_images

mkdir Original-NeRF_nafnet/specified_images
mkdir Original-NeRF_nafnet_realesrgan/specified_images
mkdir Original-NeRF_realesrgan/specified_images

cp -r "$1"/images/* Original-NeRF_nafnet/specified_images
cp -r "$1"/images/* Original-NeRF_nafnet_realesrgan/specified_images
cp -r "$1"/images/* Original-NeRF_realesrgan/specified_images

cp -r "$1"/images/* NAFNet/tobedeblurred
cp -r "$1"/images/* Real-ESRGAN/tobedeblurred

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "NAFNet deblurring"
cd NAFNet
conda activate nafnet
python deblur.py --dir tobedeblurred
cd .. 
cp -r NAFNet/tobedeblurred_deblurred_nafnet Real-ESRGAN



cd Real-ESRGAN
echo "Real-ESRGAN deblurring"
conda activate torcher
python deblur.py --dir tobedeblurred_deblurred_nafnet  --gt_dir tobedeblurred
python deblur.py --dir tobedeblurred --gt_dir tobedeblurred
cd ..
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"

cp -r "$1" "$1"_nafnet
cp -r "$1" "$1"_esrgan
cp -r "$1" "$1"_nafnet_esrgan


rm -rf "$1"_nafnet/images/*
rm -rf "$1"_nafnet/images_2/*
rm -rf "$1"_nafnet/images_4/*
rm -rf "$1"_esrgan/images/*
rm -rf "$1"_esrgan/images_2/*
rm -rf "$1"_esrgan/images_4/*
rm -rf "$1"_nafnet_esrgan/images/*
rm -rf "$1"_nafnet_esrgan/images_2/*
rm -rf "$1"_nafnet_esrgan/images_4/*



cp -r Real-ESRGAN/tobedeblurred_deblurred_nafnet_deblurred_esrgan/* "$1"_nafnet_esrgan/images
for img in Real-ESRGAN/tobedeblurred_deblurred_nafnet_deblurred_esrgan/*; do
    convert "$img" -resize 50% "$1"_nafnet_esrgan/images_2/$(basename "$img")
done

for img in Real-ESRGAN/tobedeblurred_deblurred_nafnet_deblurred_esrgan/*; do
    convert "$img" -resize 25% "$1"_nafnet_esrgan/images_4/$(basename "$img")
done



cp -r Real-ESRGAN/tobedeblurred_deblurred_esrgan/* "$1"_esrgan/images
for img in Real-ESRGAN/tobedeblurred_deblurred_esrgan/*; do
    convert "$img" -resize 50% "$1"_esrgan/images_2/$(basename "$img")
done

for img in Real-ESRGAN/tobedeblurred_deblurred_esrgan/*; do
    convert "$img" -resize 25% "$1"_esrgan/images_4/$(basename "$img")
done



cp -r NAFNet/tobedeblurred_deblurred_nafnet/* "$1"_nafnet/images
for img in NAFNet/tobedeblurred_deblurred_nafnet/*; do
    convert "$img" -resize 50% "$1"_nafnet/images_2/$(basename "$img")
done

for img in NAFNet/tobedeblurred_deblurred_nafnet/*; do
    convert "$img" -resize 25% "$1"_nafnet/images_4/$(basename "$img")
done


mv "$1"_nafnet Original-NeRF_nafnet
mv "$1"_esrgan Original-NeRF_realesrgan
mv "$1"_nafnet_esrgan Original-NeRF_nafnet_realesrgan


echo "Running NeRF routine on NAFNet Outputs"
cd Original-NeRF_nafnet
rm -r weighty
rm -r scene
rm -r tensy
mv "$1"_nafnet scene
python run_nerf.py --config configs/demo_blurball.txt


echo "Running NeRF routine on Real-ESRGAN Outputs"
cd Original-NeRF_realesrgan
rm -r weighty
rm -r scene
rm -r tensy
mv "$1"_esrgan scene
python run_nerf.py --config configs/demo_blurball.txt


echo "Running NeRF routine on NAFNet->Real-ESRGAN Outputs"
cd Original-NeRF_nafnet_realesrgan
rm -r weighty
rm -r scene
rm -r tensy
mv "$1"_nafnet_esrgan scene
python run_nerf.py --config configs/demo_blurball.txt