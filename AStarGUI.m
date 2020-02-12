% Project created by Krystof Hes as part of Erasmus programme 
% Universidad de Sevilla
% 1.cuatrimestre 2019/2020

% Project description: A* search algorithm implementation in MATLAB
% This part is followed by an implementation of the algorithm in Python and
% ROS. See: https://github.com/krystofh/robot_navigation_project

close all; clear all;
addpath('maps');
src = "maps/Map4-2.png";
img = imread(src);
map = loadMap(src);

% Program parameters
% use bitmap = 1 to work in a direct mode where you enter the start and end
% position in the variables start_pos and end_pos by hand
% use smallMap = 1 if the map is very small (eg. 12x12) and needs to be
% enlarged in order to view it. In this case put a scale such as 30
bitmap = 1;
scale = 30;  
smallMap = 1;

if(~bitmap)
    info = "Pick a start point with left-click and end point with right-click";
    fprintf(info);
    map_fig = figure('Name', 'A* path search');
    imshow(img); title("Pick 2 points:");
    % Get Start and end positions by clicking the points in the map
    [i,j] = getpts;
    start_pos = [round(j(1)), round(i(1))]; % invert x and y (convert into [row, column] format)
    end_pos = [round(j(2)), round(i(2))];

    % Mark start and end point
    marked_img = markPoint(img,scale, start_pos, 0);
    marked_img = markPoint(marked_img,scale, end_pos, 1);
    ax1 = gca;                   % save current axes
    cla reset;                   % reset to refresh the image
    imshow(marked_img, 'Parent', ax1);  % refresh the image
    info = sprintf('Calculating the path... [%i %i] -> [%i %i]', start_pos(1), start_pos(2), end_pos(1), end_pos(2));
    title(info);
    pause(1); % pause 1 s for the window to show before starting the calculations
else
    % map = [ 0 0 0 0 1 0 0 0 0 0;
    %         0 0 0 0 1 0 0 0 0 0;
    %         0 0 0 0 1 0 0 1 1 1;
    %         0 0 0 0 0 0 0 0 0 0;
    %         0 0 0 0 1 0 0 1 1 1;
    %         0 0 0 0 1 0 0 0 0 0];
%     map = [0 0 0 0 0;
%        0 0 0 1 0;
%        1 1 0 1 0;
%        0 0 0 1 0;
%        0 1 0 1 0;
%        0 1 0 0 0;
%        0 1 0 1 0;
%        0 0 0 0 0];
     start_pos = [1 1];
     end_pos = [12 1];
end

% Check that the points are not obstacles or outside the map (needed when manual input without clicking)
if((start_pos(1)>size(map,1)) || (start_pos(2)>size(map,2)) || (end_pos(1)>size(map,1)) || (end_pos(2)>size(map,2)))
    disp("Start or end point out of the map bounds");
elseif(start_pos(1)<=0 || start_pos(2)<=0 || end_pos(1)<=0 || end_pos(2)<=0)
    disp("Start and end point must be positive and greater or equals 1");
elseif(map(start_pos(1),start_pos(2)) == 1) || map(end_pos(1),end_pos(2))
    disp("Start or end point is an obstacle!");
else
    
    % Calculate the path according to A*
    path = AStarPath(map, start_pos, end_pos);
    disp(path);

    % If the image is to be enlarged in order to view something, use
    % different function (from the matrix it makes a bigger image)
    info = sprintf('Path [%i %i] -> [%i %i]:', start_pos(1), start_pos(2), end_pos(1), end_pos(2));
    if smallMap==1
        dispImageEnlarged(map, scale, path, info);
    else
        %close(map_fig)
        dispImage(img, scale, path, info);
    end
end

% Mark the start or end point and return the image (parameter 'type': 0-start, 1-end)
function new_image = markPoint(img, magnify, point, type)
    new_image = img;  % create a copy of the image 
    i = point(1);
    j = point(2);
    switch type
        case 0   % Mark start point         
            new_image(i-magnify:i+magnify, j-magnify:j+magnify, 1)= 3;  % r
            new_image(i-magnify:i+magnify,j-magnify:j+magnify, 2)= 252;  % g
            new_image(i-magnify:i+magnify,j-magnify:j+magnify, 3)= 11;  % b 
        case 1  % Mark end point
            new_image(i-magnify:i+magnify, j-magnify:j+magnify, 1)= 214;  % r
            new_image(i-magnify:i+magnify, j-magnify:j+magnify, 2)= 36;  % g
            new_image(i-magnify:i+magnify, j-magnify:j+magnify, 3)= 36;  % b  
        otherwise
            disp("Unsupported point type parameter, use 0-start 1-end");
    end   
end

% Displays the image with the start point (green), end point (red) and path (blue)
% Because the path is only one px, in order to see something, set up
% magnify parameter which is the number of px to be added in -x,+x and
% -y,+y directions to let the 1 px grow into a rectangle
% E.g. 1 start px is a rectangle of 3x3 px if magnify = 1

function dispImage(img, magnify, path, strTit)
    start_pos = path(1, :);
    end_pos = path(size(path,1), :);
    [M, N] = size(img);
    
    % Mark path
    for idx = 2:size(path,1)-1       
        i = path(idx,1);
        j = path(idx,2);
        img(i-magnify:i+magnify, j-magnify:j+magnify, 1)= 36;  % r
        img(i-magnify:i+magnify, j-magnify:j+magnify, 2)= 155;  % g
        img(i-magnify:i+magnify, j-magnify:j+magnify, 3)= 214;  % b     
    end
    
    % Mark Start
    i = start_pos(1);
    j = start_pos(2);
    img(i-magnify:i+magnify, j-magnify:j+magnify, 1)= 3;  % r
    img(i-magnify:i+magnify,j-magnify:j+magnify, 2)= 252;  % g
    img(i-magnify:i+magnify,j-magnify:j+magnify, 3)= 11;  % b 
    
    % Mark End
    i = end_pos(1);
    j = end_pos(2);
    img(i-magnify:i+magnify, j-magnify:j+magnify, 1)= 214;  % r
    img(i-magnify:i+magnify, j-magnify:j+magnify, 2)= 36;  % g
    img(i-magnify:i+magnify, j-magnify:j+magnify, 3)= 36;  % b    
    
    % Show image
    figure(); 
    imshow(uint8(img)); title(strTit);  
end

%  dispImage(map, scale, path, "Map");
function dispImageEnlarged(img, magnify, path, strTit)
    start_pos = path(1, :);
    end_pos = path(size(path,1), :);
    [M, N] = size(img);
    imgBig = zeros(M*magnify, N*magnify,3);
    for i=1:M
       for j=1:N
           if img(i,j)==1  % obstacles black
               % leave as 0;
           else
               % free space white
               imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 1)= 255;  % r
               imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 2)= 255;  % g
               imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 3)= 255;  % b 
           end
       end
    end
    % Mark Start
    i = start_pos(1);
    j = start_pos(2);
    imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 1)= 3;  % r
    imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 2)= 252;  % g
    imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 3)= 11;  % b 
    
    % Mark End
    i = end_pos(1);
    j = end_pos(2);
    imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 1)= 214;  % r
    imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 2)= 36;  % g
    imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 3)= 36;  % b    
    
    % Mark path
    for idx = 2:size(path,1)-1       
        i = path(idx,1);
        j = path(idx,2);
        imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 1)= 36;  % r
        imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 2)= 155;  % g
        imgBig((i-1)*magnify+1:(i*magnify),(j-1)*magnify+1:(j*magnify), 3)= 214;  % b     
    end
    
    % Show image
    figure(); 
    imshow(uint8(imgBig)); title(strTit);  
end

% Load an image and convert it into an occupancy grid
% 0 = free space, 1 = obstacle
function map = loadMap(src)
    img = imread(src);
    img = rgb2gray(img);  % convert to grayscale
    img = img>127;        % convert to binary image (thresholding)
    [M, N] = size(img);
    for i = 1:M   % invert 1 and 0 so that 1 = obstacle and 0=free space
        for j = 1:N
            if(img(i,j)==0)
                img(i,j) = 1;
            else
                img(i,j) = 0;
            end
        end
    end
    map = img;
end