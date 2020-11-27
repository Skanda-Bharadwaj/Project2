clear; clc;

%%
pathToCam1Parameters = '../Data/vue2CalibInfo.mat';
pathToCam2Parameters = '../Data/vue4CalibInfo.mat';
pathToMocapJoints    = '../Data/Subject4-Session3-Take4_mocapJoints.mat';
pathToVideo1         = '../Data/Subject4-Session3-24form-Full-Take4-Vue2.mp4';
pathToVideo2         = '../Data/Subject4-Session3-24form-Full-Take4-Vue4.mp4';

%%
load(pathToCam1Parameters);
load(pathToCam2Parameters);
load(pathToMocapJoints);
vue2video = VideoReader(pathToVideo1);
vue4video = VideoReader(pathToVideo2);

%%
cnt = 0;
mocapFrames = [457, 1339, 12272, 15452, 19971];
test = struct();
for frame = mocapFrames
    
    cnt = cnt + 1;
    
    %
    x = mocapJoints(frame, :, 1); 
    y = mocapJoints(frame, :, 2); 
    z = mocapJoints(frame, :, 3);
    
    %
    worldCoord3DPoints = [x;y;z;ones(1,12)];
    cam1PixelCoords = project3DTo2D(vue2, worldCoord3DPoints);
    cam2PixelCoords = project3DTo2D(vue4, worldCoord3DPoints);
    
    %
%     plotJointPosition(vue2video, frame, cam1PixelCoords);
%     plotJointPosition(vue4video, frame, cam2PixelCoords);
    
    %
    recovered3DPoints = reconstruct3DFrom2D(vue2, cam1PixelCoords, vue4, cam2PixelCoords);
    [EpipolarLines1, EpipolarLines2] = findEpipolarLines(worldCoord3DPoints, vue2, cam1PixelCoords, vue4, cam2PixelCoords);
%     err = sum((recovered3DPoints - worldCoord3DPoints).^2)'
    
%     plotEpipolarLines(vue2video, frame, EpipolarLines1, cam1PixelCoords);
%     plotEpipolarLines(vue4video, frame, EpipolarLines2, cam2PixelCoords);

    test(cnt).Frame = frame;
    test(cnt).worldCoord3DPoints = worldCoord3DPoints(1:3, 1);
    test(cnt).cam1PixelCoords = cam1PixelCoords(1:2, 1);
    test(cnt).cam2PixelCoords = cam2PixelCoords(1:2, 1);
    test(cnt).recovered3DPoints = recovered3DPoints(1:3, 1);
    test(cnt).EpipolarLines1 = EpipolarLines1(1:3, 1);
    test(cnt).EpipolarLines2 = EpipolarLines2(1:3, 1);
end

function plotJointPosition(video, mocapFnum, cam_coordinates)

    video.CurrentTime = (mocapFnum-1)*(50/100)/video.FrameRate; 
    vidFrame = readFrame(video);

    figure;
    image(vidFrame);
    hold on;
    scatter(cam_coordinates(1,:), cam_coordinates(2,:));

end

function plotEpipolarLines(video, mocapFnum, camEpipoleLines, cam_coordinates)

    
    video.CurrentTime = (mocapFnum-1)*(50/100)/video.FrameRate; 
    vidFrame = readFrame(video);
    x = linspace(1,size(vidFrame, 2), 50);
    figure;
    image(vidFrame);
    hold on;
    for i = 1:length(camEpipoleLines)
        l = camEpipoleLines(:,i);
        y = -(l(1)*x + l(3))/l(2);
        plot(x,y);
        scatter(cam_coordinates(1,i), cam_coordinates(2,i), 'o');
    end
    hold off;

end