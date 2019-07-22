% Generate a 302*302 blue square to overlay on top of grid depending where the user has the mouse hovering
img = zeros(302, 302);
coloredChannel = ones(302, 302) * 255;
coloredImg = cat(3, img, img, coloredChannel);
%imshow(coloredImg);
imwrite(coloredImg, "blueSquare.png");

