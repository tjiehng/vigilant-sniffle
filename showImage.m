% The function creates a circle about a stated centre point of coordinates
% (xint,yint) and displays the circle on the stated frame of the video

function showImage(xint,yint,vidObj)
    figure
    hold on;
%     rectangle('Position',[xint-50,y-int-50,100,100],...
%   'Curvature',[0.8,0.4],...
%   'EdgeColor', 'r',...
%   'LineWidth', 3,...
%   'LineStyle','-')
    RGB = insertShape(vidObj,'circle',[xint yint 175],'LineWidth',5);
    imshow(RGB);

    hold off;

end