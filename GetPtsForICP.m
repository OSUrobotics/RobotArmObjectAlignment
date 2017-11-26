function [ pts ] = GetPtsForICP( stlmesh, mask, nSamples )
%Sub-sample the polygons that have the listed vertices
%   Barycentric coords are your friend

bHasVertex = sum( mask( stlmesh.faces ), 2 ) > 0;

v1 = stlmesh.faces( bHasVertex, 1 );
v2 = stlmesh.faces( bHasVertex, 2 );
v3 = stlmesh.faces( bHasVertex, 3 );

vs1 = stlmesh.vertices( v1', :);
vs2 = stlmesh.vertices( v2', :);
vs3 = stlmesh.vertices( v3', :);

%% Get areas of faces
aF = zeros( size( vs1, 1 ), 1 );
for k = 1:size( vs1, 1 )
    vec = cross( vs2(k,:) - vs1(k,:), vs3(k,:) - vs1(k,:) );
    aF(k) = sqrt( sum( vec.^2 ) );
end
nAll = nSamples * size( vs1, 1 );
aF = nAll * aF / sum( aF );
fprintf('Generating %0.0f vs, max %0.0f ', nSamples * size( vs1, 1 ), max(aF) );

ptsInterp = zeros( nSamples * size(vs1,1), 3 );
count = 1;
for j = 1:size( vs1,1 )
    if floor( aF(j) ) > 0
        ptsInterp(count,:) = (1/3) * vs1(j,:) + (1/3) * vs2(j,:) + (1/3) * vs3(j,:);
        count = count + 1;
    end
    for s = 1:floor( aF(j) )-1
        alphas = rand( 3, 1 );
        alphas = alphas ./ sum(alphas);
        ptsInterp(count,:) = alphas(1) * vs1(j,:) + alphas(2) * vs2(j,:) + alphas(3) * vs3(j,:);
        count = count + 1;
    end
end
    
pts = [ stlmesh.vertices( mask, : ); ptsInterp(1:count-1,:) ];
fprintf(' total %0.0f\n', size(pts,1));
end

