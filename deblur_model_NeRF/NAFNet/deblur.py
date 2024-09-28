import os
os.environ["CUDA_VISIBLE_DEVICES"] = "1"


fold=7
import warnings
warnings.filterwarnings("ignore")

import numpy
import argparse
import cv2
import torch

from basicsr.models import create_model
from basicsr.utils import img2tensor as _img2tensor, tensor2img, imwrite
from basicsr.utils.options import parse
import numpy as np
import cv2
import imageio.v2 as imageio
from blurgenerator import motion_blur,lens_blur, gaussian_blur

os.environ['MKL_THREADING_LAYER'] = 'GNU'


parser=argparse.ArgumentParser()
parser.add_argument('--dir',required=True,type=str)
# parser.add_argument('--gt_dir',required=True,type=str)
args=parser.parse_args()

dirr=args.dir
# gt_dir=args.gt_dir


if os.path.exists('resized'):
    os.system('rm -rf resized')
os.system('mkdir resized')

if os.path.exists('deblur_output'):
    os.system('rm -rf deblur_output')

os.system('mkdir deblur_output')

img_names=sorted(os.listdir(dirr),key=lambda x: int(x.split('_')[-1].split('.')[0]) if '_' in x else int(x.split('.')[0]))

count=0
for img_nam in img_names:
    img_path=os.path.join(dirr,img_nam)
    img=cv2.imread(img_path)
    # img_resized=cv2.resize(img,(256,256))
    num_img=int(img_nam.split('.')[0].split('_')[-1]) if '_' in img_nam else int(img_nam.split('.')[0])
    if num_img%fold==0:
        cv2.imwrite(f'resized/{img_nam}',img)
        continue
    else:
        size=5
        gaussian_blurred=gaussian_blur(img,size)
        cv2.imwrite(f'resized/{img_nam}',gaussian_blurred)
    count+=1


paths=sorted(os.listdir('resized'),key=lambda x: int(x.split('_')[-1].split('.')[0]) if '_' in x else int(x.split('.')[0]))


output_dir=args.dir+'_deblurred_nafnet'
if os.path.exists(output_dir):
    os.system(f'rm -rf {output_dir}')
os.system(f'mkdir {output_dir}')

print("Deblurring images using NAFNet...")
for pth in paths:
    num_img=int(pth.split('.')[0].split('_')[-1]) if '_' in pth else int(pth.split('.')[0])
    if num_img%fold==0:
        # replace the output image with the input image
        os.system(f'cp -r resized/{pth} {output_dir}/{pth}')
    else:
        input_path=os.path.join('resized',pth)
        
        os.system(f'python basicsr/demo.py -opt options/test/REDS/NAFNet-width64.yml --input_path {input_path} --output_path {output_dir}/{pth}')

print("Computing metrics for deblurring...")
# os.system(f'python compute_metrics.py --gt_dir {gt_dir} --target_dir {output_dir}')


if not os.path.exists('GIF'):
    os.system('mkdir GIF')

def gifer(out_directory,gif_name,fps=10):
    if os.path.exists(gif_name):
        os.system(f'rm -rf {gif_name}')
    
    print("Current Directory:",out_directory)
    img_list=os.listdir(out_directory)
    img_list=[img for img in img_list if img.endswith('.png') or img.endswith('.jpg') or img.endswith('.JPG')]
    images=sorted(img_list,key=lambda x:int(x.split('_')[-1].split('.')[0]) if '_' in x else int(x.split('.')[0]))

    images=[os.path.join(out_directory,img_name) for img_name in images]
    
    gif=[]

    for img in images:
        gif.append(imageio.imread(img))

    imageio.mimsave(gif_name,gif,fps=fps)
    print(f"--> Saved {gif_name}.")


gifer(output_dir,'GIF/'+output_dir+'.gif',fps=10)
