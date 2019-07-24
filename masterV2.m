clear all; close all;

%% Obtaining User Input
Info = {'Initials', 'Full Name','Gender [1=Male, 2=Female, 3=Other]','Age','Ethnicity', 'Handedness [1=Right, 2=Left]'};
dlg_title = 'Subject Information';
num_lines = 1;
subject_info = inputdlg(Info,dlg_title,num_lines);

existingData = load('subjectNumber.mat');
subjectNumber = existingData.subjectNumber + 1;
save('subjectNumber', 'subjectNumber');

%% Setting Up the Screen
Screen('Preference', 'SkipSyncTests', 1);
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock))); % Create a new random stream
[window, rect] = Screen('OpenWindow', 0, [128 128 128]); % Opening the screen
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
    Screen('DrawText', window, 'Loading...', x_center*0.0069, y_center*1.9178); % Write text to confirm loading of images
    Screen('DrawText', window, [int2str(int16(i*100/147)) '%', 0.0069, y_center*1.9111]); % Write text to confirm percentage complete
    Screen('DrawText', window, 'Hello! Welcome to the Temporal Crowds Experiment.',x_center*0.6528, y_center) % User instruction page with proportionalized coordinates
    Screen('DrawText',window,'In the following screen, four flashing faces will be displayed, one of which will have a different expression from the other three faces.',x_center*0.025, y_center*1.0556); 
    Screen('DrawText',window,'Please identify which of the four faces is an outlier.',x_center*0.6646,y_center*1.111);
    Screen('DrawText',window,'Then, please specifify how different the outlier looked by choosing "High" variance or "Low" variance in the final slide.',x_center*0.125, y_center*1.1667);
    Screen('Flip', window); % Display text
end

WaitSecs(1);

cd('../'); % Go up a directory, no need to be in the images directory anymore

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
%lowRange = 7; %the variance number for low variance
%highRange = 20; %the variance number for high variance

trialnum = 6; %number of images shown in each one of the four positions in one loop
round = 300; % The number of trials. For the real experiment, this will be 300

faceNums = zeros(round, 4, 6);  % Stores all the morph numbers of each image shown in each round (each row is a round, each column corresponds to one square of the 4 in each scene, and each channel represents the image flashed in the sequence)

lowVariance = [-3 -1 1 3 5];
highVariance = [-40 -20 15  35 55];

crowds = zeros(4, 6);

Screen('Flip', window);
DrawFormattedText(window,'+','center','center',[0 0 0]);
Screen('Flip', window);
WaitSecs(0.5);

for m = 1: round
	regImages = randi(total_Images, 1, 4);  % Generate average morph for each of the 3 regular images in each scene
	%regImages = randperm(total_Images - highRange*trialnum, 4);

	%order = randperm(6);  % Random order to display morphs around the average for each of the 3 regular images in each scene

	low_or_high = randi(2) %1 = low as outlier 2 = high as outlier
	outlier = randi(4) %picking which of the four is the outlier

	adjustedVals = zeros(1, 4); % Initialize outside loop so MATLAB doesn't have to copy values and resize the matrix each iteration

	while abs(regImages(1) - regImages(2)) <= 5 || abs(regImages(1) - regImages(3)) <= 5 || abs(regImages(1) - regImages(4)) <= 5 || abs(regImages(2) - regImages(3)) <= 5 || abs(regImages(2) - regImages(4)) <= 5 || abs(regImages(3) - regImages(4)) <= 5
		regImages = randperm(total_Images, 4);
	end

	for group = 1 : 4
		
		if low_or_high == 1 %low as outlier
			crowds(group, :) = Shuffle([regImages(group) mod(regImages(group) + highVariance, total_Images) + 1]);
			crowds(outlier, :) = Shuffle([regImages(outlier) mod(regImages(outlier) + lowVariance, total_Images) + 1]);
		else %high as outlier
			crowds(group, :) = Shuffle([regImages(group) mod(regImages(group) + lowVariance, total_Images) + 1]);
			crowds(outlier, :) = Shuffle([regImages(outlier) mod(regImages(outlier) + highVariance, total_Images) + 1]);
		end

	end
	
	
	
	%% Display the Images
	for i = 1 : trialnum

	    
	    
	    
	    for k = 1:size(crowds, 1)

		for r = 1 : size(crowds, 2)

		
			if crowds(k, r) > total_Images
				crowds(k, r) = mod(crowds(k, r), 147) + 1;
			end

			if crowds(k, r) > 73.5
				faceNums(m, k, r) = 73.5 - (crowds(k, r) - 73.5);
			else
				faceNums(m, k, r) = crowds(k, r);
			end



		end
	    end	

	    HideCursor();
	    Screen('DrawTextures', window, tid(crowds(1:4, i)), [], xy_rect);  %% Use the default source and use our xy_rect matrix for the destination of the images
	    DrawFormattedText(window,'+','center','center',[0 0 0]);
	    Screen('Flip', window);
	    WaitSecs(0.2); % Supposed to be 0.2
	    DrawFormattedText(window,'+','center','center',[0 0 0]);
	    Screen('Flip', window);
	    DrawFormattedText(window,'+','center','center',[0 0 0]);
	    WaitSecs(0.1);
	    
	    if i == 6
			
		ShowCursor();
		SetMouse(450, 450, 0); %putting it near the middle of the screen
		
		%% Getting clicks and screen for clicks
		
		size_of_square_image = 302; %enter the size of one of the sides of one of the images/grid squares
		if outlier == 1 %this is all just determining where the user should click depending on which image was the outlier previously
		    correct_area_in_image = [x_center-size_of_square_image, y_center, x_center, y_center+size_of_square_image]; % top left one
		elseif outlier == 2
		    correct_area_in_image = [x_center-size_of_square_image,y_center-size_of_square_image, x_center, y_center]; % bottom left one
		elseif outlier == 3
		    correct_area_in_image = [x_center, y_center, x_center+size_of_square_image,y_center+size_of_square_image]; % top right one
		elseif outlier == 4
		    correct_area_in_image = [x_center,y_center-size_of_square_image,x_center+size_of_square_image, y_center]; % bottom right one
		end
		
		clicking_grid = imread('clickinggrid.png');
		bluesquare = imread('blueSquare.png');
		xy_center = [x_center-size_of_square_image,y_center-size_of_square_image,x_center+size_of_square_image,y_center+size_of_square_image]; %defining the location and size of the grid 
		makegrid = Screen('MakeTexture', window, clicking_grid);
		makesquare = Screen('MakeTexture', window, bluesquare);
		Screen('DrawTextures', window, makegrid, [], xy_center);
		DrawFormattedText(window,'Please click on the location of the outlier','center',100,[0 0 0]);
		Screen('Flip', window);
		square1 = [x_center-size_of_square_image, y_center, x_center, y_center+size_of_square_image];
		square2 = [x_center-size_of_square_image,y_center-size_of_square_image, x_center, y_center]; %defining the locations of the squares inside the grid for any screen size
		square3 = [x_center,y_center, x_center+size_of_square_image,y_center+size_of_square_image];
		square4 = [x_center,y_center-size_of_square_image,x_center+size_of_square_image, y_center];
		
		tf = 0;
		x=0;
		y=0;
		
		while tf == 0
		    [x,y,buttons]=GetMouse(); %gets coordinates of the button press when it is done
		    tf=any(buttons); %sets to 1 if a button was pressed
		    WaitSecs(.01);
		    Screen('DrawTextures', window, makegrid, [], xy_center);
		    DrawFormattedText(window,'Please click on the location of the outlier','center',100,[0 0 0]);

		    if (x>square1(1) && x<square1(3) && y>square1(2) && y<square1(4))
		        Screen('DrawTextures', window, makesquare, [], square1);
		    elseif (x>square2(1) && x<square2(3) && y>square2(2) && y<square2(4))
		        Screen('DrawTextures', window, makesquare, [], square2);
		    elseif (x>square3(1) && x<square3(3) && y>square3(2) && y<square3(4)) %drawing all of the grey squares if the mouse is hovering over a square in the grid
		        Screen('DrawTextures', window, makesquare, [], square3);
		    elseif (x>square4(1) && x<square4(3) && y>square4(2) && y<square4(4))
		        Screen('DrawTextures', window, makesquare, [], square4);
		    end
		    Screen('Flip', window);

		    if (x>correct_area_in_image(1) && x<correct_area_in_image(3)) && (y>correct_area_in_image(2) && y<correct_area_in_image(4)) %if the person clicked on the correct outlier location in grid
		        accuracy_storage(m, 1) = 1;%record correct click (accuracystorage(...,1) will display the numbers of the pictures shown in a single cell)
		    else
		        if (x>xy_center(1) && y>xy_center(2) && x<xy_center(3) && y<xy_center(4))% if clicked inside grid but not in the correct outlier location ...
		            accuracy_storage(m, 1) = 0;%record bad click
		        else
		            tf = 0; %if not inside grid, loop again
		        end
		    end
		end
		
		WaitSecs(.5);
		
		%% Getting click for high/low variance part thingy doob
		
		dimensions_of_buttons = [137, 103]; %defining size of buttons to be used below
		xy_high_center = [x_center-dimensions_of_buttons(1), y_center-dimensions_of_buttons(2)-150, x_center+dimensions_of_buttons(1), y_center+dimensions_of_buttons(2)-150];
		xy_low_center = [x_center-dimensions_of_buttons(1), y_center-dimensions_of_buttons(2)+150, x_center+dimensions_of_buttons(1), y_center+dimensions_of_buttons(2)+150]; %defining size and location of buttons
		High_button = rgb2gray(imread('High Button.png'));
		High_button = High_button(:, :, 1);
		Low_button = rgb2gray(imread('Low Button.png'));
		Low_button = Low_button(:, :, 1);
		highButtonColored = colorMyImage(High_button);
		lowButtonColored = colorMyImage(Low_button); %creating blue colored alternatives using below function colorMyImage()
		tff = 0;
		looping_again = 0;
		
		while looping_again == 0
		   
		    xx=0;
		    yy=0; %initialization of clicking vars
		    userchoice_variance = 0;
		    
		    while tff == 0
		        DrawFormattedText(window,'Was the variance \n of this outlier set \n high or low?','center',100,[0 0 0]);
		        [xx,yy,buttons]=GetMouse(); %gets coordinates of the button press when it is done
		        
		        if (xx > xy_high_center(1) && xx < xy_high_center(3) && yy > xy_high_center(2) && yy < xy_high_center(4))
		            makebuttonlayout_high = Screen('MakeTexture', window, highButtonColored);
		        else
		            makebuttonlayout_high = Screen('MakeTexture', window, High_button); %this while loop is just getting the location of the mouse hover and if it is over one of the buttons turning it blue 
		        end
		        
		        if (xx > xy_low_center(1) && xx < xy_low_center(3) && yy > xy_low_center(2) && yy < xy_low_center(4))
		            makebuttonlayout_low = Screen('MakeTexture', window, lowButtonColored);
		        else
		            makebuttonlayout_low = Screen('MakeTexture', window, Low_button);
		        end
		        
		        Screen('DrawTextures', window, makebuttonlayout_high, [], xy_high_center);
		        Screen('DrawTextures', window, makebuttonlayout_low, [], xy_low_center);
		        Screen('Flip', window);
		        tff=any(buttons); %sets to 1 if a button was pressed and thus breaks loop
		        WaitSecs(.01);
		    end
		    
		    if (xx > xy_high_center(1) && xx < xy_high_center(3) && yy > xy_high_center(2) && yy < xy_high_center(4))
		        userchoice_variance = 1; % setting userchoise_variance equal to 1 if the high button is pressed
		        looping_again = 1; %breaking out of loop
		    elseif (xx > xy_low_center(1) && xx < xy_low_center(3) && yy > xy_low_center(2) && yy < xy_low_center(4))
		        userchoice_variance = 2; % setting userchoise_variance equal to 2 if the low button is pressed
		        looping_again = 1; %breaking out of loop
		    else
		        tff = 0; %going back into the "is the user clicking?" loop once the looping_again while loop is repeated
		        looping_again = 0;
		    end

		end

		if userchoice_variance == low_or_high %if user choice is correct
		    accuracy_storage(m, 2) = 1;     % Store whether or not the user chose the correct variance (1 - yes, 0 - no)
		else
		    accuracy_storage(m, 2) = 0; 
		end
		
		WaitSecs(0.5);

	    end

	end
	    if mod(m, 50) == 0 && m ~= round %if the user has gone through 50 loops since last breaking or starting...
		
		breakTime = 60; % 1 minute break time	

		while breakTime >= 0
			Screen('DrawText', window, [num2str(breakTime) ' seconds left of break...'], x_center, y_center); % Write text to confirm percentage complete
			Screen('Flip', window); % Display text
			WaitSecs(1);
			breakTime = breakTime - 1;
		end	

	    end

end

%% Saving User's Results
if isdir('Results')
    cd('Results');
elseif ~isdir('Results')
    mkdir('Results');
end

nameID = char(upper(subject_info(1))); % Take the initials (first cell in subject_info) and make it uppercase so our formatting is consistent. Also convert the cell to a character array (a string)
dirName = num2str(subjectNumber) + "_" + nameID; % Name the user's results directory with the format of "[subject number]-[initials]"

if ~isdir(dirName)
	mkdir(dirName);
end

cd(dirName);
save('Results.mat', 'accuracy_storage');
save('SubjectInfo.mat', 'subject_info');
save('FaceMorphs.mat', 'faceNums');

Screen('CloseAll');

outlierAccuracy = sum(accuracy_storage(:, 1) == 1) / m * 100;
varianceAccuracy = sum(accuracy_storage(:, 2) == 1) / m * 100;
disp(newline + "Outlier detection accuracy: " + num2str(outlierAccuracy) + "% accuracy!");
disp("Variance direction accuracy: " + num2str(varianceAccuracy) + "% accuracy!");

standardDevs = zeros(m, 4);  % Save standard deviation of each location of each round. There are 4 locations, each of which flashes 6 pictures in each round
means = zeros(m, 4);  % Save the mean of each location of each round

for rows = 1 : m

	for cols = 1 : 4
	
		standardDevs(rows, cols) = std(faceNums(rows, cols, :));	% Take the standard deviation of each sequence shown in each location for every round (there are 4 total locations)
		means(rows, cols) = mean(faceNums(rows, cols, :));		% Take the mean of each sequence in each location for every round
	
	end

end

standardDevs % Display the standard deviations matrix
means % Display the mean matrix to consol

save('Outlier_Accuracy_Percentage.mat', 'outlierAccuracy');
save('Variance_Detection_Accuracy.mat', 'varianceAccuracy'); %saving all the data to files in folder for user
save('Standard_Deviations.mat', 'standardDevs');
save('means.mat', 'means');

cd('../../');  %% Go up to the original directory

function coloredImg = colorMyImage(img)
	
	% Note: Use first two commented lines if you want to change the button background's color instead of the text and the button border's
	%img = 255 - img;  % Invert the colors so the text is now white and the background is now black
        %background = img <= 100; % Find the black background with a threshold of 100

	background = img <= 200;  % Find the pixels of our background (the background is white). This is one channel of a grayscale image
	blueChannel = img;  % Create a new color layer, we're using blue
	blueChannel(background) = 255; % Change the new image's background to all white
	coloredImg = cat(3, img, img, blueChannel);  % Set the blue channel to activate
	
end
