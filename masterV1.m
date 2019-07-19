% Cleaning Up the Workspace
clear all; close all;
 
%% Setting Up the Screen
Screen('Preference', 'SkipSyncTests', 1);
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock))); % Create a new random stream
[window, rect] = Screen('OpenWindow', 0); % Opening the screen
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % Setting up transparency
 
%% Window Sizing and Coordinates for Center
window_w = rect(3);
window_h = rect(4);
x_center = window_w/2;
y_center = window_h/2;

%% Loading Textures Into tid
total_Images = 147; % Number of images in our dataset
tid = zeros(1, total_Images);  % Holds textures

cd('Face_Stimuli');

%% Transparency Mask to Filter Excess Stimuli
Mask_Plain = imread('mask.png');
Mask_Plain = 255 - Mask_Plain(:, :, 1); % Only need one color channel of a grayscale image since all channels are the same

for i = 1 : total_Images
    tmp_bmp = imread([num2str(i) '.PNG']);
    tmp_bmp(:,:,4) = Mask_Plain;
    tid(i) = Screen('MakeTexture', window, tmp_bmp);
    Screen('DrawText', window, 'Loading...', x_center, y_center-25); % Write text to confirm loading of images
    Screen('DrawText', window, [int2str(int16(i*100/147)) '%'], x_center, y_center+25); % Write text to confirm percentage complete
    Screen('Flip', window); % Display text
end

cd('../');  %% Go up a directory, no need to stay int he images directory any longer

image_size = size(tmp_bmp);
w_img =  image_size(2) / 2; % image width
h_img =  image_size(1) / 2; % image height


%% Determining Location on Screen to Display Images
startingX = x_center - w_img / 2;
startingY = y_center - h_img / 2;
xVector = linspace(startingX, window_w-startingX, 2);
yVector = linspace(startingY, window_h-startingY, 2);
[x, y] = meshgrid(xVector, yVector);

%% Image Location and Organization
xy_rect = [x(:)' - w_img / 2; y(:)' - h_img / 2; x(:)' + w_img / 2; y(:)' + h_img / 2];  % Generate a matrix of where to position the images
num_In_Scene = 4; % The number of images we display in each scene

%% Non-Outlier Images
regImages = randperm(total_Images - 6, 4);  % Generate average morph for each of the 3 regular images in each scene
order = randperm(6);  % Random order to display morphs around the average for each of the 3 regular images in each scene

%% Display the Images
for c = 1 : 6

	adjustedVals = [regImages(1) + order(c), regImages(2) + order(c), regImages(3) + order(c), regImages(4) + order(c)];

	Screen('DrawTextures', window, tid(adjustedVals), [], xy_rect);  %% Use the default source and use our xy_rect matrix for the destination of the images
	DrawFormattedText(window,'+','center','center',[0 0 0]);
	Screen('Flip', window);
	WaitSecs(0.5);

	if c == 6

		
	%% Cole's Part: getting clicks and screen for clicks

	% correct_area_in_image = ... (need to specify for a given randomly
	% generated crowd, what index the outlier is at -- should be done by
	% whoever is doing the randomization thingy) -- specify in the first index,
	% the outer x coordinate of the grid (i.e. the far left or the far right
	% side if the correct outlier is on the left or right respectively, and in
	% the second index specify the outer y coordinate of the grid (i.e. the far
	% bottom and the far top coordinate if the correct outlier is in the top or
	% bottom respectively)
	size_of_square_image = 302; %enter the size of one of the sides of one of the images

	clicking_grid = imread('clickinggrid.png');
	xy_center = [x_center-size_of_square_image,y_center-size_of_square_image,x_center+size_of_square_image,y_center+size_of_square_image];
	makegrid = Screen('MakeTexture', window, clicking_grid);
	Screen('DrawTextures', window, makegrid, [], xy_center);
	DrawFormattedText(window,'Please click on the location of the outlier','center',100,[0 0 0]);
	Screen('Flip', window);

	tf = 0;
	x=0;
	y=0;

	while tf == 0
	    [x,y,buttons]=GetMouse(); %gets coordinates of the button press when it is done
	    tf=any(buttons); %sets to 1 if a button was pressed
	    WaitSecs(.01);
	end

	%if ((x<correct_area_in_image(1) && x>x_center) || (x>correct_area_in_image(1)) && (x<x_center)) && ((y<correct_area_in_image(2) && y>y_center) || (y>correct_area_in_image(2) && y<y_center)) %if the person clicked on the correct outlier
	%    accuracystorage(crowdnum, 2) = 1;%record correct click (accuracystorage(...,1) will display the numbers of the pictures shown in a single cell)
	%else
	%    accuracystorage(crowdnum, 2) = 0;%record bad click
	%end
	% then just repeat the loop that everything is in
 

%% Getting click for high/low variance part thingy doob

dimensions_of_buttons = [137, 103];

 

xy_high_center = [x_center-dimensions_of_buttons(1), y_center-dimensions_of_buttons(2)-150, x_center+dimensions_of_buttons(1), y_center+dimensions_of_buttons(2)-150];

xy_low_center = [x_center-dimensions_of_buttons(1), y_center-dimensions_of_buttons(2)+150, x_center+dimensions_of_buttons(1), y_center+dimensions_of_buttons(2)+150];

 

 

DrawFormattedText(window,'Was the variance \n of this outlier set \n high or low?','center',100,[0 0 0]);

High_button = imread('High Button.png');

Low_button = imread('Low Button.png');

makebuttonlayout_high = Screen('MakeTexture', window, High_button);

makebuttonlayout_low = Screen('MakeTexture', window, Low_button);

Screen('DrawTextures', window, makebuttonlayout_high, [], xy_high_center);

Screen('DrawTextures', window, makebuttonlayout_low, [], xy_low_center);

Screen('Flip', window);

tff = 0;

looping_again = 0;

while looping_again == 0

    xx=0;

    yy=0;

    userchoice_variance = 0;

    while tff == 0

        [xx,yy,buttons]=GetMouse(); %gets coordinates of the button press when it is done

        tff=any(buttons); %sets to 1 if a button was pressed

        WaitSecs(.01);

    end

    if (xx > xy_high_center(1) && xx < xy_high_center(3) && yy > xy_high_center(2) && yy < xy_high_center(4))

        userchoice_variance = 1; % setting userchoise_variance equal to 1 if the high button is pressed

        looping_again = 1; %breaking out of loop

        %DrawFormattedText(window,'high was pressed?','center',700,[0 0 0]);

        %Screen('Flip', window);

    elseif (xx > xy_low_center(1) && xx < xy_low_center(3) && yy > xy_low_center(2) && yy < xy_low_center(4))

        userchoice_variance = 2; % setting userchoise_variance equal to 2 if the low button is pressed

        looping_again = 1; %breaking out of loop

        %DrawFormattedText(window,'low was pressed?','center',700,[0 0 0]);

        %Screen('Flip', window);

    else

        tff = 0 %going back into the "is the user clicking?" loop once the looping_again while loop is repeated

        looping_again = 0;

    end

end

%if userchoice_variance == correct_variance

%    accuracy_storage(crowdnum, 3) = 1;

%else

%    accuracy_storage(crowdnum, 3) = 0;

%end

 

WaitSecs(2);

	end

end



Screen('CloseAll');
