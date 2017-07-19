function [ vertexIndex ] = PixelToPCVertex( x,y, im )
%PixelToPCVertex Convert from a pixel in the image to a vertex index
%   INPUT:
%     x - x location in pixels OR 0-1
%     y - y location in pixels OR 0-1
%             Assumes indexing from 0
%    im - image

w = size( im, 2 );
h = size( im, 1 );

if x < 1 && y < 1
    x = round( x ) * w;
    y = round( y ) * h;
else
    x = round(x);
    y = round(y);
end

if x > w-1
    x = w-1;
end

if y > h-1
    y = h-1;
end

vertexIndex = x * h + y;
end

