function saveXLSData(file_path,varargin)
% *************************************************************************
% Superresolution with Dictionary Technique
% saveXLSData
%
% saves any number of structs in an XLS file with name/path of file_path
%
% example:
% saveXLSData('mypath/data.xls',struct1,struct2)
%
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         3/20/2013
%
% Modifications:
% 
% *************************************************************************

nVarargs = length(varargin);
tmp = [];

for k = 1:nVarargs 
    str = varargin{k};
    tmp = [tmp; fieldnames(str),squeeze(struct2cell(str))];
    tmp = [tmp;cell(1,size(tmp,2))];
end

xlswrite([file_path '.xls'],tmp);
end