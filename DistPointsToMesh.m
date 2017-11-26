function [ distances ] = DistPointsToMesh( pts, maskPts, stlmesh, maskVsOfTris, distSearch, distClip )
%DistPointsToMesh Project all the points onto the mesh
%   Return the distances and if they're considered "close"
%
% INPUT:
%   pts - nX3 list of points to project
%   maskPts - which of those points to try projecting
%   tris - mX3 triangles as vertex ids
%   maskVsOfTris - Which vertices of the mesh to consider (only do faces
%   that contain those vertices)
%   distClip - Anything further than that is too far away
%     Use distance to closest vertex for any point > percClip
%
% OUTPUTS:
%   distances - actual distances
%      further distances will only be approximate

%% Get the faces we need to project onto
bHasVertex = sum( maskVsOfTris( stlmesh.faces ), 2 ) > 0;

v1 = stlmesh.faces( bHasVertex, 1 );
v2 = stlmesh.faces( bHasVertex, 2 );
v3 = stlmesh.faces( bHasVertex, 3 );

tris = zeros( sum( bHasVertex ), 9 );
tris(:,1:3) = stlmesh.vertices( v1', :);
tris(:,4:6) = stlmesh.vertices( v2', :);
tris(:,7:9) = stlmesh.vertices( v3', :);

%% Distances - pre-set to distClip for those we're not doing
distances = zeros( 1, size(pts,1) ) + distClip;

%% For each point to project...
iTryMax = 30;
for p = 1:size(pts,1)
    if maskPts(p)
        %% Get distance to vertices of each triangle
        dsFs = zeros( size(tris, 1), 1 ) + distClip;
        for k = [1 4 7]
            dsFsVI = ( tris(:,k) - pts(p,1) ).^2 + ( tris(:,k+1) - pts(p,2) ).^2 + ( tris(:,k+2) - pts(p,3) ).^2;
            bCloser = dsFsVI < dsFs;
            dsFs(bCloser) = dsFsVI( bCloser );
        end
        [dTriVs, is] = sort( dsFs );
        bFound = false;
        distances(p) = dTriVs(1);
        k = 1;
        
        % Starting with the triangle with the closest vertex, project
        % onto triangle
        %   If it projected onto the triangle, we're done
        %     Not necessarily closest - but good enough
        while ( k < iTryMax && bFound == false && dTriVs(k) < distClip)
            iIndex = is(k);
            [ dist, bInPolygon, ~, ~, ~, ~, ~ ] = ProjectPolygon( tris(iIndex,:), pts(p,1:3) );
            if bInPolygon 
                bFound = true;
                distances(p) = dist;
            end
            if distances(p) < distSearch && k > 3 
                bFound = true;
            end                
            k = k+1;
        end
    end
end

end

