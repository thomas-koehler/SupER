%%%%%%%%%%%%%%% COPYRIGHT AND CONFIDENTIALITY INFORMATION %%%%%%%%%%%%%%%
%%%                                                                   %%%
%%% Copyright (c) 2015 DEUTSCHE THOMSON OHG - A Technicolor's Company %%%
%%% All Rights Reserved                                               %%%
%%%                                                                   %%%
%%% This program contains proprietary information which is a trade    %%%
%%% secret of DTO and/or its affiliates and also is protected as      %%%
%%% under applicable Copyright laws. Recipient is                     %%%
%%% not permitted to use or make copies thereof other than as         %%%
%%% permitted in a written agreement with DTO or its affiliates,      %%%
%%% UNLESS OTHERWISE EXPRESSLY ALLOWED BY APPLICABLE LAWS.            %%%
%%%                                                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Your use of the Software is subject to the terms and conditions set forth
in the license Agreement available at jordisalvador-image.blogspot.de.
By installing, using, accessing or copying the Software, you hereby
irrevocably accept the terms and conditions of this license Agreement. If
you do not accept all or parts of the terms and conditions of this
Agreement you cannot install, use, access nor copy the Software.




* Publication/communication *********************************************

A copy of any written publication or a summary of any communication
resulting from the use of the Software shall be sent to Technicolor at
the address stated at article 10.5 (license Agreement) as soon as
possible.

In any publication and on any support joined to an oral communication
(for instance a PowerPoint document) resulting from the use of the
Software, the following statement shall be inserted:

NBSRF is a DEUTSCHE THOMSON OHG -a company of Technicolor's Group-product

And in any publication, the latest publication about the software shall
be properly cited. The latest publication currently is: 

Salvador, J. and Pérez-Pellitero, E., "Naive Bayes Super-Resolution
Forest," in Proc. IEEE Int. Conf. on Computer Vision, 2015

In any oral communication resulting from the use of the Software, the
Licensee shall orally indicate that the Software is Technicolor's
property.




* Platform and support **************************************************

The current version of NBSRF has been compiled with OpenMP support
for both Linux and Windows(R) 64-bit environments. May the supplied
binaries not work with your setup, please contact Jordi Salvador
(jordi.salvador@technicolor.com).

The software uses MATLAB's Image Processing Toolbox.




* Quick start ***********************************************************

You just need to call the script run_nbsrf.m from MATLAB(R). The expected
output is:

  Your use of the Software is subject to the terms and conditions set
  forth in the license Agreement available at
  http://jordisalvador-image.blogspot.de/.
  By installing, using, accessing or copying the Software, you hereby
  irrevocably accept the terms and conditions of this license Agreement.
  If you do not accept all or parts of the terms and conditions of this
  Agreement you cannot install, use, access nor copy the Software.

  Loading .../trees_x2_ibp_2048_n16.mat
  Loading .../regs_x2_ibp_2048_n16_nt16_ns1500.mat
  baboon.bmp   PSNR 25.68 dB   Time 0.126 s
  barbara.bmp   PSNR 28.55 dB   Time 0.106 s
  bridge.bmp   PSNR 27.80 dB   Time 0.062 s
  coastguard.bmp   PSNR 30.74 dB   Time 0.027 s
  comic.bmp   PSNR 28.59 dB   Time 0.027 s
  face.bmp   PSNR 35.77 dB   Time 0.021 s
  flowers.bmp   PSNR 33.20 dB   Time 0.042 s
  foreman.bmp   PSNR 37.03 dB   Time 0.026 s
  lenna.bmp   PSNR 36.68 dB   Time 0.059 s
  man.bmp   PSNR 30.93 dB   Time 0.102 s
  monarch.bmp   PSNR 37.70 dB   Time 0.084 s
  pepper.bmp   PSNR 37.00 dB   Time 0.059 s
  ppt3.bmp   PSNR 30.72 dB   Time 0.060 s
  zebra.bmp   PSNR 33.92 dB   Time 0.053 s

  Average PSNR 32.45 dB   Average time 0.061 s

Note that the time will vary with the computational power of your work-
station, but the PSNR values should match the ones listed above. The
resulting images are also written to disk under the results subfolder.




* Extended usage ********************************************************

By inspecting the script run_nbsrf.m, you will find that the default
configuration can be easily changed. Here we list the most relevant
parameters:

- Upscaling factor (integer value 2, 3 or 4)
	setup.scaling
- Number of leaves per tree (power of 2)
	setup.nclusters
- Upscaling mode (any supported by MATLAB's imresize, or 'ibp')
	setup.model
- Number of trees
	setup.ntrees
- Number of training scales (maximum 16)
	setup.nscales
- Maximum number of samples per leaf to compute regressors
	setup.nsamples
- Path to the testing images folder
	testingfolder

For the default configuration, the complete model data (partitioning
trees and leaf regressors) are provided for upscaling factor 2,
whereas for factors 3 and 4 only the partitioning trees are provided.
Training the regressors requires a computer with around 8 GB RAM.

