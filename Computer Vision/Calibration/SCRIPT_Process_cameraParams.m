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
clearvars -except fnameBase nFiles
for i = 1:nFiles
    % Clear existing calibration data
    clearvars cameraParams estimationErrors
    
    % Load file
    fname = sprintf('%s%d.mat',fnameBase,i);
    load(fname);
    
    all_A_c2m{i} = A_c2m;
    
    fprintf('Calibration Data %d:\n\t A_c2m = \n',i);
    fprintf('\t\t[ %10.6f, %10.6f, %10.6f ]\n\t\t[ %10.6f, %10.6f, %10.6f ]\n\t\t[ %10.6f, %10.6f, %10.6f ]\n',transpose( A_c2m ));
end
