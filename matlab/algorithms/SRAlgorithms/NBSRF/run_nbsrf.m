function run_nbsrf

%%%%%%%%%%%%%%% COPYRIGHT AND CONFIDENTIALITY INFORMATION %%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%% Copyright (c) 2015 DEUTSCHE THOMSON OHG � A Technicolor's Company   %%%
%%% All Rights Reserved                                                 %%%
%%%                                                                     %%%
%%% This program contains proprietary information which is a trade      %%%
%%% secret of DTO and/or its affiliates and also is protected as        %%%
%%% under applicable Copyright laws. Recipient is                       %%%
%%% not permitted to use or make copies thereof other than as           %%%
%%% permitted in a written agreement with DTO or its affiliates,        %%%
%%% UNLESS OTHERWISE EXPRESSLY ALLOWED BY APPLICABLE LAWS.              %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

fprintf( [ ...
  'Your use of the Software is subject to the terms and conditions set\n' ...
  'forth in the license Agreement available at\n' ...
  'http://jordisalvador-image.blogspot.de/.\n' ...
  'By installing, using, accessing or copying the Software, you hereby\n' ...
  'irrevocably accept the terms and conditions of this license Agreement.\n' ...
  'If you do not accept all or parts of the terms and conditions of this\n' ...
  'Agreement you cannot install, use, access nor copy the Software.\n\n' ...
  ] );

basefolder=fileparts( mfilename( 'fullpath' ) );

%Training setup
setup.scaling=4;
setup.nclusters=2048; %default configuration nclusters=2048
setup.overlap=setup.scaling;%min=1 (sliding window), max=psize (no overlap)
setup.psize=3*setup.scaling;
setup.model='ibp';%can be replaced by 'bicubic', etc.
setup.ntrees=16; %for training
setup.nscales=16; %for training
setup.force_trees=false; %force training - trees
setup.force_regs=false; %force training - regressors
setup.nsamples=1500; %per leaf, to compute regressors
setup.trainingfolder=[ basefolder '/data/training' ];
setup.trainingext='*.bmp';
setup=nbsrf_training( setup );

%Testing setup
setup.ntrees=8; %default configuration ntrees=8
setup.R=setup.R(:,:,:,1:setup.ntrees);
setup.ldir=single( setup.ldir(:,:,1:setup.ntrees) );
setup.rdir=single( setup.rdir(:,:,1:setup.ntrees) );

% testingfolder=[ basefolder,'/data/Set5' ];
testingfolder=[ basefolder,'/data/Set14' ];
imagenames=dir( fullfile( testingfolder,'*.bmp' ) );
% testingfolder=[ basefolder,'/data/kodak' ];
% imagenames=dir( fullfile( testingfolder,'*.png' ) );

[~,foldername]=fileparts( testingfolder );
outfolder=[ basefolder,'/results/nbsrf_' datestr( now,'yyyymmddHHMMSS' ) '_' foldername '_x' num2str(setup.scaling) '_' setup.model '_m' num2str(setup.nclusters) '_n' num2str(setup.ntrees) ];
mkdir( outfolder );

PSNR=zeros( 1,length( imagenames ) );
time=zeros( 1,length( imagenames ) );
for tit=1:length( imagenames ) ,
  fprintf( '%s   ',imagenames(tit).name );
  [~,outname,~]=fileparts( imagenames(tit).name );
  
  imx=imread( fullfile( testingfolder,imagenames(tit).name ) );
  if size( imx,3 ) == 3 , imx=rgb2ycbcr( imx ); end
  imx=im2single( imx );
  imx=imx( 1:end-mod( size( imx,1 ),setup.scaling ),1:end-mod( size( imx,2 ),setup.scaling ),: );
  
  imsmall=imresize( imx,1/setup.scaling ); %simulate low-res input
  
  imout=imresize( imsmall,setup.scaling ); %bicubic for color channels
  start=tic;
  imout(:,:,1)=nbsrf( imsmall(:,:,1),setup ); %NBSRF for luminance
  time(tit)=toc( start );
  
  %Shave groundtruth and output and compute PSNR
  imx=imx(1+setup.scaling:end-setup.scaling,1+setup.scaling:end-setup.scaling,1);
  test=imout(1+setup.scaling:end-setup.scaling,1+setup.scaling:end-setup.scaling,1);
%   test=im2single( im2uint8( min( max( test,0 ),1 ) ) );
  PSNR(tit)=10*log10( length( imx(:) )/sum( abs( imx(:)-test(:) ).^2 ) );
  fprintf( 'PSNR %5.2f dB   Time %5.3f s\n',PSNR(tit),time(tit) );
  
  imout=im2double( min( max( imout,0 ),1 ) );
  imwrite( imout(:,:,1),[ outfolder '/' outname '_gray.tif' ] );
  if size( imout,3 ) > 1 , imout=ycbcr2rgb( imout ); end
  imwrite( imout,[ outfolder '/' outname '_rgb.tif' ] );
end
fprintf( '\nAverage PSNR %5.2f dB   Average time %5.3f s\n',mean( PSNR ),mean( time ) );
