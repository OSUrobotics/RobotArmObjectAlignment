%% Run conversion scripts
addpath('STLRead');

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
name = 'handOnly';
strConv = { 'palm', 'thumb_inner', 'thumb_outer', ...
            'finger1_inner', 'finger1_outer', ...
            'finger2_inner', 'finger2_outer'};
        
strMesh = strcat(dir, name, '.stl');
for k = 1:size( strConv, 2)
    clf
    strBase = strcat(dir, name, '_', strConv{k});
    PointsToBary( strMesh, strcat(strBase, '.txt'), strcat(strBase, '_ids.txt'));
end
