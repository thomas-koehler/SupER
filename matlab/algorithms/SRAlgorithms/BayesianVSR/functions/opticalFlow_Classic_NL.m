function [u v] = opticalFlow_Classic_NL(frame1, frame2)


%tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uv = estimate_flow_interface(frame1, frame2, 'classic+nl-fast');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%toc

u = uv(:,:,1);
v = uv(:,:,2);
