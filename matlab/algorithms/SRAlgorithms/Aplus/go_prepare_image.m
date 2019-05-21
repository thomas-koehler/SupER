function [Ip] = go_prepare_image(I, x1,y1,x2,y2,s,K1, K2)

Ic = imcrop(I,[x1 y1 x2 y2]);

Is = imresize(Ic,s,'nearest');

Ip = uint8(255*ones(size(I,1)+K1, size(I,2)+K2, 3));
Ip(1:size(I,1),1:size(I,2),:) = I;

Is(1:end,1,:) = 0;
Is(1:end,end,:) = 0;
Is(1,1:end,:) = 0;
Is(end,1:end,:) = 0;

Ip(size(Ip,1)-size(Is,1)+1:size(Ip,1),size(Ip,2)-size(Is,2)+1:size(Ip,2),:)=Is;

