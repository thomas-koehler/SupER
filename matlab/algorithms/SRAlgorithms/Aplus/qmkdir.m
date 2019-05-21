function dir = qmkdir(dir)
% Quiet MKDIR (does not emit warning if DIR exists)
[success, message] = mkdir(dir);  %#ok<NASGU>
