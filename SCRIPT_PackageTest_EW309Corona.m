%% SCRIPT_PackageTest_EW309Corona
% This script tests the required functions for the EW309 Corona Software
% Package.
%
%   M. Kutzer, 20Apr2020, USNA

clear all
close all
clc

%% Define Key Functions
% a. Ballistics:
%   01. getShotPattern.m ----------- IGNORE, used in (b.01)
% b. Computer Vision
%   01. getTargetImage.m ----------- TEST
%   02. getShotPatternImage.m ------ TEST
%   03. getCalibrationImage.m ------ TEST
% c. Turret-Movement Simulation
%   01. objFunc.m ------------------ TEST
%   02. sendCmdtoDcMotor.m --------- TEST
% d. Support
%   01. EW309coronaUpdate.m -------- IGNORE, required admin
%   02. EW309coronaVer.m ----------- TEST

%% d.02
EW309coronaVer;

%% b.01
range = 250;    % Range in centimeters
angle = pi/10;  % Angle in radians
im = getTargetImage(range,angle);

fig(1) = figure('Name','getTargetImage.m');
axs(1) = axes('Parent',fig(end));
obj(1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
drawnow;

%% b.02
range = 250;    % Range in centimeters
nShots = 10;    % Number of shots to take
im = getShotPatternImage(range,nShots);

fig(end+1) = figure('Name','getShotPatternImage.m');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
drawnow;

%% b.03
range = 250;    % Range in centimeters
im = getCalibrationImage(range);

fig(end+1) = figure('Name','getCalibrationImage.m');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
drawnow;

%% c.01
uniform_t     = linspace(0,60,500).';           % Uniform time  (made-up, not real, for test only)
uniform_PWM   = sin(2*pi * uniform_t./10);      % Uniform PWM   (made-up, not real, for test only)
uniform_theta = 2*pi*cos(2*pi * uniform_t./10); % Uniform angle (made-up, not real, for test only)
dat = [uniform_PWM, uniform_t, uniform_theta];

b = 5;          % Transfer function numerator   (made-up, not real, for test only)
a = 2;          % Transfer function pole        (made-up, not real, for test only)
delta = 0.25;   % Transfer function pole        (made-up, not real, for test only)
x = [b,a,delta];

metric = objFunc(x,dat)

%% c.02
cParams.Kp     = 2.0;
cParams.Ki     = 0.5;
cParams.Kd     = 1.0;
cParams.despos = pi/8;
timeIN = 0:0.1:10;

[SSE,time,theta,omega,duty_cycle,eint] = sendCmdtoDcMotor('closed',cParams,timeIN);
fig(end+1) = figure('Name','sendCmdtoDcMotor.m');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = plot(axs(end),time,theta,'b');
xlabel(axs(end),'Time (s)');
ylabel(axs(end),'Angle (radians)');
drawnow;