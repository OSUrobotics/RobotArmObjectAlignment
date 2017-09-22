function [ pts ] = GetPtsForICP( stlmesh, mask, nSamples )
%Sub-sample the polygons that have the listed vertices
%   Barycentric coords are your friend

bHasVertex = sum( mask( stlmesh.faces ), 2 ) == 3;

v1 = stlmesh.faces( bHasVertex, 1 );
v2 = stlmesh.faces( bHasVertex, 2 );
v3 = stlmesh.faces( bHasVertex, 3 );

vs1 = stlmesh.vertices( v1', :);
vs2 = stlmesh.vertices( v2', :);
vs3 = stlmesh.vertices( v3', :);

ptsInterp = zeros( nSamples * size(vs1,1), 3 );
count = 1;
for k = 1:nSamples
    for j = 1:size( vs1,1 )
        alphas = rand( 3, 1 );
        alphas = alphas ./ sum(alphas);
        ptsInterp(count,:) = alphas(1) * vs1(j,:) + alphas(2) * vs2(j,:) + alphas(3) * vs3(j,:);
        count = count + 1;
    end
end
    
pts = [ stlmesh.vertices( mask, : ); ptsInterp ];

end

