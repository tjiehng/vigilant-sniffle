% Scenario: a caller has reported a traffic accident taking place. Caller
%        is able to state general vicinity, but unable to pinpoint. UAV is
%       deployed to :
%
%   1) find vicinity of location(see traffic patterns, i.e. average vehicle 
%       velocity)
%   2) Pinpoint exact coordinate of accident for GPS beaming and
%       photography


clear all;
close all;
%% Phase 0: Reading File
fileID = fopen('jh2.txt','r');
vidObj = VideoReader('jh2.mp4');
frameRate = 60; % frame rate of the video feed
m = -0.341; % m and c are slope and intercepts obtained by comparing pixels of the widest and narrowest lane spacing
c = 510;
resY = 1080; % y-resolution of video feed

% grandArr and unArr both stores the coordinates of each ID into an array.
% But grandArr stores the IDs based on the presence of the ID in each
% timeframe.

[grandArr,unArr] = fileRead2(fileID,20,resY,m,c);
[unitVect,dirID] = direction(unArr); % unitVect is the direction of the overall traffic flow

plotTraj(unArr)


%% Phase 1: Locating location of congestion
frames = size(grandArr); % number of frames within the video
vectArr=[];x=0;y=0;

min=102; % threshold minimum pixel velocity for the ID to be flagged out as part of the congestion
perc=30; % percentile of IDs with pixel velocity under the threshold for frame to be flagged out as congestion

vectArr=[];
skipFrame = 15; % number of frames to skip forward to compare the change in coordinates for each ID to obtain pixel velocity for each ID
for frame = 1:frames(3)-skipFrame
    [vectArr,coorArr1,coorArr2,plotArr,clustCoorArr] = findCong(grandArr(:,:,frame),grandArr(:,:,frame+skipFrame),dirID,min,perc,120);
    if ~isempty(clustCoorArr) && (height(clustCoorArr)>2)
        break;
    end
end

vidObj.CurrentTime = frame/frameRate;
vidFrame = readFrame(vidObj); % vidFrame is the image in the video where the congestion has occured

if frame==frames(3)-1
    vectArr = [];
    disp("No Congestion found, drone to continue moving.")
end

% Plots the IDs in the current frame with the IDs of the subsequent frame
figure
hold on
scatter(coorArr1(:,2),coorArr1(:,3))
scatter(coorArr2(:,2),coorArr2(:,3),'filled','d')


%% Phase 2: Finding coordinate of bottleneck

figure
hold on
gscatter(plotArr(:,2),plotArr(:,3),plotArr(:,4)); % plots coordinates of ID based on whether their pixel velocity falls under the threshold

k = boundary(clustCoorArr(:,2),clustCoorArr(:,3),0.05); % create an enclosed boundary based on the coordinates of the IDs that fall under threshold pixel velocity
centCoor = [mean(clustCoorArr(k,2)) mean(clustCoorArr(k,3))]; % coordinates of the centre of the boundary
plot(clustCoorArr(k,2),clustCoorArr(k,3))
 
interpolationLine = [centCoor(1) centCoor(2)]; % interpolationLine can be extrapolated from centCoor with the gradient following unitVect
 
 for i=1:15
     interpolationLine = [interpolationLine; centCoor(1)+i*(unitVect(1))/5 centCoor(2)+i*unitVect(2)/5];
 end
 
plot(interpolationLine(:,1),interpolationLine(:,2)) % plots interpolation line

xIntArr = [];
yIntArr = [];

for p = 1:size(k)
    ind = k(p);
    xIntArr = [xIntArr; clustCoorArr(ind,2)];
    yIntArr = [yIntArr; clustCoorArr(ind,3)];
end

[xint,yint] = polyxpoly(interpolationLine(:,1),interpolationLine(:,2),xIntArr,yIntArr);

scatter(centCoor(1),centCoor(2),'x') % plots centCoor with 'x'
scatter(xint,yint,'o') % plots intersection with 'o'
hold off

yintconv = yint*c/(c-m*yint); % scaled down y-coordinate value to find the position of the bottleneck within the picture

showImage(xint,resY-yintconv,vidFrame) % plots the coordinates of the bottleneck as a circle in the frame 

