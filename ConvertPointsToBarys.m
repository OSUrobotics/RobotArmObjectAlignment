%% Run conversion scripts
addpath('STLRead');

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
name = 'handAndArm';
%name = 'handOnly';
handrep = struct;
strConv = { 'palm', 'palm_left', 'palm_right', ...
            'thumb_inner', 'thumb_joint', ...
            'thumb_outer1', 'thumb_outer2',  'thumb_outer3', ...
            'finger1_inner', 'finger1_joint', ...
            'finger1_outer1', 'finger1_outer2', 'finger1_outer3', ...
            'finger2_inner', 'finger2_joint', ...
            'finger2_outer1', 'finger2_outer2', 'finger2_outer3'};
handrep.names = strConv;
handrep.vIds = zeros( length( strConv ), 3 );
handrep.vBarys = zeros( length( strConv ), 3 );
handrep.vNorms = zeros( length( strConv ), 3 );
        
strMesh = strcat(dir, name, '.ply');
for k = 1:size( strConv, 2)
    clf
    strBase = strcat(dir, name, '_', strConv{k});
    [m, ids, barys, norms] = PointsToBary( strMesh, strcat(strBase, '.txt'), strBase);
    handrep.vIds(k,:) = ids(1,:);
    handrep.vBarys(k,:) = barys(1,:);
    handrep.vNorms(k,:) = norms(1,:);    
end

RenderSTL( m, 1, false, [0.5 0.5 0.5] );
hold on
for k = 1:size( strConv, 2 )
    pt = Reconstruct(m, handrep.vIds(k,:), handrep.vBarys(k,:) );
    plot3( pt(1), pt(2), pt(3), 'Xr', 'MarkerSize', 20 );
end

%%Points on hand
save( strcat( dir, 'handrep', name, '.mat'), 'handrep' );

foo = load( strcat( dir, 'handrep', name, '.mat') );
hrCheck = foo.handrep;
for k = 1:size(hrCheck.vIds, 1 )
    pt = Reconstruct(m, hrCheck.vIds(k,:), hrCheck.vBarys(k,:) );
    plot3( pt(1), pt(2), pt(3), 'Og', 'MarkerSize', 20 );
end

fid = fopen( strcat(dir, name, '_vs.txt'), 'w');
for k = 1:size(m.vertices,1)
    fprintf(fid, '%0.6f %0.6f %0.6f ', m.vertices(k,:));
end
fclose(fid);