%% SCRIPT_CreateCameraFOV
% This script tests camera view and image dewarping.
%
% Each figure contains the following hierarchy (discounting "triad.m" 
% lines) where tabs illustrate parent/child relationships:
%   Figure -------------------------- Tag: Figure, FOV Ri0**             
%       Axes ------------------------ Tag: Axes, FOV Ri0**
%           HgTransform ------------- Tag: Room Center Frame
%               HgTransform --------- Tag: West Corner Frame
%                   Light ----------- Tag: Light 1
%                   ...
%                   Light ----------- Tag: Light 8
%                   HgTransform ----- Tag: SW Wall Base Frame
%                       HgTransform - Tag: SW Wall Dewarp Frame
%                           Image --- Tag: SW Wall Image
%                   HgTransform ----- Tag: SE Wall Base Frame
%                       HgTransform - Tag: SE Wall Dewarp Frame
%                           Image --- Tag: SE Wall Image
%                   HgTransform ----- Tag: NE Wall Base Frame
%                       HgTransform - Tag: NE Wall Dewarp Frame
%                           Image --- Tag: NE Wall Image
%                   HgTransform ----- Tag: NW Wall Base Frame
%                       HgTransform - Tag: NW Wall Dewarp Frame
%                           Image --- Tag: NW Wall Image
%
%   EW309 - Guided Design Experience
%
%   M. Kutzer, 18Mar2020, USNA

% Updates
%   30Mar2020 - Removed "correction" to better align the target center with
%               the center of the image when the target is aligned with the
%               camera z-axis
%   02Apr2020 - Updated to incorporate create3Dfov.m breakout.

clear all
close all
clc

%% Set save media flag
saveMedia = false;

%% Set replace figures flag
replaceFigures = false;

%% Present results
roomIDs = {'Ri078','Ri080'};
for i = 1:2
    h = createEW309RoomFOV(roomIDs{i});
    fig = h.Figure;
    centerfig(fig);
    set(fig,'Visible','on');
    
    if saveMedia
        vidObj = VideoWriter([fname,'.mp4'],'MPEG-4');
        open(vidObj);
        
        saveas(fig,[fname,'.png'],'png');
    end
    
    h_r2b = h.Frames.h_r2b;
    
    for theta = linspace(0,2*pi,5*30)
        set(h_r2b,'Matrix',Rz(theta));
        drawnow
        
        if saveMedia
            % Grab frame for video
            frame = getframe(sim.Figure);
            writeVideo(vidObj,frame);
        end
    end
    
    if saveMedia
        % Close video obj
        close(vidObj);
    end
    
    drawnow;
    
    delete(fig);
end