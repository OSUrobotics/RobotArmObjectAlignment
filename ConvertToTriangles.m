function [ triangles ] = ConvertToTriangles( stlmesh, maskVs )
%ConvertToTriangles Convert the stlmesh to a set of triangles
%   Don't include the faces with all vertices masked out

bHasVertex = sum( maskVs( stlmesh.faces ), 2 ) > 1;

v1 = stlmesh.faces( bHasVertex, 1 );
v2 = stlmesh.faces( bHasVertex, 2 );
v3 = stlmesh.faces( bHasVertex, 3 );

triangles = [ stlmesh.vertices( v1', :) ...
              stlmesh.vertices( v2', :) ...
              stlmesh.vertices( v3', :) ];
end

