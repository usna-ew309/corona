%% SCRIPT_Test_getShotPattern
clear all
close all
clc

%% Set save media flag
saveMedia = false;

%% Define test ranges
ranges = 150:50:450;    % ranges in centimeters (~5ft to ~15ft)
nShots = 10;

%% Get images
for i = 1:numel(ranges)
    range = ranges(i);
    im{i} = getShotPattern(range,nShots);
    
    fig(i) = figure('Name',sprintf('Range: %.2f',range));
    axs(i) = axes('Parent',fig(i));
    img(i) = imshow(im{i},'Parent',axs(i));
    
    hold(axs(i),'on');
    set(axs(i),'Visible','on');
    xlabel(axs(i),'x (pixels)');
    ylabel(axs(i),'y (pixels)');
    title(axs(i),sprintf('ShotPattern %.1fcm.png',range));
    
    plt(i,1) = plot(axs(i),size(im{i},2)*[0,1],size(im{i},1)*(1/2)*[1,1],'g');
    plt(i,2) = plot(axs(i),size(im{i},2)*(1/2)*[1,1],size(im{i},1)*[0,1],'g');
    drawnow;
    
    if saveMedia
        fname = sprintf('Img_ShotPattern_%.1fcm.png',range);
        imwrite(im{i},fname,'PNG');
        fname = sprintf('Fig_ShotPattern_%.1fcm.png',range);
        saveas(fig(i),fname,'png');
    end
end