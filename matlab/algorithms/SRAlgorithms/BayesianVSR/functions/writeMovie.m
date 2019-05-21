function writeMovie(path,vid)
% *************************************************************************
% Superresolution with Dictionary Technique
% writeMovie 
%
% Saves an input video as an uncompressed grayscale video
% 
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         03/27/2013
%
% Modifications:
% 
% *************************************************************************
property = 'Uncompressed AVI';

writerObj = VideoWriter(path,property);
open(writerObj);

for k = 1:length(vid) 
   writeVideo(writerObj,im2uint8(vid{k}));
end

% Create AVI file.
close(writerObj);

end