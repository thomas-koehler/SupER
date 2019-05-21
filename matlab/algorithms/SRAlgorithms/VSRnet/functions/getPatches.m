%% returns patches of size 'patchSize' from the positions (xPos,yPos)
% Attention: no border check performed, use getPatchPos to obtain coordinates
function [patches,patch_deviation]= getPatches(img,patchSize, xPos, yPos,getStdDev,showpatch)

%input checks
if nargin<6
    showpatch = false;
end
if nargin<5
    getStdDev = false;
end

if(length(xPos) ~= length(yPos))
    warning('xPos and yPos do not have the same length!! the shorter one will be used');
end

% initialization
nrPatches = min(length(xPos),length(yPos));
offset = patchSize-1;
%patches = cell(nrPatches,1);
patches = zeros([patchSize patchSize size(img,3) nrPatches],'single');
patch_deviation = zeros(nrPatches,1);

% show progress
if (showpatch == true) && (size(img,3) <=3)
    hold off; 
    imshow(img,[]);
    hold on;
end

% obtain patches
for i = 1:nrPatches
    offsety = min(offset,size(img,1)-yPos(i));
    offsetx = min(offset,size(img,2)-xPos(i));
%     if offsetx ~= offset
%        display('short'); 
%     end
    
    patch = img(yPos(i):yPos(i)+offsety,xPos(i):xPos(i)+offsetx,:);
    %        patches{i} = patch;
    patches(1:offsety+1,1:offsetx+1,:,i) = patch;
    if getStdDev
        patch_deviation(i) = var(patch(:));
    end
    if (showpatch == true) && (size(img,3) <=3)
        rectangle('Position',[xPos(i),yPos(i),patchSize,patchSize],'EdgeColor','r','LineWidth',2)
        drawnow;
        %pause(0.0);
    end
end
end
