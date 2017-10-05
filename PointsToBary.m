function [m, idsOut, barysOut, normsOut] = PointsToBary( fnameMesh, fnamePoints, fnameWriteTo )

%% Read in a set of 3D points and produce
%   Vertex 1 vertex 2 vertex 3  bary 1 bary 2 bary 3
% for each point


if strcmp( upper( fnameMesh(end-3:end) ), '.STL' ) 
    mClick = stlread( fnameMesh );
elseif strcmp( upper( fnameMesh(end-3:end) ), '.PLY' ) 
    mClick = struct;
    [mClick.vertices, mClick.faces] = read_ply( fnameMesh );
else
    fprintf('File type %s not found\n', fnameMesh);
    mClick = [];
end

m = stlread( strcat(fnameMesh(1:end-4), '.STL') );
%RenderSTL( m, 1, false, [0.5 0.5 0.5] );
%hold on
RenderSTL( mClick, 1, false, [0.5 0.5 0.5] );

ps = dlmread( fnamePoints );
pts = [];
% list of points
if size(ps,2) == 3
    pts = ps;
else
    pts = mClick.vertices(ps == 1, :);
    hold on;
    plot3( pts(:,1), pts(:,2), pts(:,3), 'Or', 'MarkerSize', 20);
    vIds = 1:length(ps);
    disp( vIds( ps == 1 ) );
    pts = mean(pts); % One point - average
end

idsOut = zeros( length( pts ), 3 ); 
barysOut = zeros( length( pts ), 3 );
normsOut = zeros( length( pts ), 3 );

hold on;
plot3( pts(:,1), pts(:,2), pts(:,3), 'Xg', 'MarkerSize', 20);
dists = zeros( size(pts,1), 1 );
tris = ConvertToTriangles(m, ones( size(m.vertices, 1), 1) );

fprintf('NVs %0.0f\n', size(m.vertices,1));
dists = zeros( size(pts,1), 1 );
fidIds = fopen( strcat( fnameWriteTo, '_ids.txt'), 'w');
fidLocs = fopen( strcat( fnameWriteTo, '_pts_norms.txt'), 'w');
for k = 1:size(pts,1)
    for indx = 1:size(tris,1)
        dists(indx) = ProjectPolygon( tris(indx,:), pts(k,1:3) );
    end
    
    [dBest, iBest] = min( dists );
    fprintf('Found %0.0f best %0.2f\n', k, dBest);
    
    [ ~, ~, ~, ~, barys, ~, ~ ] = ProjectPolygon( tris(iBest,:), pts(k,1:3) ) ;
    
    fprintf('%0.0f, %0.0f, %0.0f, %0.6f, %0.6f, %0.6f\n', m.faces(iBest,:), barys );
    fprintf(fidIds, '%0.0f, %0.0f, %0.0f, %0.6f, %0.6f, %0.6f\n', m.faces(iBest,:), barys );
    
    ptReconstruct = Reconstruct( m, m.faces(iBest,:), barys );
                    %m.vertices( m.faces(iBest,1),:) .* barys(1) + ...
                    %m.vertices( m.faces(iBest,2),:) .* barys(2) + ...
                    %m.vertices( m.faces(iBest,3),:) .* barys(3);
    plot3( ptReconstruct(1), ptReconstruct(2), ptReconstruct(3), 'Or', 'MarkerSize', 20);
    fprintf('Pt - ptReconstruct %0.6f %0.6f %0.6f\n', pts(k,1:3) - ptReconstruct );
    
    fprintf(fidLocs, '%0.6f, %0.6f, %0.6f,', ptReconstruct );
    vecNorm = cross( m.vertices( m.faces(iBest,2),:) - m.vertices( m.faces(iBest,1),:), ...
                     m.vertices( m.faces(iBest,3),:) - m.vertices( m.faces(iBest,1),:) );
    vecNorm = vecNorm ./ sqrt( vecNorm(1)^2 + vecNorm(2)^2 + vecNorm(3)^2 );
    fprintf(fidLocs, '%0.6f, %0.6f, %0.6f,', vecNorm );
    
    idsOut(k,:) = m.faces(iBest,:);
    barysOut(k,:) = barys;
    normsOut(k,:) = vecNorm;
end
fclose(fidIds);
fclose(fidLocs);

end