Anchored Neighborhood Regression for Fast Example-Based Super-Resolution
========================================================================

Please cite:
------------
Radu Timofte, Vincent De Smet, Luc Van Gool:
Anchored Neighborhood Regression for Fast Example-Based Super-Resolution, (ICCV) 2013.

The source codes are freely available for research and study purposes. Enjoy!

Codes written & compiled by:
----------------------------
Radu Timofte
Computer Vision Lab
ETH Zurich, Switzerland
radu.timofte@vision.ee.ethz.ch
http://www.vision.ee.ethz.ch/~timofter/

Packages and codes included and/or adapted:
-------------------------------------------
* Codes by Roman Zeyde are the basis of ours, are used for
training the dictionaries and feature representation
[http://www.cs.technion.ac.il/~elad/Various/Single_Image_SR.zip]

* OMPBox v9+ and KSVDBox v12+ by Ron Rubinstein are used 
for dictionary training and sparse coding in Roman Zeyde's code.
[http://www.cs.technion.ac.il/~ronrubin/software.html]

* Training and test files of Yang et al.'s Super Resolution algorithm.
(Image Super-resolution as Sparse Representation of Raw Image Patches, (CVPR) 2008.
[CVPR08-SR/]

Usage
-----
>> go_run_upscaling_experiment; % demo running one experiment setting using an magnification factor and set of images

>> go_run_Set14;   % demo running the magnification x3 experiment on Set14 -- results in Table 1 from our ICCV2013 paper
>> go_run_Set5_x2; % demo running the magnification x2 experiment on Set5 -- Table 2 from our ICCV2013 paper
>> go_run_Set5_x3; % demo running the magnification x3 experiment on Set5 -- Table 2 from our ICCV2013 paper
>> go_run_Set5_x4; % demo running the magnification x4 experiment on Set5 -- Table 2 from our ICCV2013 paper

Written
-------
30.03.2013, Radu Timofte @ KU Leuven

Revised versions
----------------
03.10.2013, Radu Timofte @ ETH Zurich