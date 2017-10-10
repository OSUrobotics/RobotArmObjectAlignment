%% Read in points on the objects and convert to points + normals using mesh

%% Run conversion scripts
addpath('STLRead');

dir = '/Users/grimmc/Dropbox/Unity/Meshes/';
namesMesh = {'cylinder_large'};

for k = 1:length(namesMesh)
    fnameMesh = strcat(dir, namesMesh{k}, '.stl');
    % From meshlab; remove first two lines
    fnamePoints  = strcat(dir, namesMesh{k}, '_pts.off');
    fnameWriteTo = strcat(dir, namesMesh{k}, '_ids.txt');
    
    [m, idsOut, barysOut, normsOut] = PointsToBary( fnameMesh, fnamePoints, fnameWriteTo );

    RenderSTL(m, 1, false, [0.5 0.5 0.5]);
    hold on;
    pts = zeros( size( idsOut, 1 ), 3 );
    norms = pts;

    for p = 1:size( idsOut, 1 )
        [pt,norm] = Reconstruct(m, idsOut(p,:), barysOut(p,:) );
        pts(p,:) = pt;
        norms(p,:) = norm;
    end
    quiver3( pts(:,1), pts(:,2), pts(:,3), norms(:,1), norms(:,2), norms(:,3) );
    
    dlmwrite( strcat(dir, namesMesh{k}, '_ptsNorms.txt'), [pts norms] );
end

