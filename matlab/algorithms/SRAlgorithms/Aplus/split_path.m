function [dir, file] = split_path(path)
[dir, f, x] = fileparts(path);
file = [f x];
