% This function calculates the direction of the traffic flow in a photo by
% comparing the coordinates of bounding box of each ID at the first frame
% where the ID first appear and at the last frame when the ID is seen. A
% vector is computed for each ID by comparing these 2 frames. The funtion
% then averages all the vector to obtain the general flow of the traffic

function [unitVect , directID] = direction(unArr)
    id = [];
    unitVectArr = []; %  [id dx dy]
    directID = [];
    
    for i = 1:size(unArr)
        if ~any(id(:)==unArr(i,1))
            for j = size(unArr):-1:1
                if unArr(i,1) == unArr(j,1)
                    dx = unArr(j,2) - unArr(i,2);
                    dy = unArr(j,3) - unArr(i,3);
                    unitVectArr = [unitVectArr;unArr(i,1) dx dy];
                    id = [id;unArr(i,1)];
                    
                    if dx < 0
                        a = -1;
                    else
                        a = 1;
                    end
                    
                    if dy < 0 
                        b = -1;
                    else
                        b = 1;
                    end
                    
                    directID = [directID; unArr(i,1) a b];
                    break;
                end
            end
        else
            continue
        end
    end
    
    unitVect = [mean(unitVectArr(:,2)) mean(unitVectArr(:,3))]; 

end