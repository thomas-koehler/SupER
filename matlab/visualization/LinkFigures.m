function LinkFigures(varargin)
% Links figures, like linkaxes but with different figures
%
% Accept the formats:
%		LinkFigures(1,2,3)  or  LinkFigures([1,2,3])  or  LinkFigures(1:3)
%
% Note that using the first 2 options, the first figure you specify will state
%    the initial axes limits, so you can first zoom in and only then link.
%
% When final input is 'x' links only X axis
% When final input is 'y' links only X axis
% When final input is 'off'  breaks links
%
% Created by Yanai Ankri


xOnly = 0;
yOnly = 0;
removeLink = 0;
L = length(varargin);
lastVar = cell2mat(varargin(end));
if ischar(lastVar)
	L = L-1;
	if strcmp(lastVar , 'x')
		xOnly = 1;
	end
	if strcmp(lastVar , 'y')
		yOnly = 1;
	end
	if strcmp(lastVar , 'off')
		removeLink = 1;
	end
end

ax = [];
for i=1:L
	list = cell2mat(varargin(i));
	for j=1:length(list)
		ax(end+1) = gca(list(j));
	end
end

if xOnly
    linkaxes(ax,'x')
elseif yOnly
    linkaxes(ax,'y')
elseif removeLink
	linkaxes(ax,'off')
else
	linkaxes(ax)
end
