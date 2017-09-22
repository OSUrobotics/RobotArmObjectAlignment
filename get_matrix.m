% This file generate matrices for Object and hand transformation from the
% object_transform.txt files

% dlmread is not working for this new format any more

function [matrix_1,matrix_2] = get_matrix(filename)

fileID=fopen(filename,'r');

matrix = [];

tline = fgetl(fileID);
while ischar(tline)
    tline = fgetl(fileID);
    id_1 = strfind(tline,'[[');
    if ~isempty(id_1)
        tline = tline(id_1(1)+1:end);
    end
    id_2 = strfind(tline,']]');
    if ~isempty(id_2)
        tline = tline(1:id_2(1));
    end
    if tline ~=-1
        vec = str2num(tline);
    end
    matrix = [ matrix; vec];
end
fclose(fileID);
matrix_1 = matrix(1:4,:);
matrix_2 = matrix(6:9,:);
end