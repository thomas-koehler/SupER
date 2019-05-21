*************************************************************************
Video Super-Resolution with Convolutional Neural Networks

If you use this code, please cite the following publication:
    A.Kappeler, S.Yoo, Q.Dai, A.K.Katsaggelos, "Video Super-Resolution 
    with Convolutional Neural Networks", to appear in IEEE Transactions
    on Computational Imaging

Installation Instructions: 
1) install Caffe from "http://caffe.berkeleyvision.org/"
2) run the following command in Matlab:
      cd external_functions/CLG-TV-matlab
      mex applyBilateralFilterToDataTerms.cpp
      cd ../..
2) specify the CAFFEPATH on line 53 in VSRnet_demo.m
3) set the experiment you want to execute to "true" (only one at the time) 

 
Version 1.0

Created by:   Armin Kappeler
Date:         02/19/2016

http://ivpl.eecs.northwestern.edu/software

*************************************************************************

Because of the data size, we only provide a subset of our videos on the
website. For additional testvideos and our training database, please
contact us directly.

*************************************************************************
Copyright (C) 2016 Armin Kappeler

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

For a copy of the GNU General Public License,
please see <http://www.gnu.org/licenses/>. 
 
*************************************************************************
