%% SCRIPT_Test_createCrosshair
% This script tests the crosshair alignment
%
%   M. Kutzer, 30Mar2020

clear all
close all
clc

%% Set save media flag
saveMedia = false;

if saveMedia
    vidObj = VideoWriter('Test_createCrosshair.mp4','MPEG-4');
    open(vidObj);
end

%% Initialize FOV
h = createEW309RoomFOV('Ri080');

%% Define test parameters
walls    = {'NE','NW','SW','SE'};
n = 2*30;
ranges   = linspace(5,20,n).*(12*25.4);	% Test ranges

%% Test walls and range shifts
txt = 'NaN';

hBias = 0;
vBias = h.H_b2c(2,4);   % Align the target with the camera
hOffset = -6*12*25.4;
vOffset = 0.5*25.4;
theta = 0;
%range = 15*12*25.4;
w = 3;
wall = walls{w};

for range = ranges
    % Define target specs
    targetSpecs.Diameter = 5*25.4;
    targetSpecs.HorizontalBias = hBias;
    targetSpecs.VerticalBias = vBias;
    targetSpecs.Color = 'w';
    targetSpecs.Wobble = 0;
    targetSpecs.Shape = 'Crosshair';
    
    % Define turret specs
    turretSpecs.HorizontalOffset = hOffset;
    turretSpecs.VerticalOffset = vOffset;
    turretSpecs.Angle = theta;
    
    if exist('h_a2r')
        delete(h_a2r);
    end
    [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);

    drawnow;
    if saveMedia
        % Grab frame for video
        frame = getframe(h.Figure);
        writeVideo(vidObj,frame);
    end
    
end

%% Close media
if saveMedia
    % Close video obj
    close(vidObj);
end