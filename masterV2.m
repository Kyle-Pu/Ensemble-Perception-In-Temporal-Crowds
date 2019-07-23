clear all; close all;

%% Obtaining User Input
Info = {'Initials', 'Full Name','Binary Gender [1=Male, 2=Female]','Age','Ethnicity', 'Handedness [1=Right, 2=Left]'};
dlg_title = 'Subject Information';
num_lines = 1;
subject_info = inputdlg(Info,dlg_title,num_lines);

existingData = load('subjectNumber.mat');
subjectNumber = existingData.subjectNumber + 1;
save('subjectNumber', 'subjectNumber');

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
    Screen('DrawText', window, 'Loading...', x_center*0.0069, y_center*1.9178); % Write text to confirm loading of images
    Screen('DrawText', window, [int2str(int16(i*100/147)) '%', 0.0069, y_center*1.9111]); % Write text to confirm percentage complete
    Screen('DrawText', window, 'Hello! Welcome to the Temporal Crowds Experiment.',x_center*0.6528, y_center) % User instructions page
    Screen('DrawText',window,'In the following screen, four random faces will be morphed, one of which is an outlier.',x_center*0.4194, y_center*1.0556); 
    Screen('DrawText',window,'Please identify which of the four faces is an outlier.',x_center*0.6646,y_center+50);
    Screen('DrawText',window,'Then, please specifify whether the variance was "High" or "Low" in the final slide.',x_center*0.4444, y_center*1.1667);
    Screen('Flip', window); % Display text
end

WaitSecs(2);

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
trialnum = 6; %number of images shown in one loop
round = 5;


for m = 1: round
regImages = randperm(total_Images, 4);  % Generate average morph for each of the 3 regular images in each scene
%regImages = randperm(total_Images - highRange*trialnum, 4);

%order = randperm(6);  % Random order to display morphs around the average for each of the 3 regular images in each scene

low_or_high = randi(2) %1 = low as outlier 2 = high as outlier
outlier = randi(4) %picking which of the four is the outlier

adjustedVals = zeros(1, 4); % Initialize outside loop so MATLAB doesn't have to copy values and resize the matrix each iteration

 
while abs(regImages(1) - regImages(2)) <= 5 || abs(regImages(1) - regImages(3)) <= 5 || abs(regImages(1) - regImages(4)) <= 5 || abs(regImages(2) - regImages(3)) <= 5 || abs(regImages(2) - regImages(4)) <= 5 || abs(regImages(3) - regImages(4)) <= 5
	regImages = randperm(total_Images, 4);
end

%% Display the Images
for i = 1 : trialnum

	lowRange = randi([3, 7]); %the variance number for low variance
 	highRange = randi([15, 20]); %the variance number for high variance

    if low_or_high == 1 %low as outlier
        
        for val = 1 : size(adjustedVals, 2)

            adjustedVals(val) = regImages(val) + highRange * i;
        end
        
        adjustedVals(outlier) = regImages(outlier) + lowRange * i;
        
    else %high as outlier
        
        for val = 1 : size(adjustedVals, 2)
            adjustedVals(val) = regImages(val) + lowRange * i;
        end
        
        adjustedVals(outlier) = regImages(outlier) + highRange * i;
        
    end
    
    
    for k = 1:4
        if adjustedVals(k) > total_Images
            adjustedVals(k) = adjustedVals(k) - total_Images;
        end
    end
    HideCursor();
    Screen('DrawTextures', window, tid(adjustedVals), [], xy_rect);  %% Use the default source and use our xy_rect matrix for the destination of the images
    DrawFormattedText(window,'+','center','center',[0 0 0]);
    Screen('Flip', window);
    WaitSecs(0.2);
    
    if i == 6
	        
        ShowCursor();
	SetMouse(450, 450, 0);
	
        %% Getting clicks and screen for clicks
        
        size_of_square_image = 302; %enter the size of one of the sides of one of the images/grid squares
        if outlier == 1
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
        xy_center = [x_center-size_of_square_image,y_center-size_of_square_image,x_center+size_of_square_image,y_center+size_of_square_image];
        makegrid = Screen('MakeTexture', window, clicking_grid);
        makesquare = Screen('MakeTexture', window, bluesquare);
        Screen('DrawTextures', window, makegrid, [], xy_center);
        DrawFormattedText(window,'Please click on the location of the outlier','center',100,[0 0 0]);
        Screen('Flip', window);
        square1 = [x_center-size_of_square_image, y_center, x_center, y_center+size_of_square_image];
        square2 = [x_center-size_of_square_image,y_center-size_of_square_image, x_center, y_center];
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
            elseif (x>square3(1) && x<square3(3) && y>square3(2) && y<square3(4))
                Screen('DrawTextures', window, makesquare, [], square3);
            elseif (x>square4(1) && x<square4(3) && y>square4(2) && y<square4(4))
                Screen('DrawTextures', window, makesquare, [], square4);
            end
            Screen('Flip', window);

            if (x>correct_area_in_image(1) && x<correct_area_in_image(3)) && (y>correct_area_in_image(2) && y<correct_area_in_image(4)) %if the person clicked on the correct outlier
                accuracy_storage(m, 2) = 1;%record correct click (accuracystorage(...,1) will display the numbers of the pictures shown in a single cell)
            else
                if (x>xy_center(1) && y>xy_center(2) && x<xy_center(3) && y<xy_center(4))
                    accuracy_storage(m, 2) = 0;%record bad click
                else
                    tf = 0;
                end
            end
        end
        WaitSecs(.5);
        
        %% Getting click for high/low variance part thingy doob
        
        dimensions_of_buttons = [137, 103];
        xy_high_center = [x_center-dimensions_of_buttons(1), y_center-dimensions_of_buttons(2)-150, x_center+dimensions_of_buttons(1), y_center+dimensions_of_buttons(2)-150];
        xy_low_center = [x_center-dimensions_of_buttons(1), y_center-dimensions_of_buttons(2)+150, x_center+dimensions_of_buttons(1), y_center+dimensions_of_buttons(2)+150];
        High_button = rgb2gray(imread('High Button.png'));
        High_button = High_button(:, :, 1);
        Low_button = rgb2gray(imread('Low Button.png'));
        Low_button = Low_button(:, :, 1);
        highButtonColored = colorMyImage(High_button);
        lowButtonColored = colorMyImage(Low_button);
        tff = 0;
        looping_again = 0;
        
        while looping_again == 0
            xx=0;
            yy=0;
            userchoice_variance = 0;
            
            while tff == 0
                DrawFormattedText(window,'Was the variance \n of this outlier set \n high or low?','center',100,[0 0 0]);
                [xx,yy,buttons]=GetMouse(); %gets coordinates of the button press when it is done
                
                if (xx > xy_high_center(1) && xx < xy_high_center(3) && yy > xy_high_center(2) && yy < xy_high_center(4))
                    makebuttonlayout_high = Screen('MakeTexture', window, highButtonColored);
                else
                    makebuttonlayout_high = Screen('MakeTexture', window, High_button);
                end
                
                if (xx > xy_low_center(1) && xx < xy_low_center(3) && yy > xy_low_center(2) && yy < xy_low_center(4))
                    makebuttonlayout_low = Screen('MakeTexture', window, lowButtonColored);
                else
                    makebuttonlayout_low = Screen('MakeTexture', window, Low_button);
                end
                
                Screen('DrawTextures', window, makebuttonlayout_high, [], xy_high_center);
                Screen('DrawTextures', window, makebuttonlayout_low, [], xy_low_center);
                Screen('Flip', window);
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
                tff = 0; %going back into the "is the user clicking?" loop once the looping_again while loop is repeated
                looping_again = 0;
            end
        end
        if userchoice_variance == low_or_high
            accuracy_storage(m, 3) = 1;
        else
            accuracy_storage(m, 3) = 0;
        end
        
	accuracy_storage(m, 1) = adjustedVals(1) + "-" + adjustedVals(2) + "-" + adjustedVals(3) + "-" + adjustedVals(4); % Save morphing sequence in the first column for each trial's results

        WaitSecs(0.5);
        WaitSecs();
    end
end
    if mod(m, 2) == 0
	breakTime = 180; % 3 minute break time	

	while breakTime >= 0
		Screen('DrawText', window, [num2str(breakTime) 'seconds left of break...', 250, 250]); % Write text to confirm percentage complete
		Screen('Flip', window); % Display text
		WaitSecs(1);
		breakTime = breakTime - 1;
	end	

    end
end

%% Saving User's Results
if ~isdir('Results')
    mkdir('Results');
end
nameID = char(upper(subject_info(1))); % Take the initials (first cell in subject_info) and make it uppercase so our formatting is consistent. Also convert the cell to a character array (a string)
dirName = num2str(subjectNumber) + "_" + nameID;

if ~isdir(dirName)
	mkdir(dirName);
end

cd(dirName);
save('Results.mat', 'accuracy_storage');
save('SubjectInfo.mat', 'subject_info');

cd('../../');  %% Go up to the original directory

Screen('CloseAll');

accuracyStorage
disp(sum(sum(accuracy_storage == 1)) / 2 / m * 100);

function coloredImg = colorMyImage(img)
	
	% Note: Use first two commented lines if you want to change the button background's color instead of the text and the button border's
	%img = 255 - img;  % Invert the colors so the text is now white and the background is now black
        %background = img <= 100; % Find the black background with a threshold of 100

	background = img <= 200;  % Find the pixels of our background (the background is white). This is one channel of a grayscale image
	blueChannel = img;  % Create a new color layer, we're using blue
	blueChannel(background) = 255; % Change the new image's background to all white
	coloredImg = cat(3, img, img, blueChannel);  % Set the blue channel to activate
	
end
