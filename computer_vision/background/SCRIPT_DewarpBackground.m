%% SCRIPT_DewarpBackground
% This script allows the user to manually define the affine transformation
% relating the "true" wall dimensions for Ri078 and Ri080 to the pixel
% coordinates associated with images captured by D. Evangelista. Then
% creates a figure for each room where each image is warped and placed in
% 3D space.
%
% This script produces:
%   3D Walls, Ri078.fig and
%   3D Walls, Ri080.fig
%
% Each figure contains the following hierarchy (discounting "triad.m" 
% lines) where tabs illustrate parent/child relationships:
%   Figure -------------------------- Tag: Figure, Ri0**             
%       Axes ------------------------ Tag: Axes, Ri0**
%           HgTransform ------------- Tag: Room Center Frame
%               HgTransform --------- Tag: West Corner Frame
%                   Light ----------- Tag: Light 1
%                   ...
%                   Light ----------- Tag: Light 8
%                   HgTransform ----- Tag: SW Wall Base Frame
%                       HgTransform - Tag: SW Wall Dewarp Frame
%                           Image --- Tag: SW Wall Image
%                   HgTransform ----- Tag: SE Wall Base Frame
%                       HgTransform - Tag: SE Wall Dewarp Frame
%                           Image --- Tag: SE Wall Image
%                   HgTransform ----- Tag: NE Wall Base Frame
%                       HgTransform - Tag: NE Wall Dewarp Frame
%                           Image --- Tag: NE Wall Image
%                   HgTransform ----- Tag: NW Wall Base Frame
%                       HgTransform - Tag: NW Wall Dewarp Frame
%                           Image --- Tag: NW Wall Image
%
%   EW309 - Guided Design Experience
%
%   M. Kutzer, 18Mar2020, USNA

clear all
close all
clc

%% Define file info
pname = 'data';
roomIDs = {'Ri078','Ri080'};
directionIDs = {'SW','SE','NE','NW'};

L = 8.40e3; % mm
W = 8.18e3; % mm
H = 2.83e3; % mm
wallDimensions{1,1} = [W,H]; % Ri078, SW Wall
wallDimensions{1,2} = [L,H]; % Ri078, SE Wall
wallDimensions{1,3} = [W,H]; % Ri078, NE Wall
wallDimensions{1,4} = [L,H]; % Ri078, NW Wall

L = 7.60e3; % mm
W = 8.50e3; % mm
H = 2.71e3; % mm
wallDimensions{2,1} = [W,H]; % Ri080, SW Wall
wallDimensions{2,2} = [L,H]; % Ri080, SE Wall
wallDimensions{2,3} = [W,H]; % Ri080, NE Wall
wallDimensions{2,4} = [L,H]; % Ri080, NW Wall

%% Select initialize plot
% Note that this section should not run if/when DigitizedWalls.mat is
% already available. This step is a bit timeconsuming. 
filename = 'DigitizedWalls.mat';
if ~isfile(filename)
    fig = figure;
    axs = axes('Parent',fig);
    
    fname = sprintf('%s_%s_Wall.jpg',roomIDs{1},directionIDs{1});
    fname = fullfile(pname,fname);
    im = imread(fname);
    
    img = imshow(im,'Parent',axs);
    hold(axs,'on');
    set(axs,'Visible','on');
    set(fig,'Units','Normalized','Position',[0,0,1,1]);
    
    offset = 300;
    res = size(im);
    x = [offset,res(2)-offset];
    y = [offset,res(1)-offset];
    xx = [x(1),x(2),x(2),x(1)];
    yy = [y(1),y(1),y(2),y(2)];
    
    verts = [xx; yy].';
    
    % Allow polygon to be dragged
    [ptc,plt] = dragPolygon(axs,verts);
    
    for i = 1:numel(roomIDs)
        for j = 1:numel(directionIDs)
            % Read image
            fname = sprintf('%s_%s_Wall.JPG',roomIDs{i},directionIDs{j});
            im = imread(fullfile(pname,fname));
            
            % Update image
            set(img,'CData',im);
            drawnow;
            
            title('Press "q" to save points.');
            waitForKey(fig,'q');
            
            X_m{i,j} = get(ptc,'Vertices').';
            set(ptc,'Vertices',verts);
            for k = 1:numel(xx)
                set(plt(k),'XData',xx(k),'YData',yy(k));
            end
        end
    end
    delete(fig);
    
    save(filename,'X_m','roomIDs','directionIDs','wallDimensions');
else
    fprintf('Loading previous dewarping points...\n');
    load(filename);
    fprintf('[COMPLETE]\n');
end

%% Define the wall-referenced coordinates

for i = 1:numel(roomIDs)
    fig(i) = figure('Name',sprintf('3D Walls, %s',roomIDs{i}),'Tag',sprintf('Figure, %s',roomIDs{i}));
    axs(i) = axes('Parent',fig(i),'Tag',sprintf('Axes, %s',roomIDs{i}));
    hold(axs(i),'on');
    daspect(axs(i),[1 1 1]);
    view(axs(i),3);
    
    % Define "west corner frame" in the lower west corner of the room
    hg_w(i) = triad('Parent',axs(i),'Scale',500,'Tag','West Corner Frame');
    
    W = wallDimensions{i,1}(1);
    L = wallDimensions{i,2}(1);
    X_w{i}(:,1) = [W; 0]; % SW
    X_w{i}(:,2) = [W; L]; % SE
    X_w{i}(:,3) = [0; L]; % NE
    X_w{i}(:,4) = [0; 0]; % NW
    
    H_b2w{i,1} =  Tx( X_w{i}(1,1) ) *  Ty( X_w{i}(2,1) ) * Rx(pi/2) * Ry( (2/2) * pi );
    H_b2w{i,2} =  Tx( X_w{i}(1,2) ) *  Ty( X_w{i}(2,2) ) * Rx(pi/2) * Ry( (3/2) * pi );
    H_b2w{i,3} =  Tx( X_w{i}(1,3) ) *  Ty( X_w{i}(2,3) ) * Rx(pi/2) * Ry( (0/2) * pi );
    H_b2w{i,4} =  Tx( X_w{i}(1,4) ) *  Ty( X_w{i}(2,4) ) * Rx(pi/2) * Ry( (1/2) * pi );
    
    % Add lights
    w = W/3;
    l = L/3;
    lightPos = [...
        (1/2)*w, (1/2)*l, H;... % Light 1
        (3/2)*w, (1/2)*l, H;... % Light 2
        (5/2)*w, (1/2)*l, H;... % Light 3
        (2/2)*w, (3/2)*l, H;... % Light 4
        (4/2)*w, (3/2)*l, H;... % Light 5
        (1/2)*w, (5/2)*l, H;... % Light 6
        (3/2)*w, (5/2)*l, H;... % Light 7
        (5/2)*w, (5/2)*l, H];   % Light 8
    for k = 1:size(lightPos,1)
        lgt(i,k) = light('Parent',hg_w(i),'Style','Local',...
            'Position',lightPos(k,:),'Tag',sprintf('Light %d',k));
    end
    
    for j = 1:numel(directionIDs)
        % Define the vertical points on the wall
        x = [0, wallDimensions{i,j}(1)];
        y = [0, wallDimensions{i,j}(2)];
        xx = [x(1),x(2),x(2),x(1)];
        yy = [y(2),y(2),y(1),y(1)];
        
        % Combine the vertical wall corner points
        X_b{i,j} = [xx; yy];
        X_b{i,j}(3,:) = 1;
        X_m{i,j}(3,:) = 1;
        
        % Calculate affine transform to warp from pixels to wall
        % coordinates
        A_m2b{i,j} = X_b{i,j} * pinv(X_m{i,j});
        tmp = eye(4);
        tmp(1:2,1:2) = A_m2b{i,j}(1:2,1:2);
        tmp(1:2,4)   = A_m2b{i,j}(1:2,3);
        tmp(3,3) = -1;  % Correction...
        A_m2b_3D{i,j} = tmp;
        
        % Load image
        fname = sprintf('%s_%s_Wall.jpg',roomIDs{i},directionIDs{j});
        fname = fullfile(pname,fname);
        im = imread(fname);
        
        % Define wall base frame
        hg_b(i,j) = triad('Parent',hg_w(i),'Scale',300,'Matrix',H_b2w{i,j},'Tag',sprintf('%s Wall Base Frame',directionIDs{j}));
        
        % Define wall dwarp frame
        hg_m(i,j) = triad('Parent',hg_b(i,j),'Matrix',A_m2b_3D{i,j},'Tag',sprintf('%s Wall Dewarp Frame',directionIDs{j}));
        
        % Plot image
        img = imshow(im,'Parent',axs(i));
        set(img,'Parent',hg_m(i,j),'Tag',sprintf('%s Wall Image',directionIDs{j}));
    end
    
    % Create base frame in the center of the room
    hg_o(i) = triad('Parent',axs(i),'Scale',300,'LineWidth',2,'Tag','Room Center Frame');
    H_w2o{i} = Tx(-W/2) * Ty(-L/2) * Tz(-1400); % Align with camera height
    set(hg_w(i),'Parent',hg_o(i),'Matrix',H_w2o{i});
    
    % Save figure
    set(axs(i),'XDir','Normal','YDir','Normal','ZDir','Normal');
    saveas(fig(i),sprintf('3D Walls, %s.fig',roomIDs{i}),'fig')
end
