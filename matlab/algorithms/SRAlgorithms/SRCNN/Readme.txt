
***********************************************************************************************************
***********************************************************************************************************

Matlab demo code for "Learning a Deep Convolutional Network for Image Super-Resolution" (ECCV 2014) 
and "Image Super-Resolution Using Deep Convolutional Networks" (arXiv:1501.00092)

by Chao Dong (ndc.forward@gmail.com)

If you use/adapt our code in your work (either as a stand-alone tool or as a component of any algorithm),
you need to appropriately cite our ECCV 2014 paper or arXiv paper.

This code is for academic purpose only. Not for commercial/industrial activities.


NOTE:

  The running time reported in the paper is from C++ implementation. This Matlab version is a re-
implementation, and is for the ease of understanding the algorithm. This code is not optimized, and the 
speed is not representative. The result can be slightly different from the paper due to transferring
across platforms.


***********************************************************************************************************
***********************************************************************************************************


Usage:

demo_SR.m - demonstrate super-resolution using SRCNN.m

function:

SRCNN.m - realize super resolution given the model parameters

Folders:

Set5 and Set14 - test images.

Model/9-1-5(91 images) - model parameters of network 9-1-5 trained on 91 images (in the ECCV paper). "x2.mat" "x3.mat" and "x4.mat" are model parameters used for upscaling factors 2,3 and 4 seperately.

Model/9-1-5(ImageNet) - model parameters of network 9-1-5 trained on ImageNet (in the arXiv paper).

Model/9-3-5(ImageNet) - model parameters of network 9-3-5 trained on ImageNet (in the arXiv paper).

Model/9-5-5(ImageNet) - model parameters of network 9-5-5 trained on ImageNet (in the arXiv paper).