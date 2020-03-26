%% SCRIPT_Test_moveTurretFOV
clear all
close all
clc

%% Initialize FOV
h = createEW309RoomFOV('Ri080');

%% 
diameter = 300;
[h_a2r,ptc] = drawTarget(h.Frames.h_r2b,'Circle',diameter,'Bright Green');

x = 0.20*h.Room_Width*(2*rand - 1);
y = h.Room_Length/2 - 1;
z = 0.30*h.Room_Height*(2*rand - 1);

wobble = pi/4;
h_a2r = placeTarget(h_a2r,[x,y,z],0,0);

%% Tweak parameters
set(ptc,'FaceLighting','gouraud'); % {'none','flat','gouraud'}
set(ptc,'SpecularColorReflectance',0.9);
set(ptc,'SpecularExponent',10);
set(ptc,'SpecularStrength',0.9);

return

%% Populate the North East Wall with targets
shapes = {'Circle','Square','Random Rectangle','Equilateral Triangle',...
    'Random Triangle','Random Polygon'};
colors = {'Bright Yellow','Bright Pink','Bright Green','Dark Orange',...
    'Light Orange','Dark Red','Light Red'};

nTargets = 10;
diameter = 300;

sIDXs = mod(1:nTargets,numel(shapes)) + 1; randi([1,numel(shapes)],1,nTargets);
cIDXs = mod(1:nTargets,numel(colors)) + 1;%randi([1,numel(colors)],1,nTargets);
for i = 1:numel(sIDXs)
    [h_a2r,ptc] = drawTarget(h.Frames.h_r2b,shapes{ sIDXs(i) },diameter,colors{ cIDXs(i) });
    
    x = 0.20*h.Room_Width*(2*rand - 1);
    y = h.Room_Length/2 - 1;
    z = 0.30*h.Room_Height*(2*rand - 1);
    h_a2r = placeTarget(h_a2r,[x,y,z],0,0);
end
return

%% Load camera parameters
load( fullfile('calibration','data','cameraParams_20200312-evangelista-1.mat'),'A_c2m' );

%% Load "3D Room 
fname = sprintf('3D Walls, %s.fig',h.Room);
open( fullfile('background',fname) );
drawnow;
axs = gca;
view(axs,[-37,60]);
drawnow;

h_b2r = triad('Parent',axs,'Scale',250,'LineWidth',2);
h_c2b = triad('Parent',h_b2r,'Scale',250,'LineWidth',2,'Matrix',(h.H_b2c)^-1);

p = plotCameraFOV(A_c2m,h.Room_Length,[640,480]);
set(p,'Parent',h_c2b);

%% Test rotation
theta = linspace(0,4*pi,500);

for i = 1:numel(theta)
    h = moveTurretFOV(h,theta(i));

    set(h_b2r,'Matrix',Rz(theta(i)));
    
    drawnow;
end

%% Test translation
phi = linspace(0,2*pi,500);
x = 0.80*(h.Room_Width/2) * sin(phi);
y = 0.80*(h.Room_Length/2) * sin(4*phi);

plt = plot(axs,0,0,'m','LineWidth',1.5);

for i = 1:numel(x)
    h = moveTurretFOV(h,x(i),y(i));
    set(plt,'XData',x(1:i),'YData',y(1:i));
    
    set(h_b2r,'Matrix',Tx(x(i))*Ty(y(i)));
    
    drawnow;
end