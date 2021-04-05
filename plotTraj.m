function plotTraj(arr)
    idArr = unique(arr(:,1));
    Legend = cell(length(idArr),1);
    
    figure
    hold on
    for i=1:length(idArr)
        tempArr = [];
        Legend{i} = num2str(idArr(i));
        for j=1:height(arr)
            if arr(j,1) == idArr(i)
                tempArr = [tempArr;arr(j,2) arr(j,3)];
            end
        end
        plot(tempArr(:,1),tempArr(:,2))
    end
    legend(Legend)
    
    
end