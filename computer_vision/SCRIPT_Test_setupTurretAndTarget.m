%% SCRIPT_Test_setupTurretAndTarget
%
%   M. Kutzer, 28Mar2020

clear all
close all
clc

%% Set save media flag
saveMedia = false;

if saveMedia
    vidObj = VideoWriter('Test_setupTurretAndTarget.mp4','MPEG-4');
    open(vidObj);
end

%% Initialize FOV
h = createEW309RoomFOV('Ri080');

%% Define test parameters
walls    = {'NE','NW','SW','SE'};
n = 2*30;
ranges   = linspace(5,20,n).*(12*25.4);               % Test ranges
hBiases  = linspace(-6,6,n).*(12*25.4);             % Horizontal bias
vBiases  = linspace(-3,3,n).*(12*25.4);               % Vertical bias
hOffsets = linspace(-10,10,n).*(12*25.4);             % Horizontal offset
vOffsets = linspace(-3,3,n).*(12*25.4);               % Vertical offset
thetas   = linspace( deg2rad(-12),deg2rad(12),n );    % Turret angles

txt = nan;
%% Test walls
%{
hBias = 0;
vBias = -1*12*25.4;
hOffset = 0;
vOffset = 0;
theta = 0;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    % Define target specs
    targetSpecs.Diameter = 5*25.4;
    targetSpecs.HorizontalBias = hBias;
    targetSpecs.VerticalBias = vBias;
    targetSpecs.Color = 'Dark Orange';
    targetSpecs.Wobble = 0;
    
    % Define turret specs
    turretSpecs.HorizontalOffset = hOffset;
    turretSpecs.VerticalOffset = vOffset;
    turretSpecs.Angle = theta;
    
    if exist('h_a2r')
        delete(h_a2r);
    end
    [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
    drawnow;
    pause;
end
%}

%% Test walls and range shifts
hBias = 0;
vBias = -1*12*25.4;
hOffset = 0;
vOffset = 0;
theta = 0;
%range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    for range = ranges
        % Define target specs
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.HorizontalBias = hBias;
        targetSpecs.VerticalBias = vBias;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        % Define turret specs
        turretSpecs.HorizontalOffset = hOffset;
        turretSpecs.VerticalOffset = vOffset;
        turretSpecs.Angle = theta;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
        % Update information
        txt = dispTurretAndTargetInfo(txt,range,targetSpecs,turretSpecs);
        drawnow;
        if saveMedia
            % Grab frame for video
            frame = getframe(h.Figure);
            writeVideo(vidObj,frame);
        end
        
    end
end

%% Test walls and theta shifts
hBias = 0;
vBias = -1*12*25.4;
hOffset = 0;
vOffset = 0;
%theta = 0;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    for theta = thetas
        % Define target specs
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.HorizontalBias = hBias;
        targetSpecs.VerticalBias = vBias;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        % Define turret specs
        turretSpecs.HorizontalOffset = hOffset;
        turretSpecs.VerticalOffset = vOffset;
        turretSpecs.Angle = theta;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
        % Update information
        txt = dispTurretAndTargetInfo(txt,range,targetSpecs,turretSpecs);
        drawnow;
        if saveMedia
            % Grab frame for video
            frame = getframe(h.Figure);
            writeVideo(vidObj,frame);
        end
        
    end
end

%% Test walls and vertical offset shifts
hBias = 0;
vBias = -1*12*25.4;
hOffset = 0;
%vOffset = 0;
theta = 0;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    for vOffset = vOffsets
        % Define target specs
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.HorizontalBias = hBias;
        targetSpecs.VerticalBias = vBias;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        % Define turret specs
        turretSpecs.HorizontalOffset = hOffset;
        turretSpecs.VerticalOffset = vOffset;
        turretSpecs.Angle = theta;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
        % Update information
        txt = dispTurretAndTargetInfo(txt,range,targetSpecs,turretSpecs);
        drawnow;
        if saveMedia
            % Grab frame for video
            frame = getframe(h.Figure);
            writeVideo(vidObj,frame);
        end
        
    end
end

%% Test walls and horizontal offset shifts
hBias = 0;
vBias = -1*12*25.4;
%hOffset = 0;
vOffset = 0;
theta = 0;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    for hOffset = hOffsets
        % Define target specs
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.HorizontalBias = hBias;
        targetSpecs.VerticalBias = vBias;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        % Define turret specs
        turretSpecs.HorizontalOffset = hOffset;
        turretSpecs.VerticalOffset = vOffset;
        turretSpecs.Angle = theta;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
        % Update information
        txt = dispTurretAndTargetInfo(txt,range,targetSpecs,turretSpecs);
        drawnow;
        if saveMedia
            % Grab frame for video
            frame = getframe(h.Figure);
            writeVideo(vidObj,frame);
        end
        
    end
end

%% Test walls and vertical bias shifts
hBias = 0;
%vBias = -1*12*25.4;
hOffset = 0;
vOffset = 0;
theta = 0;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    for vBias = vBiases
        % Define target specs
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.HorizontalBias = hBias;
        targetSpecs.VerticalBias = vBias;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        % Define turret specs
        turretSpecs.HorizontalOffset = hOffset;
        turretSpecs.VerticalOffset = vOffset;
        turretSpecs.Angle = theta;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
        % Update information
        txt = dispTurretAndTargetInfo(txt,range,targetSpecs,turretSpecs);
        drawnow;
        if saveMedia
            % Grab frame for video
            frame = getframe(h.Figure);
            writeVideo(vidObj,frame);
        end
        
    end
end

%% Test walls and horizontal bias shifts
%ccc = 0;
vBias = -1*12*25.4;
hOffset = 0;
vOffset = 0;
theta = 0;
range = 15*12*25.4;
for w = 1:numel(walls)
    wall = walls{w};
    
    for hBias = hBiases
        % Define target specs
        targetSpecs.Diameter = 5*25.4;
        targetSpecs.HorizontalBias = hBias;
        targetSpecs.VerticalBias = vBias;
        targetSpecs.Color = 'Dark Orange';
        targetSpecs.Wobble = 0;
        
        % Define turret specs
        turretSpecs.HorizontalOffset = hOffset;
        turretSpecs.VerticalOffset = vOffset;
        turretSpecs.Angle = theta;
        
        if exist('h_a2r')
            delete(h_a2r);
        end
        [h,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
        % Update information
        txt = dispTurretAndTargetInfo(txt,range,targetSpecs,turretSpecs);
        drawnow;
        if saveMedia
            % Grab frame for video
            frame = getframe(h.Figure);
            writeVideo(vidObj,frame);
        end
        
    end
end

%% Close media
if saveMedia
    % Close video obj
    close(vidObj);
end