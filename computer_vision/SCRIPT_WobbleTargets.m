%% SCRIPT_WobbleTargetsFOV
% This script tests a variety of settings including "material" and lighting
% height to adjust the target color variability.
%
%   M. Kutzer, 27Mar2020

clear all
close all
clc

%% Set save media flag
saveMedia = false;

%% Initialize FOV
h = createEW309RoomFOV('Ri080');

%% Define shape and color options
shapes = {'Circle','Square','Random Rectangle','Equilateral Triangle',...
    'Random Triangle','Random Polygon'};
colors = {'Bright Yellow','Bright Pink','Bright Green','Dark Orange',...
    'Light Orange','Dark Red','Light Red'};

%% Plot colors
diameter = 457.2;

scale = 0.65;
[X,Z] = meshgrid(-1:1:1,-1:1,1);
X = scale*X;
Z = scale*Z;
for i = 1:numel(colors)
    [h_a2r(i),ptc(i)] = createTarget(h.Frames.h_r2b,'Circle',diameter,colors{i});
    
    x(i) = 0.20*h.Room_Width*X(i);%(2*rand - 1);
    y(i) = h.Room_Length/2 - diameter;
    z(i) = 0.30*h.Room_Height*Z(i);%(2*rand - 1);
    
    wobble = deg2rad(10);
    h_a2r(i) = placeTarget(h_a2r(i),[x(i),y(i),z(i)],0,wobble);
    txt(i) = text(x(i)+diameter/2,y(i)-diameter/2+1,z(i)-diameter/2,colors{i},...
        'Parent',h.Frames.h_r2b,'Color','w','VerticalAlignment','baseline');
end

%% Tweak parameters
%set(ptc,'FaceLighting','flat'); % {'none','flat','gouraud'}
% set(ptc,'SpecularColorReflectance',0.8);
% set(ptc,'SpecularExponent',1e8);
% set(ptc,'SpecularStrength',0.8);
materials = {'shiny','dull','metal'};

p0 = get(h.Lights,'Position');
for matIDX = 1:numel(materials)
    materialSTR = materials{matIDX}; % {'shiny','dull','metal'}
    material(ptc,materialSTR);
    
    %% Move the lights away
    for hFT = [0,15,30,45]
        delta_H = hFT*12*25.4;

        for dH = delta_H
            for i = 1:numel(p0)
                p{i,1} = p0{i,1};
                p{i,1}(3) = p{i,1}(3)- h.Light_Height + dH;
                set(h.Lights(i),'Position',p{i,1});
            end
            %set(h.Figure,'Name',sprintf('Light Height ~%05d Feet',round( (p{1}(3)/25.4)/12 )));
            drawnow
        end
        
        %% Wobble the targets
        if saveMedia
            vidObj = VideoWriter(sprintf('TargWbl_%s_LgtHt%02dft.mp4',materialSTR,round(hFT)),'MPEG-4');
            open(vidObj);
        end
        
        wobble = deg2rad(10);
        vXY = [1;0;0;0];
        phiALL = linspace(0,4*pi,30*10);
        
        for phi = phiALL
            v_wobble = Rz(phi)*vXY;
            v_wobble(4) = [];
            v_wobble = v_wobble./norm(v_wobble);
            r_wobble = wedge( wobble * v_wobble );
            R_wobble = expm( r_wobble );
            H_wobble = eye(4);
            H_wobble(1:3,1:3) = R_wobble;
            
            for i = 1:numel(h_a2r)
                h_a2r(i) = placeTarget(h_a2r(i),[x(i),y(i),z(i)],0,H_wobble);
            end
            drawnow;
            
            if saveMedia
                % Grab frame for video
                frame = getframe(h.Figure);
                writeVideo(vidObj,frame);
            end
        end
        
        if saveMedia
            % Close video obj
            close(vidObj);
        end
        
    end
end