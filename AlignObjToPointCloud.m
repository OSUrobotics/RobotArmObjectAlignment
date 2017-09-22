function [ mFix ] = AlignObjToPointCloud( stlMesh, pts )
%AlignObjToPointCloud Project points onto stl mesh, align using procrustes
%   Detailed explanation goes here

ptPolygon = pts;
mFix = eye(4,4);

iTry = min( [size(stlMesh.faces,1), 40] );
ds = zeros( iTry, 1);
projTris = zeros( iTry, 3);

for loop = 1:3
    dSum = 0;
    trisObj = ConvertToTriangles( stlMesh, stlMesh.vertices(:,1) < 1e-30 );
    
    for k = 1:size(pts,1)
        dsFs = ( trisObj(:,1) - pts(k,1) ).^2 + ( trisObj(:,2) - pts(k,2) ).^2 + ( trisObj(:,3) - pts(k,3) ).^2;
        [~, is] = sort( dsFs );
        for j = 1:iTry        
            t = is(j); % only look at closest triangles
            [ d, ~, ~, triPt, ~, ~, ~ ] = ...
                ProjectPolygon( trisObj(t,:), pts(k,:) );
            ds(j) = d;
            projTris(j,:) = triPt;
        end
        [dMin,iClosest] = min( ds );
        dSum = dSum + dMin;
        ptPolygon(k,:) = projTris( iClosest,:);
        
        %vs = [pts(k,:); ptPolygon(k,:)];
        %plot3( vs(:,1), vs(:,2), vs(:,3), '-Xk');
    end
    fprintf('sum %f\n', dSum / size(pts,1));
    
    [~,~,transform] = procrustes( pts, ptPolygon, 'scaling', false, 'reflection', false );

    R = eye(4,4);
    T = eye(4,4);
    S = eye(4,4);

    R(1:3,1:3) = transform.T';
    for k = 1:3
        S(k,k) = transform.b;
    end

    T(1:3,4) = transform.c(1,1:3);

    M = T * R * S;

    stlMesh.vertices = Move( stlMesh.vertices, M );
    mFix = mFix * M;

end

