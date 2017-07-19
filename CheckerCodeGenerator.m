%%%Matlab script to generate unique color codes
%%%for Eye Tacking Grasp Study. Study features 50ish 
%%%white tiles, and for Computer Vision 3D Image Registration
%%%we would like to generate a unique color code for each tile
%%%this makes identifying where you are relative to the table easy if
%%%can see at least one of these tiles.
%%%The code will be a 3x3 grid of colored circles where the
%%%possibilities are either R, G, B

%%%This script will use variables for size of output image (will have 
%%%to match pixel size in tiles) and how the tiles will be spaced
%%%for the 3x3 case we will draw at 1/6, 3/6, and 5/6 of the overall
%%%square. The script will output each code as an image that will then
%%%be pasted into the overall checkerboard in GIMP.

%Our color vectors, victor
R = [1; 0; 0;];
G = [0; 1; 0;];
B = [0; 0; 1;];
W = [1; 1; 1; ];


%number of pixels for width/height of one tile
pixels = input('Enter tile width (in pixels): ');
%number of dots for width and height of tile, 3x3 in this case
%we assume grids are square
gridWidth = 3;
numDots = gridWidth^2;

increment = pixels/gridWidth;

initialPos = [increment/2 increment/2];
%matrix of positions, rows contain x,y and col's contain each position
positions = zeros(2,numDots);
currCol = 1;
for i = 0:gridWidth-1
   for j = 0:gridWidth-1
       positions(:,currCol) = initialPos + [i*increment j*increment];
       currCol = currCol + 1;
   end
end


%try 50 for now
radius = 50;

%generate Red, Green, and Blue circle matrices
Rcircle = ones(2*radius+1,2*radius+1,3);
Gcircle = ones(2*radius+1,2*radius+1,3);
Bcircle = ones(2*radius+1,2*radius+1,3);

for x = 1:2*radius
    for y = 1:2*radius
        X = [x,y;radius,radius];
        distance = pdist(X);
        if distance < radius
            Rcircle(x,y,:) = R;
            Gcircle(x,y,:) = G;
            Bcircle(x,y,:) = B;
        end
    end
end
        
        
%make folder
mkdir ('images');

%convert doubles to ints, as pixel fractions don't exist
positions = uint32(positions);



%binary matrix to make sure we don't duplicate number of colors
%in a tile, we code based on number of colors in the tile.
%the +1 comes from 0 of a certain color being a possibility
colorKeys = zeros(numDots+1,numDots+1,numDots+1);

%loop through our colors and positions
imageNum = 1;
for r = 0:1:numDots
   for g = 0:1:numDots
       for b = 0:1:numDots
           %we want the number of colors to sum to 
           %numDots, otherwise it is an invalid key
          
           
           if (r+g+b ~= numDots) 
               continue
           end
           
           %make sure we haven't used this key before
           %+1 comes from matlab being stupid and not using 0 index 
           if colorKeys(r+1,g+1,b+1) == 1
               continue
           end
           
           
           
           %if we made it this far we have a valid key
           %and we aren't resuing one. Create an image
           %for the tile, RGB depth. Also, update
           %boolean matrix so this key not used again
           Image = ones(pixels,pixels,3);
           colorKeys(r+1,g+1,b+1) = 1;
           
           %orientation of the colors doesn't necessarily matter, 
           %so the plan is to apply red to the first r positions
           %green to the following g positions, and blue to last 
           %positions. currCol used to loop through positions matrix
           currCol = 1;
           
           for rr = 1:r
               posX = positions(1,currCol);
               posY = positions(2,currCol);
               Image(posX-radius:posX+radius,posY-radius:posY+radius,:)=Rcircle;
               currCol = currCol + 1;
           end
           
           for bb = 1:b
               posX = positions(1,currCol);
               posY = positions(2,currCol);
               Image(posX-radius:posX+radius,posY-radius:posY+radius,:)=Bcircle;
               currCol = currCol + 1;
           end
           
           for gg = 1:g
               
               posX = positions(1,currCol);
               posY = positions(2,currCol);
               Image(posX-radius:posX+radius,posY-radius:posY+radius,:)=Gcircle;
               currCol = currCol + 1;
           end
           
           imwrite(Image,strcat('images/color',num2str(imageNum),'.png'));
           imageNum = imageNum+1;
       end 
   end
end

