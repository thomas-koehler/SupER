SSEQ Software release.

=======================================================================
-----------COPYRIGHT NOTICE STARTS WITH THIS LINE------------
Copyright (c) 2014 Beijing Institude of Technology and The University of Texas at Austin
All rights reserved.

Permission is hereby granted, without written agreement and without license or royalty fees, to use, copy, 
modify, and distribute this code (the source files) and its documentation for
any purpose, provided that the copyright notice in its entirety appear in all copies of this code, and the 
original source of this code, Laboratory for Image and Video Engineering (LIVE, http://live.ece.utexas.edu)
and Center for Perceptual Systems (CPS, http://www.cps.utexas.edu) at the University of Texas at Austin (UT Austin, 
http://www.utexas.edu), is acknowledged in any publication that reports research using this code. The research
is to be cited in the bibliography as:

1)  Lixiong Liu, Bao Liu, Hua Huang, and Alan Conrad Bovik, "No-reference Image Quality Assessment Based on Spatial and Spectral Entropies", 
    Signal Processing: Image Communication, Vol. 29, No. 8, pp. 856-863, Sep. 2014.

2)  Lixiong Liu, Bao Liu, Hua Huang, and Alan Conrad Bovik, "SSEQ Software Release", 
    URL: http://live.ece.utexas.edu/research/quality/SSEQ_release.zip, 2014

IN NO EVENT SHALL THE UNIVERSITY OF TEXAS AT AUSTIN BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, 
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF THIS DATABASE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF TEXAS
AT AUSTIN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE UNIVERSITY OF TEXAS AT AUSTIN SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE DATABASE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
AND THE UNIVERSITY OF TEXAS AT AUSTIN HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

-----------COPYRIGHT NOTICE ENDS WITH THIS LINE------------%

=======================================================================
Author  : Lixiong Liu
Version : 1.0

The authors are with the School of School of Computer Science and Technology, Beijing Institute of Technology, Beijing 100081, China

Kindly report any suggestions or corrections to lxliu@bit.edu.cn

=======================================================================

This is a demonstration of the Spatial¨CSpectral Entropy-based Quality (SSEQ) index. The algorithm is described in:

Lixiong Liu, Bao Liu, Hua Huang, and Alan Conrad Bovik. No-reference Image Quality Assessment Based on Spatial and Spectral Entropies, 
Signal Processing: Image Communication, 29(8), 2014. 856-863.

You can change this program as you like and use it anywhere, but please
refer to its original source (cite our paper and our web page at
http://live.ece.utexas.edu/research/quality/SSEQ_release.zip, 2014).

========================================================================

Running on Matlab 

Input : A test image loaded in an array

Output: A quality score of the image. The score typically has a value
        between 0 and 100 (0 represents the best quality, 100 the worst).
  
Usage:

%1. Load the image, for example
    image        = imread('bikes.bmp');

%2. Call this function to calculate the quality score:
    qualityscore = SSEQ(image)

Dependencies: 

LibSVM package: 
    C.C. Chang, C.J. Lin. LIBSVM: a library for support vector machines. Available from: 
    ¡´http://www.csie.ntu.edu.tw/~cjlin/libsvm/¡µ, 2001.

MATLAB files: 
    SSEQ.m, SSQA_by_f.m, feature_extract.m, setscale.m, fecal.m, secal.m (provided with release)

Model files:
    model.mat (provided with release)

Image Files: 
    img.bmp (provided with release)

Example files:
    example.m (provided with release)

NOTE: Please download the LibSVM package and add the LibSVM path to MATLAB path.

========================================================================

Note on training: 
This release version of SSEQ was trained on the entire LIVE database.

====================================================================

This program uses LibSVM package.

1)  Chih-Chung Chang and Chih-Jen Lin, LIBSVM : a library for support vector machines. 
    ACM Transactions on Intelligent Systems and Technology, 2:27:1--27:27, 2011. 
    Software available at http://www.csie.ntu.edu.tw/~cjlin/libsvm

2)  LIBSVM implementation document is available at http://www.csie.ntu.edu.tw/~cjlin/papers/libsvm.pdf

====================================================================

