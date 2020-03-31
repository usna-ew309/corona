%% SCRIPT_CreateCameraFOV
% This script tests camera view and image dewarping and saves the camera
% FOV figures.
%
% This script produces:
%   Camera FOV, Ri078.fig and
%   Camera FOV, Ri080.fig
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
clear all
close all
clc

%% Set save media flag
saveMedia = false;

%% Load Camera Calibration
load( fullfile('calibration','data','cameraParams_20200312-evangelista-1.mat') );

%% Present results
roomIDs = {'Ri078','Ri080'};

for i = 1:2
    
    % Simulate camera FOV
    imageResolution = [640,480];
    sim = initCameraSim(A_c2m,imageResolution,0.5*24*12*25.4);
    
    % Update tags
    set(sim.Figure,'Tag',sprintf('Figure, FOV %s',roomIDs{i}));
    set(sim.Axes,  'Tag',sprintf(  'Axes, FOV %s',roomIDs{i}));
    
    % Attempt "correction"
    %{
    pA(1:2) = [-84,-100]./fliplr(imageResolution);
    pA(3:4) = [1.37, 1.37];
    set(sim.Axes,'Position',pA);
    %}
    
    % Adjust x and y limits?
    xlim(sim.Axes,xlim(sim.Axes)*5);
    ylim(sim.Axes,ylim(sim.Axes)*5);
    zlim(sim.Axes,zlim(sim.Axes)*3);
    
    % Load the room model
    fname = sprintf('3D Walls, %s',roomIDs{i});
    open( fullfile('background',[fname,'.fig']) );
    drawnow;
    axs = gca;
    hg_o = get(axs,'Children');
    fig = get(axs,'Parent');
    
    if saveMedia
        vidObj = VideoWriter([fname,'.mp4'],'MPEG-4');
        open(vidObj);
        
        saveas(fig,[fname,'.png'],'png');
    end
    
    % Move contents into camera FOV
    set(hg_o,'Parent',sim.Axes);
    drawnow;
    delete(fig);
 
    for theta = linspace(0,2*pi,5*30)
        set(hg_o,'Matrix',Rx(pi/2)*Rz(theta));
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
    saveas(sim.Figure,sprintf('Camera FOV, %s.fig',roomIDs{i}),'fig');
    
    delete(sim.Figure);
end