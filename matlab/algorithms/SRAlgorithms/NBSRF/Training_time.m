basefolder=fileparts( mfilename( 'fullpath' ) );
elapsedtime=zeros(1,5);

%Training setup
setup.scaling=3; % MAGI-ADAPT
setup.nclusters=2048; %default configuration nclusters=2048
setup.overlap=setup.scaling;%min=1 (sliding window), max=psize (no overlap)
setup.psize=3*setup.scaling;
setup.model='ibp';%can be replaced by 'bicubic', etc.
setup.ntrees=16; %for training
setup.nscales=16; %for training
setup.force_trees=true; %force training - trees
setup.force_regs=true; %force training - regressors
setup.nsamples=1500; %per leaf, to compute regressors
setup.trainingfolder=[ basefolder '/data/training' ];
setup.trainingext='*.bmp';
time=tic;

for i = 1:5
setup=nbsrf_training( setup );
elapsedtime(i,1)=toc(time);

end

average=sum(elapsedtime)/5;
