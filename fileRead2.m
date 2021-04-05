% The function reads the the output text file and the maximum predicted number of vehicle
% IDs (maxIDs). The function then loops and finds frames that contains recognised
% IDs. After that, for each frame, it stores the x-,y-coordinates of the 
% midpoint of each vehicle and its corresponding ID. Each frame is stored
% in arr as a 3D matrix, where each 3rd dimension index represent the
% corresponding timeframe

% The output text file from YOLOv4 stores the min and max value of the x-
% and y- coordinates of the bounding box in each timeframe. The timeframes
% are arranged in ascending order, with the first time frame at the top.
% Each timeframe stores the coordinates of the bounding box with the ID of
% the vehicle, the classification and the bounding box coordinates as such:
% 
% Frame: # 1
% Tracker ID: 1, Class: car,  BBox Coords (xmin, ymin, xmax, ymax): (799, 797, 943, 984)
% FPS: 11.27

% m and c is used for scaling in the equation sy = my + c, where sy is the
% scaled value of the the y coordinate of the bounding box centroid.

% unArr store all the coordinates of arr in a list format, except without 
% timeframe or falseData. unArr stores the value of all the IDs and their
% corresponding bounding box in every timeframe, with all the bounding box
% in the first timeframe followed by the subsequent timeframes. The purpose
% of unArr is to plot the trajectory of the each ID.

function [arr, unArr] = fileRead2(fileID,maxIDs,resY,m,c)
text = textscan(fileID,'%s');
textArr = text{:,1};
arr = zeros(maxIDs,3,50); % initialise 3D matrix with 0
unArr = [];
k = 1;
i=1;

% In this loop, the loop checks if there are any bounding boxes/IDs within
% the recorded timeframe. If there is, the loop will clean the text file
% for that frame and
while i~=length(textArr)
    if i+3<length(textArr) && string(textArr{i}) == 'Frame'
        if string(textArr{i+3}) == 'FPS:'
            i=i+5;
        else
            i=i+3;
            tempArr = [];
            tick=1; %tick tracks the number of data filled in tempArr for each timeframe
            
            while string(textArr{i})=='Tracker'
                
            % the numbers of ID,xmin,xmax,ymin and ymax appear as strings
            % with ',' , '(', or ')'. Hence, these have to be removed to
            % extract the integers
                textArr{i+2}(length(textArr{i+2}))=[];
                textArr{i+13}(length(textArr{i+13}))=[];
                textArr{i+11}(length(textArr{i+11}))=[];
                textArr{i+11}(1)=[];
                textArr{i+14}(length(textArr{i+14}))=[];
                textArr{i+12}(length(textArr{i+12}))=[];
                
                % Finds the xcoor and ycoor as the centroid of the bounding
                % box of each id. Subsequently, the y-coordinates of ymin
                % and ymax of the bounding box shall be scaled up based on
                % their relative pixel pos;ition on the frame to symin and
                % symax respectively.
                
                id = str2num(textArr{i+2});
                xcoor = (str2num(textArr{i+13})- str2num(textArr{i+11}))/2+str2num(textArr{i+11});
                ymin = resY - str2num(textArr{i+12});
                ymax = resY - str2num(textArr{i+14});
                symin = ymin/((m*ymin+c)/c);
                symax = ymax/((m*ymax+c)/c);
                ycoor = (symin-symax)/2+symax;

                tempArr = [tempArr;id xcoor ycoor];
                unArr = [unArr;tempArr];
                i=i+15;
                tick=tick+1;
            end
            for tick = tick:maxIDs
                tempArr = [tempArr;'x' 0 0]; % fills in remaining array with 'x' and 0s
            end
            arr(:,:,k) = tempArr; % stores each frame as k in arr
            k=k+1;
            i=i+2;
        end
    else
        i=i+1;
    end
end
