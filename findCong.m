% This function takes arr1, the array of a timestep, and arr2, an array of
% a later timestep. The function takes the difference in the positioning of
% the vehicles from the arrays. For each vehicle ID, the function
% calculates the magnitude of the velocity based on the timestep arrays.
% After that, each ID and their corresponding magnitude is stored in array,
% A or B depending on the unit vector of the ID. 
%
% After this, the function reads each non-empty A and B array and check if
% the set percentile value falls under the min value. vectArr will store
% the array with the lowest percentile value. x and y represents the unit
% vector that represents the stored A,B,C or D array in vectArr.
%
% Since read array(arr1,arr2) contains dummy variables, falseRead is the ID of
% the dummy variables. coorArr1 and coorArr2 returns the array of the 
% coordinates of each ID at arr1 and arr2 respectively without any 
% dummy variables.

% Inputs:
% arr1 : raw timestep 1 array with falseRead IDs
% arr2 : raw next timestep 2 array with falseRead IDs
% dirID : array that matches IDs and their corresponding directions

% Outputs:
% coorArr1 : arr1 without falseRead IDs
% coorArr2 : arr2 without falseRead IDs
% A and B : temporary array after sorting IDs and velocities based on
% direction
% vectArr : array of IDs and their velocities in the chosen direction
% oppArr : array of IDs in the opposite direction
% plotArr : array used for plotting, where the last element of the row
% represents the group that each point belongs to (clust,vect, or coor)
% clustCoorArr : coordinates of ID that has pixel velocity under the threshold 
% A and B: arrays of ID and 

function [vectArr,coorArr1,coorArr2,plotArr,clustCoorArr] = findCong(arr1,arr2,dirID,min,percentile,falseRead)
vectArr = [];
oppArr = [];
coorArr1 = [];
coorArr2 = [];
plotArr = [];
clustCoorArr = [];

A = [];
B = [];

%% Attributing speed properties for each ID
for i=1:height(arr1)
    for j=1:height(arr2)
        tempArr = [];
        if arr1(i,1) == arr2(j,1) && arr1(i,1)~=falseRead
            dx = arr2(j,2) - arr1(i,2); % difference in pixels in x direction
            dy = arr2(j,3) - arr1(i,3); % difference in pixels in y direction
            mag = sqrt(dx^2+dy^2); % magnitude of pixel velocity
            vect = [dx dy];
            unitV = vect./norm(vect);
            tempArr =[arr1(i,1) dx dy mag unitV];
            coorArr1 = [coorArr1;arr1(i,1) arr1(i,2) arr1(i,3)];
            coorArr2 = [coorArr2;arr2(j,1) arr2(j,2) arr2(j,3)];
            vectArr = [vectArr;tempArr];
            
            % classify the IDs into matrices based on direction
            idx = find(dirID(:,1)==arr1(i,1));
            if dirID(idx,3)==1
                A = [A;tempArr];
            else
                B = [B;tempArr];
            end
            
            break;
        end
    end
end

%% Counting and Comparing which direction, A or B, has more cars in congestion
if ~isempty(A) && ~isempty(B) && prctile(A(:,4),percentile)<min && prctile(B(:,4),percentile)<min
    countA = sum(A(:,4)<min);
    countB = sum(B(:,4)<min);
    if countA > countB
        vectArr = A;
        oppArr = B;
    else
        vectArr = B;
        oppArr = A;
    end
elseif ~isempty(A) && prctile(A(:,4),percentile)<min
    vectArr = A;
    oppArr = B;
elseif ~isempty(B) && prctile(B(:,4),percentile)<min
    vectArr = B;
    oppArr = A;
end

%% Classifying whether ID belongs in opposite direction, under min speed or above min speed)
if ~isempty(vectArr) && ~isempty(coorArr1)
    
    for i=1:height(coorArr1)
        carID = coorArr1(i,1);
        
        if ~isempty(oppArr) && ismember(carID,oppArr(:,1))
            plotArr = [plotArr;coorArr1(i,:) 3];
        else
            if vectArr(find(vectArr(:,1)==carID),4)<min
                plotArr = [plotArr;coorArr1(i,:) 1];
                clustCoorArr = [clustCoorArr;coorArr1(i,:)];
            else
                plotArr = [plotArr;coorArr1(i,:) 2];
            end
        end
    end
    
end
    
end