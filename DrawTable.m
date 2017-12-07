function [  ] = DrawTable( verticesTable, bFill )
%DrawTable Idealized table
%   Checkboard with colors
%     flat in x,y plane at z = 0
%     -1 to 1 in x,y is the middle four boxes (see ImageTable.png)
%
%   0,0 is middle (picked point 5)
%   1st picked point is upper left (-x, positive y) [brown]
%   2nd picked point is upper right (positive x and y) [cyan]
%
%  Grid size is set in the global variable dSquareWidth
%     2 cm currently

global dSquareWidth;
global checkerboardSize;

widthBox = dSquareWidth; 
nXY = floor( checkerboardSize/2 );

topLeft = [-nXY(1) * widthBox, -nXY(2) * widthBox];

% Color map for scribbled in squares
map = [0 0 0; 255 255 255; 90 215 55; 99 214 210; ...
       217 151 207; 215 120 103]/255;
colormap(map);

bWhite = false;
dX = 0.1 * dSquareWidth;
col = 0;
for xs = 1:checkerboardSize(1)
    x = topLeft(1) + (xs-1) * widthBox;
    y = topLeft(2);
    for ys = 1:checkerboardSize(2)        
        if bWhite == true 
            col = 2;
        else
            col = 1;
        end
        bWhite = ~bWhite;
        if xs == nXY(1)-1 && ys == nXY(2)-1
            col = 3;
        elseif xs == nXY(1)+1 && ys == nXY(2)-1
            col = 4;
        elseif xs == nXY(1)-1 && ys == nXY(2)+1
            col = 5;
        elseif xs == nXY(1)+2 && ys == nXY(2)+2
            col = 6;
        end
        if bFill
            fill3( [x, x+widthBox, x+widthBox, x], ...
                   [y, y, y+widthBox, y+widthBox]*-1, ...
                   [0,0,0,0], col );
        else
            plot3( [x+dX, x+widthBox-dX, x+widthBox-dX, x+dX, x+dX], ...
                   [y+dX, y+dX, y+widthBox-dX, y+widthBox-dX, y+dX]*-1, ...
                   [0,0,0,0,0], '-k', 'LineWidth', 1.5, 'Color', map(col,:) );
        end
       hold on;
       
       y = y + widthBox;
    end
    bWhite = ~bWhite;
end

plot3( verticesTable(:,1), verticesTable(:,2), verticesTable(:,3), 'Xr' );
for k = 1:size( verticesTable, 1 )
    text( verticesTable(k,1), verticesTable(k,2), num2str(k), 'Color', [1 0 1], 'FontSize',18 );
end

xlabel('x'); 
ylabel('y');
zlabel('z');
end
