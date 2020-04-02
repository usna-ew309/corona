function create3Dwalls(varargin)
%CREATE3DWALLS generates "3D Walls, Ri078.fig" and "3D Walls, Ri080.fig"
%   CREATE3DWALLS saves the designated figures as files
%
%   CREATE3DWALLS(saveFiles) allows the user to specify whether or not to
%   save the *.fig files.
%       saveFiles = {[true],false} where true results in saved files.
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
%   M. Kutzer, 02Apr2020, USNA

%% Check input(s)
narginchk(0,1);

if nargin == 1
    saveFiles = varargin{1};
else
    saveFiles = true;
end

%% Provide status
fprintf('Generating 3D wall figures...\n');

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
fprintf('\tLoading dewarping points...');
load(filename);
fprintf('[COMPLETE]\n');

%% Define the wall-referenced coordinates
for i = 1:numel(roomIDs)
    str = sprintf('3D Walls, %s',roomIDs{i});
    fprintf('\tCreating "%s"...',str);
    fig = figure('Name',str,'Tag',sprintf('Figure, %s',roomIDs{i}));
    set(fig,'Visible','off');
    axs = axes('Parent',fig,'Tag',sprintf('Axes, %s',roomIDs{i}));
    hold(axs,'on');
    daspect(axs,[1 1 1]);
    view(axs,3);
    
    % Define "west corner frame" in the lower west corner of the room
    hg_w = triad('Parent',axs,'Scale',500,'Tag','West Corner Frame');
    
    W = wallDimensions{i,1}(1);
    L = wallDimensions{i,2}(1);
    X_w(:,1) = [W; 0]; % SW
    X_w(:,2) = [W; L]; % SE
    X_w(:,3) = [0; L]; % NE
    X_w(:,4) = [0; 0]; % NW
    
    H_b2w{1} =  Tx( X_w(1,1) ) *  Ty( X_w(2,1) ) * Rx(pi/2) * Ry( (2/2) * pi );
    H_b2w{2} =  Tx( X_w(1,2) ) *  Ty( X_w(2,2) ) * Rx(pi/2) * Ry( (3/2) * pi );
    H_b2w{3} =  Tx( X_w(1,3) ) *  Ty( X_w(2,3) ) * Rx(pi/2) * Ry( (0/2) * pi );
    H_b2w{4} =  Tx( X_w(1,4) ) *  Ty( X_w(2,4) ) * Rx(pi/2) * Ry( (1/2) * pi );
    
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
        lgt(i,k) = light('Parent',hg_w,'Style','Local',...
            'Position',lightPos(k,:),'Tag',sprintf('Light %d',k));
    end
    
    for j = 1:numel(directionIDs)
        % Define the vertical points on the wall
        x = [0, wallDimensions{i,j}(1)];
        y = [0, wallDimensions{i,j}(2)];
        xx = [x(1),x(2),x(2),x(1)];
        yy = [y(2),y(2),y(1),y(1)];
        
        % Combine the vertical wall corner points
        X_b{j} = [xx; yy];
        X_b{j}(3,:) = 1;
        X_m{j}(3,:) = 1;
        
        % Calculate affine transform to warp from pixels to wall
        % coordinates
        A_m2b{j} = X_b{j} * pinv(X_m{j});
        tmp = eye(4);
        tmp(1:2,1:2) = A_m2b{j}(1:2,1:2);
        tmp(1:2,4)   = A_m2b{j}(1:2,3);
        tmp(3,3) = -1;  % Correction...
        A_m2b_3D{j} = tmp;
        
        % Load image
        fname = sprintf('%s_%s_Wall.jpg',roomIDs{i},directionIDs{j});
        fname = fullfile(pname,fname);
        im = imread(fname);
        
        % Define wall base frame
        hg_b(j) = triad('Parent',hg_w,'Scale',300,'Matrix',H_b2w{j},'Tag',sprintf('%s Wall Base Frame',directionIDs{j}));
        
        % Define wall dwarp frame
        hg_m(j) = triad('Parent',hg_b(j),'Matrix',A_m2b_3D{j},'Tag',sprintf('%s Wall Dewarp Frame',directionIDs{j}));
        
        % Plot image
        img = imshow(im,'Parent',axs);
        set(img,'Parent',hg_m(j),'Tag',sprintf('%s Wall Image',directionIDs{j}));
    end
    
    % Create base frame in the center of the room
    hg_o = triad('Parent',axs,'Scale',300,'LineWidth',2,'Tag','Room Center Frame');
    H_w2o = Tx(-W/2) * Ty(-L/2) * Tz(-1400); % Align with camera height
    set(hg_w,'Parent',hg_o,'Matrix',H_w2o);
    
    % Update axes directions
    set(axs,'XDir','Normal','YDir','Normal','ZDir','Normal');
    
    fprintf('[COMPLETE]\n');
    
    % Save figure
    if saveFiles
        fname = sprintf('3D Walls, %s.fig',roomIDs{i});
        fprintf('\tSaving "%s"...',fname);
        drawnow;
        try
            saveas(fig,fname,'fig');
            fprintf('[COMPLETE]\n');
        catch
            % TODO - add failed message
            fprintf('[FAILED]\n');
        end
        
        % Delete figure
        delete(fig);
    else
        set(fig,'Visible','on');
    end
    drawnow
end

%% Display complete notification
fprintf('3D wall figure generation complete.\n');