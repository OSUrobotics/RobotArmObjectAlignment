%% Run conversion scripts
addpath('STLRead');

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
name = 'handAndArm';
%name = 'handOnly';
handrep = struct;
strConv = { 'palm', 'palm_left', 'palm_right', ...
            'thumb_inner', ...
            'thumb_outer1', 'thumb_outer2',  'thumb_outer3', ...
            'finger1_inner', ...
            'finger1_outer1', 'finger1_outer2', 'finger1_outer3', ...
            'finger2_inner', ...
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
    handrep.vIds(k,:) = ids(1,:) + 18; % Account for wacky v number
    handrep.vBarys(k,:) = barys(1,:);
    handrep.vNorms(k,:) = norms(1,:);    
end

RenderSTL( m, 1, false, [0.5 0.5 0.5] );
hold on;
pts = zeros( size( hrCheck.vIds, 1 ), 3 );
norms = pts;
for k = 1:size( strConv, 2 )
    [pt, norm] = Reconstruct(m, handrep.vIds(k,:) - 18, handrep.vBarys(k,:) );
    pts = [pt pt+norm * 0.1];
    pts(k,:) = pt;
    norms(k,:) = ptNorm;
end
quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );

%%Points on hand
save( strcat( dir, 'handrep', name, '.mat'), 'handrep' );

foo = load( strcat( dir, 'handrep', name, '.mat') );
hrCheck = foo.handrep;
mCheck = stlread( strcat( dir, 'frame0.stl') );
RenderSTL( mCheck, 1, false, [0.5 0.5 0.5] );
hold on;
for k = 1:size(hrCheck.vIds, 1 )
    [pt, ptNorm] = Reconstruct(mCheck, hrCheck.vIds(k,:), hrCheck.vBarys(k,:) );
    pts(k,:) = pt;
    norms(k,:) = ptNorm;
end
quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );

fid = fopen( strcat(dir, name, '_vs.txt'), 'w');
for k = 1:size(m.vertices,1)
    fprintf(fid, '%0.6f %0.6f %0.6f ', m.vertices(k,:));
end
fclose(fid);