%% SCRIPT_RoomTour
clear all
close all
clc

%% Load Camera Calibration
load( fullfile('calibration','data','cameraParams_20200312-evangelista-1.mat') );

%% Present results
roomIDs = {'Ri078','Ri080'};

for i = 1:2
    
    % Simulate camera FOV
    imageResolution = [640,480];
    sim = initCameraSim(A_c2m,imageResolution,0.5*24*12*25.4);
    
    % Attempt "correction"
    pA(1:2) = [-84,-100]./fliplr(imageResolution);
    pA(3:4) = [1.37, 1.37];
    set(sim.Axes,'Position',pA);
    
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
    
    saveas(fig,[fname,'.png'],'png');
    
    % Move contents into camera FOV
    vidObj = VideoWriter([fname,'.mp4'],'MPEG-4');
    open(vidObj);
    
    set(hg_o,'Parent',sim.Axes);
    drawnow;
    delete(fig);
    
    for theta = linspace(0,2*pi,5*30)
        set(hg_o,'Matrix',Rx(pi/2)*Rz(theta));
        drawnow
        % Grab frame for video
        frame = getframe(sim.Figure);
        writeVideo(vidObj,frame);
    end
    % Close video obj
    close(vidObj);
    
    delete(sim.Figure);
end