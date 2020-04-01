%% SCRIPT_Test_getTargetImage
%
%   M. Kutzer, 31Mar2020, USNA
clear all
close all
clc

%% Test consistency
%{
range = 300;    % Target range (cm)
angle = 0;   % Turret angle (cm)
targetSpecs = createTargetSpecs;    % Prompt user for target specifications

for i = 1:3
    im{i} = getTargetImage(range,angle,targetSpecs);
    figure; imshow(im{i})
end

for i = 2:numel(im)
    delta_im = double(im{i}) - double(im{i-1});
    figure; imagesc(delta_im);
end
%}

%% Test angles
%{
targetSpecs = createTargetSpecs(12.7);

fig = figure;
axs = axes;
im = getTargetImage(150,0,targetSpecs);
img = imshow(im,'Parent',axs);
txt = text(axs,100,100,'Angle = 0','Color','w');
for range = linspace(150,600,5)
    for angle = linspace(-25,25,50)
        im = getTargetImage(range,deg2rad(angle),targetSpecs);
        
        set(img,'CData',im);
        set(txt,'String',sprintf('Range = %.2f\nAngle = %.2f',range,angle));
        drawnow
    end
end
%}

%% Option 1 - Specify range only
range = 150;    % Target range (cm)

im = getTargetImage(range,[]);
figure; imshow(im);

%% Option 2 - Specify range and angle
range = 200;    % Target range (cm)
angle = pi/8;   % Turret angle (radians)

im = getTargetImage(range,[]);
figure; imshow(im);

%% Option 3 - Specify range and prompt user to specify target
range = 250;    % Target range (cm)
targetSpecs = createTargetSpecs;    % Prompt user for target specifications

im = getTargetImage(range,[],targetSpecs);
figure; imshow(im);


%% Option 4 - Specify range and angle, and prompt user to specify target
range = 300;    % Target range (cm)
angle = pi/8;   % Turret angle (radians)
targetSpecs = createTargetSpecs;    % Prompt user for target specifications

im = getTargetImage(range,[],targetSpecs);
figure; imshow(im);
