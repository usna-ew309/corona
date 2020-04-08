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
%   02. getTargetImageUpdate.m ----- TEST
%   03. getShotPatternImage.m ------ TEST (2x)
%   04. EW309coronaPerforanceEval -- TEST
%   05. getCalibrationImage.m ------ TEST
% c. Turret-Movement Simulation
%   01. objFunc.m ------------------ TEST
%   02. sendCmdtoDcMotor.m --------- TEST
% d. Support
%   01. EW309coronaUpdate.m -------- IGNORE, required admin
%   02. EW309coronaVer.m ----------- TEST

%% d.02
% Test function
EW309coronaVer;

%% Display status information
fprintf('RUNNING: "%s"\n',mfilename);
fprintf('%s, MATLAB %s, %s\n',computer,version('-release'),datestr(now));

%% b.01
% Test function
range = 250;    % Range in centimeters
angle = pi/10;  % Angle in radians
im = getTargetImage(range,angle); % <---------------------- FUNCTION CALL -

% Plot result
fig(1) = figure('Name','getTargetImage.m');
axs(1) = axes('Parent',fig(end));
obj(1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
hold(axs(end),'on');
pltH(1) = plot(axs(end),size(im,2)*[0.0,1.0],size(im,1)*[0.5,0.5],':g','LineWidth',1.5);
pltV(1) = plot(axs(end),size(im,2)*[0.5,0.5],size(im,1)*[0.0,1.0],':g','LineWidth',1.5);
drawnow;

% Compare image sizes 
%   This is for debugging purposes only. The following code does not use 
%   the standard functionality of the EW309corona package. Please do not 
%   obses and stress about the following lines of code. 
% -> Manually get image
figTMP = findobj(0,'Type','figure','Tag','Figure, FOV Ri080');
frm = getframe(figTMP);
imTMP = frm.cdata;
% -> Compare sizes
fprintf('\tb.01\n');
fprintf('\t\tFunction Image Size: [%3d,%3d,%3d]\n',size(im));
fprintf('\t\t   Frame Image Size: [%3d,%3d,%3d]\n',size(imTMP));

%% b.02
% Test function
relative_angle = -0.5*angle;
im = getTargetImageUpdate(relative_angle); % <------------- FUNCTION CALL -

% Plot result
fig(end+1) = figure('Name','getTargetImageUpdate.m');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
hold(axs(end),'on');
pltH(end+1) = plot(axs(end),size(im,2)*[0.0,1.0],size(im,1)*[0.5,0.5],':g','LineWidth',1.5);
pltV(end+1) = plot(axs(end),size(im,2)*[0.5,0.5],size(im,1)*[0.0,1.0],':g','LineWidth',1.5);
drawnow;

% Compare image sizes 
%   This is for debugging purposes only. The following code does not use 
%   the standard functionality of the EW309corona package. Please do not 
%   obses and stress about the following lines of code. 
% -> Manually get image
figTMP = findobj(0,'Type','figure','Tag','Figure, FOV Ri080');
frm = getframe(figTMP);
imTMP = frm.cdata;
% -> Compare sizes
fprintf('\tb.02\n');
fprintf('\t\tFunction Image Size: [%3d,%3d,%3d]\n',size(im));
fprintf('\t\t   Frame Image Size: [%3d,%3d,%3d]\n',size(imTMP));

%% b.03.01
nShots = 10;    % Number of shots
im = getShotPatternImage(nShots); % <---------------------- FUNCTION CALL -

% Plot result
fig(end+1) = figure('Name','getShotPatternImage.m, Single Input');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
hold(axs(end),'on');
pltH(end+1) = plot(axs(end),size(im,2)*[0.0,1.0],size(im,1)*[0.5,0.5],':g','LineWidth',1.5);
pltV(end+1) = plot(axs(end),size(im,2)*[0.5,0.5],size(im,1)*[0.0,1.0],':g','LineWidth',1.5);
drawnow;

% Compare image sizes 
%   This is for debugging purposes only. The following code does not use 
%   the standard functionality of the EW309corona package. Please do not 
%   obses and stress about the following lines of code. 
% -> Manually get image
figTMP = findobj(0,'Type','figure','Tag','Figure, FOV Ri080');
frm = getframe(figTMP);
imTMP = frm.cdata;
% -> Compare sizes
fprintf('\tb.03.01\n');
fprintf('\t\tFunction Image Size: [%3d,%3d,%3d]\n',size(im));
fprintf('\t\t   Frame Image Size: [%3d,%3d,%3d]\n',size(imTMP));

%% b.03.01.01
% Test function
EW309coronaPerforanceEval; % <----------------------------- FUNCTION CALL -

%% b.03.02
% Test function
range = 250;    % Range in centimeters
nShots = 10;    % Number of shots to take
im = getShotPatternImage(range,nShots); % <---------------- FUNCTION CALL -

% Plot result
fig(end+1) = figure('Name','getShotPatternImage.m, Dual Input');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
hold(axs(end),'on');
pltH(end+1) = plot(axs(end),size(im,2)*[0.0,1.0],size(im,1)*[0.5,0.5],':g','LineWidth',1.5);
pltV(end+1) = plot(axs(end),size(im,2)*[0.5,0.5],size(im,1)*[0.0,1.0],':g','LineWidth',1.5);
drawnow;

% Compare image sizes 
%   This is for debugging purposes only. The following code does not use 
%   the standard functionality of the EW309corona package. Please do not 
%   obses and stress about the following lines of code. 
% -> Manually get image
figTMP = findobj(0,'Type','figure','Tag','Figure, FOV Ri080');
frm = getframe(figTMP);
imTMP = frm.cdata;
% -> Compare sizes
fprintf('\tb.03.02\n');
fprintf('\t\tFunction Image Size: [%3d,%3d,%3d]\n',size(im));
fprintf('\t\t   Frame Image Size: [%3d,%3d,%3d]\n',size(imTMP));

%% b.05
% Test function
range = 250;    % Range in centimeters
im = getCalibrationImage(range); % <----------------------- FUNCTION CALL -

% Plot result
fig(end+1) = figure('Name','getCalibrationImage.m');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = imshow(im,'Parent',axs(end));
set(axs(end),'Visible','on');
xlabel(axs(end),'x (pixels)');
ylabel(axs(end),'y (pixels)');
hold(axs(end),'on');
pltH(end+1) = plot(axs(end),size(im,2)*[0.0,1.0],size(im,1)*[0.5,0.5],':g','LineWidth',1.5);
pltV(end+1) = plot(axs(end),size(im,2)*[0.5,0.5],size(im,1)*[0.0,1.0],':g','LineWidth',1.5);
drawnow;

% Compare image sizes 
%   This is for debugging purposes only. The following code does not use 
%   the standard functionality of the EW309corona package. Please do not 
%   obses and stress about the following lines of code. 
% -> Manually get image
figTMP = findobj(0,'Type','figure','Tag','Figure, FOV Ri080');
frm = getframe(figTMP);
imTMP = frm.cdata;
% -> Compare sizes
fprintf('\tb.05\n');
fprintf('\t\tFunction Image Size: [%3d,%3d,%3d]\n',size(im));
fprintf('\t\t   Frame Image Size: [%3d,%3d,%3d]\n',size(imTMP));

%% c.01
% Define dat
uniform_t     = linspace(0,60,500).';           % Uniform time  (made-up, not real, for test only)
uniform_PWM   = sin(2*pi * uniform_t./10);      % Uniform PWM   (made-up, not real, for test only)
uniform_theta = 2*pi*cos(2*pi * uniform_t./10); % Uniform angle (made-up, not real, for test only)
dat = [uniform_PWM, uniform_t, uniform_theta];
% Define x
b = 5;          % Transfer function numerator   (made-up, not real, for test only)
a = 2;          % Transfer function pole        (made-up, not real, for test only)
delta = 0.25;   % Transfer function pole        (made-up, not real, for test only)
x = [b,a,delta];

% Test function
metric = objFunc(x,dat); % <------------------------------- FUNCTION CALL -

% Compare variable sizes
fprintf('\tc.01\n');
fprintf('\t\t     "x" Variable Size: [%3d,%3d]\n',size(x));
fprintf('\t\t   "dat" Variable Size: [%3d,%3d]\n',size(dat));
fprintf('\t\t"metric" Variable Size: [%3d,%3d]\n',size(metric));
fprintf('\t\t"metric" Variable Value: %.4f\n',metric);

%% c.02
% Define cParams
cParams.Kp     = 2.0;
cParams.Ki     = 0.5;
cParams.Kd     = 1.0;
cParams.despos = pi/8;
% Define time
timeIN = 0:0.1:10;

% Test function  % v--------------------------------------- FUNCTION CALL -
[SSE,ts,timeOUT,theta,omega,duty_cycle,eint] = sendCmdtoDcMotor('closed',cParams,timeIN);

% Plot result
fig(end+1) = figure('Name','sendCmdtoDcMotor.m');
axs(end+1) = axes('Parent',fig(end));
obj(end+1) = plot(axs(end),timeOUT,theta,'b');
xlabel(axs(end),'Time (s)');
ylabel(axs(end),'Angle (radians)');
hold(axs(end),'on');
pltH(end+1) = plot(axs(end),size(im,2)*[0.0,1.0],size(im,1)*[0.5,0.5],':g','LineWidth',1.5);
pltV(end+1) = plot(axs(end),size(im,2)*[0.5,0.5],size(im,1)*[0.0,1.0],':g','LineWidth',1.5);
drawnow;

% Compare variable sizes
fprintf('\tc.02\n');
fprintf('\t\t    "timeIN" Variable Size: [%3d,%3d]\n',size(timeIN));
fprintf('\t\t   "timeOUT" Variable Size: [%3d,%3d]\n',size(timeOUT));
fprintf('\t\t     "theta" Variable Size: [%3d,%3d]\n',size(theta));
fprintf('\t\t"duty_cycle" Variable Size: [%3d,%3d]\n',size(duty_cycle));
fprintf('\t\t      "eint" Variable Size: [%3d,%3d]\n',size(eint));
fprintf('\t\t       "SSE" Variable Size: [%3d,%3d]\n',size(SSE));
fprintf('\t\t        "ts" Variable Size: [%3d,%3d]\n',size(ts));
fprintf('\t\t       "SSE" Variable Value: %.4f\n',SSE);
fprintf('\t\t   "ts.time" Variable Value: %.4f\n',ts.time);
fprintf('\t\t  "ts.index" Variable Value: %d\n',ts.index);