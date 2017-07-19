%%% Script to generate a black and white checker board for the 
%%% Summer 2015 Eye Tracking Grasp. Currently takes a pixel
%%% size in that stands for width and height of each tile.
%%% The size of table will be hard coded. We will using 150 pixels
%%% per inch. The current values are based on the desk 
%%% being used Summer 2015. Starting in top left the tiles are placed until
%%% row and columns end.

%we used 500
pixelWidth = input('What size would you like the tiles to be?(in pixels): ');

%this gives us a 36" x 66" poster with 150 pix/inch
imageWidth = 5400;
imageHeight = 9900;

% for new, smaller table
imageWidth = 15 * pixelWidth;
imageHeight = 15 * pixelWidth;

white = [1;1;1];

finalImage = zeros(imageHeight,imageWidth,3);

doubleWidth = 2*pixelWidth;

%brute force way, can be slow
for i = 1:imageWidth
   
    for j = 1:imageHeight
        
         %are we black or white?
         %for cases, i and j are both less than
         %width (black), both greater than width (black)
         %or exclusive or is true (one is greater than width
         %one less than
         isRowGreater = mod(i,doubleWidth) > pixelWidth;
         isColGreater = mod(j + 3 * pixelWidth / 2,doubleWidth) > pixelWidth;
         
         if xor(isRowGreater,isColGreater)
            finalImage(j,i,:) = white;
         end
        
        
    end
    
end

imwrite(finalImage,'checkerboard.png');