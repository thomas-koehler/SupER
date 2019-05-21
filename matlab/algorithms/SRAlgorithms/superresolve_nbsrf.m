function sr_img = superresolve_nbsrf(slidingWindows, magFactor)

lIm       = slidingWindows.referenceFrame;
upscaling = magFactor;


basefolder = fileparts( mfilename( 'fullpath' ) );

basefolder = [basefolder,'/NBSRF']; % MAGI-ADAPT

%Training setup
setup.scaling=upscaling;
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

%Super Resolution

%luminance
sr_img(:,:,1) = double(nbsrf(lIm(:,:,1), setup)); %NBSRF for luminance

if size(lIm,3) == 3,
    %bicubic for color channels
    for i=2:3
        sr_img(:,:,i)=lmsSR_interpolate2D(lIm(:,:,i),[upscaling,upscaling], 'cubic');
    end
end


%allignment for imresize in nbsrf
%[x_mesh,y_mesh]=meshgrid(1:size(sr_img(:,:,1),2),1:size(sr_img(:,:,1),1));
%x_mesh_shift = x_mesh + (upscaling-1)/2; %1,5;
%y_mesh_shift = y_mesh + (upscaling-1)/2; %1,5;
%
%sr_img_shifted=griddata(x_mesh,y_mesh,sr_img(:,:,1),x_mesh_shift,y_mesh_shift,'cubic');
%sr_img(:,:,1)=sr_img_shifted;

