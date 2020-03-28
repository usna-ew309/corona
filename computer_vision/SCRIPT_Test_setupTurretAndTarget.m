%% SCRIPT_Test_setupTurretAndTarget
%
%   M. Kutzer, 28Mar2020

clear all
close all
clc

%% Set save media flag
saveMedia = false;

%% Initialize FOV
h = createEW309RoomFOV('Ri080');

%% Define test parameters
walls = {'NE','NW','SW','SE'};
ranges = linspace(5,20,100).*(12*25.4);             % Test ranges
hOffsets = linspace(-10,10,100).*(12*25.4);         % Horizontal offsets
vOffsets = linspace(-3,3,100).*(12*25.4);           % Vertical offsets
thetas = linspace( deg2rad(-12),deg2rad(12),100 );   % Turret angles

%% Test walls
hOffset = 0;
vOffset = -1*12*25.4;
theta = 0;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    targetSpecs.Diameter = 5*25.4;
    targetSpecs.VerticalOffset = vOffset;
    targetSpecs.HorizontalOffset = hOffset;
    targetSpecs.Color = 'Dark Orange';
    targetSpecs.Wobble = 0;
    
    if exist('h_a2r')
        delete(h_a2r);
    end
    
    [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,theta,wall);
    drawnow;
    pause;
end

%% Test walls and range shifts
hOffset = 0;
vOffset = -1*12*25.4;
theta = 0;
for w = 1:numel(walls)
    wall = walls{w};
    for range = ranges
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.VerticalOffset = vOffset;
        targetSpecs.HorizontalOffset = hOffset;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,theta,wall);
        drawnow;
    end
end

%% Test walls and angle shifts
hOffset = 0;
vOffset = -1*12*25.4;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    for theta = thetas
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.VerticalOffset = vOffset;
        targetSpecs.HorizontalOffset = hOffset;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,theta,wall);
        drawnow;
    end
end