function [ assignment, distances ] = AssignPointsToMesh( pts, mask, tris1, tris2, percClip )
%AssignPointsToMesh
%   which mesh is it closest to
%   tris should be triangles made by ConvertToTriangles
%   1 is first mesh, 2 is second, 3 is not near either

dists1 = zeros( 1, min( [30, size(tris1,1) ] ) );
dists2 = zeros( 1, min( [30, size(tris2,1) ] ) );

bboxObj1 = [ min( min( tris1(:,1:3:end) ) ) min( min( tris1(:,2:3:end) ) ) min( min( tris1(:,3:3:end) ) ); ...
             max( max( tris1(:,1:3:end) ) ) max( max( tris1(:,2:3:end) ) ) max( max( tris1(:,3:3:end) ) )];
bboxObj2 = [ min( min( tris2(:,1:3:end) ) ) min( min( tris2(:,2:3:end) ) ) min( min( tris2(:,3:3:end) ) ); ...
             max( max( tris2(:,1:3:end) ) ) max( max( tris2(:,2:3:end) ) ) max( max( tris2(:,3:3:end) ) )];
         
dDiag1 = sqrt( sum( (bboxObj1(2,:) - bboxObj1(1,:)).^2 ) );
dDiag2 = sqrt( sum( (bboxObj2(2,:) - bboxObj2(1,:)).^2 ) );

assignment = zeros( size(pts,1), 1 );
distances = zeros( size(pts,1), 1 );
for p = 1:size(pts,1)
    if mask(p)
        dsFs = ( tris1(:,1) - pts(p,1) ).^2 + ( tris1(:,2) - pts(p,2) ).^2 + ( tris1(:,3) - pts(p,3) ).^2;
        [~, is] = sort( dsFs );
        for k = 1:length(dists1)
            iIndex = is(k);
            dists1(k) = ProjectPolygon( tris1(iIndex,:), pts(p,1:3) );
        end

        dsFs = ( tris2(:,1) - pts(p,1) ).^2 + ( tris2(:,2) - pts(p,2) ).^2 + ( tris2(:,3) - pts(p,3) ).^2;
        [~, is] = sort( dsFs );
        for k = 1:length(dists2)
            iIndex = is(k);
            dists2(k) = ProjectPolygon( tris2(iIndex,:), pts(p,1:3) );
        end

        %[d1, i1] = min(dists1);
        %[d2, i2] = min(dists2);
        d1 = min(dists1);
        d2 = min(dists2);

        if d1 < d2
            distances(p) = d1;
            assignment(p) = 1;
        else
            distances(p) = d2;
            assignment(p) = 2;
        end
        
%         clf
%         showPointCloud( tris1(:, 1:3), [1 0 0] );
%         hold on;
%         showPointCloud( tris2(:, 1:3), [0 1 0] );
%         
%         for k = 1:length(dists1)
%             ptsP = [ tris1(is(k),1:3); pts(p,1:3)];
%             plot3( ptsP(:,1), ptsP(:,2), ptsP(:,3), '-Xk');
%         end
%         ptsP = [ reshape( tris1(is(i1),:), [3 3] )';...
%                  tris1(is(i1),1:3)];
%         plot3( ptsP(:,1), ptsP(:,2), ptsP(:,3), '-Xr');
%         ptsP = [ reshape( tris2(i2,:), [3 3] )';...
%                  tris2(i2,1:3)];
%         plot3( ptsP(:,1), ptsP(:,2), ptsP(:,3), '-Xg');
%         
%         plot3( pts(p,1), pts(p,2), pts(p,3), 'Ob', 'MarkerSize', 20);
    end
end

% Far away points
assignment( assignment == 1 & distances > dDiag1 * percClip ) = 3;
assignment( assignment == 2 & distances > dDiag2 * percClip ) = 4;

end

