%% SCRIPT_Process_cameraParams
% This script parses *.mat files containing cameraParams (camera
% parameters) returned from cameraCalibrator.mat. This functions produces:
%
%   A_c2m - the intrinsic matrix associated with the camera parameters.
%
%   H_g2c - a cell array of the extrinsics associated with each
%           checkerboard pattern accepted during the calibration process.
%
% Intrinsic and extrinsic parameters are appended to the existing
% cameraParms file; and a calibration result image is produced in both
% figure (*.fig) and image (*.png) form.
%
%   EW309 - Guided Design Experience
%
%   M. Kutzer, 16Mar2020, USNA

clear all;
close all;
clc

%% Define base filename and number of calibration files
pname = 'data';
fnameBase = 'cameraParams_20200312-evangelista-';
cnameBase = '20200312-evangelista-';
nFiles = 3;

%% Define calibration checkerboard parameters
% NOTE: These must match the checkerboard used to define cameraParams for 
%       the visualizations to appear properly. These paramters are solely
%       for visualization purposes.
boardSize = [6,7];  % width (+x) by height (+y)
squareSize = 19.05; % millimeters
imageResolution = [640,480];

%% Load and process data

for i = 1:nFiles
    % Clear existing calibration data
    clearvars cameraParams estimationErrors
    
    % Load file
    fname = sprintf('%s%d.mat',fnameBase,i);
    fname = fullfile(pname,fname);
    fprintf('Loading %s...',fname);
    load(fname);
    fprintf('[COMPLETE]\n');
    
    % Create visualization
    fig = figure('Name',fname);
    axs = axes('Parent',fig);
    view(axs,3);
    daspect(axs,[1 1 1]);
    hold(axs,'on');
    xlabel(axs,'x (mm)');
    ylabel(axs,'y (mm)');
    zlabel(axs,'z (mm)');
    
    % Plot Pico iCubie
    % TODO - create drawPicoICubie
    % hg_c = drawPicoICubie(axs);
    hg_c = triad('Parent',axs,'Scale',25.4,'LineWidth',2,'AxisLabels',{'x_c','y_c','z_c'});
    
    fprintf('Processing %s...',fname);
    % Intrinsic matrix
    A_c2m = transpose( cameraParams.IntrinsicMatrix );  
    % Extrinsic matrices
    for j = 1:size(cameraParams.RotationMatrices,3)
        H_g2c{j} = ...
            [transpose( cameraParams.RotationMatrices(:,:,j) ),...
             transpose( cameraParams.TranslationVectors(j,:) );...
             0,0,0,1];
         
         hg_g(j) = plotCheckerboard(boardSize,squareSize,{'k','w'});
         set(hg_g(j),'Parent',hg_c,'Matrix',H_g2c{j});
    end
    
    % Plot field of view
    axis(axs,'tight');
    zz = zlim(axs);
    pFOV = plotCameraFOV(A_c2m,zz(2),imageResolution);
    drawnow;
    axis(axs,'tight');

    % Append intrinsic and extrinsic data
    save(fname,'A_c2m','H_g2c','-append');
    
    % Save figure
    saveas(fig, sprintf('%s%d.fig',fnameBase,i), 'fig');
    saveas(fig, sprintf('%s%d.png',fnameBase,i), 'png');
    
    fprintf('[COMPLETE]\n');
end

%% Compare intrinsics
clearvars -except fnameBase nFiles imageResolution boardSize squareSize
for i = 1:nFiles
    % Clear existing calibration data
    clearvars cameraParams estimationErrors
    
    % Load file
    fname = sprintf('%s%d.mat',fnameBase,i);
    fname = fullfile(pname,fname);
    load(fname);
    
    all_A_c2m{i} = A_c2m;
    all_H_g2c{i} = H_g2c;
    
    fprintf('Calibration Data %d:\n\t A_c2m = \n',i);
    fprintf('\t\t[ %10.6f, %10.6f, %10.6f ]\n\t\t[ %10.6f, %10.6f, %10.6f ]\n\t\t[ %10.6f, %10.6f, %10.6f ]\n',transpose( A_c2m ));
end

%% Attempt to *easily* replicate camera FOV
A_sim2tru_ALL = zeros(3,3);
i = 1;  % Data set
for j = 3:5  % Extrinsic parameter
    
    % Simulate camera FOV
    sim = initCameraSim(A_c2m,imageResolution,24*12*25.4);
    % Simulate checkerboard
    hg_g = plotCheckerboard(boardSize,squareSize,{'k','w'});
    set(hg_g,'Parent',sim.Axes,'Matrix',all_H_g2c{i}{j});
    hideTriad(hg_g);
    
    % Attempt "correction"
    pA(1:2) = [-84,-100]./fliplr(imageResolution);
    pA(3:4) = [1.37, 1.37];
    set(sim.Axes,'Position',pA);
    
    % Snap image of simulated FOV
    drawnow;
    frm = getframe(sim.Figure);
    imSim = frm.cdata;
    
    % Load the "true" image
    % NOTE THAT I ONLY INCLUDED A FEW OF THESE FOR REFERENCE
    cname = sprintf('%s%d',cnameBase,i);
    iname = sprintf('im%03d.png',j);
    imTru = imread( fullfile(pname,cname,iname) );
    
    % Compare to "truth"
    simPoints = detectCheckerboardPoints(imSim);
    truPoints = detectCheckerboardPoints(imTru);
    
    % Delete simulation
    delete(sim.Figure);
    
    % Compare images
    fig = figure('Units','Normalized','Position',[0,0,0.705,0.389]);
    centerFigure(fig);
    
    axs(1) = subplot(1,2,1);
    imshow(imSim);
    hold on
    plot(simPoints(:,1),simPoints(:,2),'og');
    plot(truPoints(:,1),truPoints(:,2),'xr');
    
    axs(2) = subplot(1,2,2);
    imshow(imTru);
    hold on
    plot(simPoints(:,1),simPoints(:,2),'og');
    plot(truPoints(:,1),truPoints(:,2),'xr');
    
    set(axs,'Visible','on');
    
    % Calculate affine adjustment
    simPoints = simPoints.';
    simPoints(3,:) = 1;
    truPoints = truPoints.';
    truPoints(3,:) = 1;
    A_sim2tru = truPoints * pinv(simPoints);
    
    A_sim2tru_ALL = A_sim2tru_ALL + A_sim2tru;
    drawnow;
    
    oname = sprintf('%s_%s',cname,iname);
    oname = fullfile(pname,oname);
    saveas(fig, oname, 'png');

end
A_sim2tru_ALL = A_sim2tru_ALL./3