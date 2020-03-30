%% SCRIPT_Test_getCalibrationImage
clear all
close all
clc

%% Define test ranges
ranges = 150:50:450;    % ranges in centimeters (~5ft to ~15ft)

%% Get images
for i = 1:numel(ranges)
    range = ranges(i);
    im{i} = getCalibrationImage(range);
    
    fig(i) = figure('Name',sprintf('Range: %.2f',range));
    axs(i) = axes('Parent',fig(i));
    img(i) = imshow(im{i},'Parent',axs(i));
    
    hold(axs(i),'on');
    plt(i,1) = plot(axs(i),size(im{i},2)*[0,1],size(im{i},1)*(1/2)*[1,1],'g');
    plt(i,2) = plot(axs(i),size(im{i},2)*(1/2)*[1,1],size(im{i},1)*[0,1],'g');
    drawnow;
    
    %fname = sprintf('CalibrationGrid_%.1fcm.png',range);
    %imwrite(im{i},fname,'PNG');
end