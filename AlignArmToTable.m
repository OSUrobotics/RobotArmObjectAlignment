function [ matAlign, vsAligned ] = AlignArmToTable( stlIn, fileData )
%AlignArmToTable Translate and rotate the arm to (approximately) align with
% the table
%   Find the vertices on the base and front of the arm
%   Rotate by known rotation (pi around z)
%   Translate middle of base to the origin
%   Then move to side of table

vsBase = stlIn.vertices( fileData.baseMask, 1:3 );
vsFront = stlIn.vertices( fileData.baseFrontMask, 1:3 );

% Middle of the base and middle of the frong
ptBase = mean( vsBase );
ptFront = mean( vsFront );

global dSquareWidth;

matTransOrig = eye(4,4);
matRot = eye(4,4);
matTransSide = eye(4,4);
% Spin around z
matRot( 1,1 ) = cos( pi );
matRot( 2,2 ) = cos( pi );
matRot( 1,2 ) = sin( pi );
matRot( 2,1 ) = -sin( pi );

% X,Y are determined by the front - bring front to zero, zero
% Z is the bottom of the base
matTransOrig( 1,4 ) = -ptFront(1);
matTransOrig( 2,4 ) = -ptFront(2);
matTransOrig( 3,4 ) = -ptBase(3);
% Push front to the -X side of the table
%   shift Y by two squares
%   shift Z down
matTransSide( 1,4 ) = -dSquareWidth * 18;
matTransSide( 2,4 ) = -dSquareWidth * 2;
matTransSide( 3,4 ) = dSquareWidth * 0.1;
matAlign = matTransSide * matRot * matTransOrig;

vsAligned = Move( stlIn.vertices, matAlign );

end

