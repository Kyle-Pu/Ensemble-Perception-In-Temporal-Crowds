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

%% Determining Location on Screen to Display Images
xVector = linspace(850, window_w - 850, 2);
yVector = linspace(450, window_h - 450, 2)
[x, y] = meshgrid(xVector, yVector);

cd('Face_Stimuli');

%% Transparency Mask to Filter Excess Stimuli
Mask_Plain = imread('mask.png');
Mask_Plain = Mask_Plain(:, :, 1); % Only need one color channel of a grayscale image

%% Parameter Settings
total_Images = 4; % Number of images in each scene

%% Loading Textures Into tid
tid = zeros(1, total_Images);  % Hold textures

for i = 1 : total_Images
    
    tmp_bmp = imread("num2str(i)" + ".png");
    tmp_bmp(:, :, 4) = Mask_Plain;
    
    Screen('DrawText', window, 'Loading...', x_center, y_center-25); 
    Screen('DrawText', window, [int2str(int16(i*100/147)) '%'], x_center, y_center+25);
     
    % Make texture of the stimuli matrix
    tid(i) = Screen('MakeTexture', window, tmp_bmp);
    
end

image_size = size(tmp_bmp);
w_img =  image_size(2); % image width
h_img =  image_size(1); % image height

xy_rect = [x(:)' - w_img / 2; y(:)' - h_img / 2; x(:)' + w_img / 2; y(:)' + h_img / 2];

% Select random oranges from the image index vector "num_oranges" using
% function "randsample"
rand_images = randsample(total_Images, total_Images); 

Screen('DrawTextures', window, tid(rand_images), [], xy_rect);
Screen('Flip', window);
WaitSecs(5);
 
Screen('CloseAll');

