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
fnameBase = 'cameraParams_20200312-evangelista-';
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
    load(fname);
    
    all_A_c2m{i} = A_c2m;
    all_H_g2c{i} = H_g2c;
    
    fprintf('Calibration Data %d:\n\t A_c2m = \n',i);
    fprintf('\t\t[ %10.6f, %10.6f, %10.6f ]\n\t\t[ %10.6f, %10.6f, %10.6f ]\n\t\t[ %10.6f, %10.6f, %10.6f ]\n',transpose( A_c2m ));
end

%% Attempt to *easily* replicate camera FOV
fig = figure('Name','Approximate FOV');
axs = axes('Parent',fig);
daspect(axs,[1 1 1]);
hold(axs,'on');
xlim([-imageResolution(1),imageResolution(1)]);
ylim([-imageResolution(2),imageResolution(2)]);
zlim([0,all_H_g2c{1}{1}(3,4) * 2]);

% Set parameters
set(fig,'Renderer','OpenGL');
set(axs,'ZDir','Reverse','XDir','Reverse');

% Setup for saving correct image dimensions
dpi = 96;
hpix = imageResolution(1);
vpix = imageResolution(2);
%hdims = [hpix/vpix,hpix/hpix];  % dimensions for choosing horizontal figure size
%vdims = [vpix/vpix,vpix/hpix];  % dimensions for choosing vertical figure size
set(axs,'Units','Normalized','Position',[0,0,1,1]);
set(fig,'Units','Pixels','Position',[0,0,hpix,vpix]);
% set(fig,'Units','normalized','Position',[0,0,min(hdims),min(vdims)]);
% set(fig,'PaperUnits','Inches','PaperPosition',[0,0,hpix/dpi,vpix/dpi]);
% set(fig,'InvertHardCopy','off');


i = 1;  % Data set
j = 3;  % Extrinsic parameter

hAOV = intrinsics2AOV(all_A_c2m{i});
camproj(axs,'Perspective');
camva(axs,hAOV)
campos(axs,zeros(1,3));

%camtarget(axs,[0,0,all_H_g2c{i}{j}(3,4)]);
camtarget(axs,[0,0,24*12*25.4]);
camup(axs,[0,-1,0]);

hg_g = plotCheckerboard(boardSize,squareSize,{'k','w'});
set(hg_g,'Parent',axs,'Matrix',all_H_g2c{i}{j});

frm = getframe(fig);
im = frm.cdata;

