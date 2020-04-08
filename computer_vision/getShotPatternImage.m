function im = getShotPatternImage(varargin)
% GETSHOTPATTERNIMAGE creates a simulated image of a shot pattern on the SW
% chalkboard of Ri080.
%   im = GETSHOTPATTERNIMAGE(range,nShots) creates a simulated image of a 
%   shot pattern and point of ain on an EW309 chalkboard. The variable 
%   "range" must be specified in *centimeters*. The number of shots is  
%   specified using "nShots". The variable "nShots" must be an integer 
%   value greater than 0. 
%
%   im = GETSHOTPATTERNIMAGE(nShots) can only be run after getTargetImage.m
%
%   im = GETSHOTPATTERNIMAGE(h,range,nShots) uses a pre-defined FOV 
%   specified using the strucured array h. Use "createEW309RoomFOV.m".
%
%   M. Kutzer, 01Apr2020, USNA

%% Define global FOV simulation
% Yes, I realize that globals are generally lazy coding, but I am doing
% this to (a) simplify the function syntax, and (b) speed up simplified
% execution.
global hFOV_global

%% Check input(s)
narginchk(1,3);

% Set default(s)
targetSpecs.Diameter = 20;             % Diameter in millimeters
targetSpecs.HorizontalBias = 0;        % Horizontal bias in millimeters
targetSpecs.VerticalBias = 0;          % Vertical bias in millimeters
targetSpecs.Color = 'Bright Green';    % Target color
targetSpecs.Wobble = 0;                % Wobble in radians
targetSpecs.Shape = 'Circle';          % Target shape

% Use global FOV
useGlobal = false;
if nargin < 3
    if isstruct(hFOV_global)
        if isfield(hFOV_global,'Figure')
            if ishandle(hFOV_global.Figure)
                useGlobal = true;
            end
        end
    end
    
    if useGlobal
        if nargin > 1
            % Check for pre-existing target(s)
            if isfield(hFOV_global,'getTargetImage')
                % Return turret to zero configuration
                set(hFOV_global.Frames.h_r2b,'Matrix',hFOV_global.getTargetImage.H_r2b_0)
                hFOV_global.Frames.H_r2b = hFOV_global.getTargetImage.H_r2b_0;
                % Remove pre-existing target(s)
                delete(hFOV_global.getTargetImage.h_a2r);
                % Remove "getTargetImage" field
                hFOV_global = rmfield(hFOV_global,'getTargetImage');
            end
        end
        % Update turret struct
        h = hFOV_global;
    else
        h = createEW309RoomFOV('Ri080');
        hFOV_global = h;
        useGlobal = true;
    end
    set(h.Figure,'Visible','off');
    
    idxSTART = 1;
else
    h = varargin{1};
    idxSTART = 2;
end

if nargin > idxSTART - 1
    rangeCM = varargin{idxSTART}; % Range in centimeters
    rangeMM = rangeCM*10;         % Range im millimeters
    idxSTART = idxSTART+1;
end
if nargin > idxSTART - 1
    nShots = varargin{idxSTART};
    idxSTART = idxSTART+1;
end

if nargin > 1
    %% Set room defaults
    [turretSpecs,wall] = getDefaultsEW309RoomFOV(h,0);
    
    %% Place target frame
    [hNEW,h_a2r,objs] = setupTurretAndTarget(h,targetSpecs,rangeMM,turretSpecs,wall); % Range must be spefi
    drawnow;
    
    % Hide target
    set(objs,'Visible','off');
else
    if ~isfield(hFOV_global,'getTargetImage')
        error('You need to run getTargetImage.m prior to running this function with a single input.');
    end
    % Recover range
    rangeCM = (hFOV_global.getTargetImage.range)/10;
    % Define shots
    nShots = varargin{1};
    % Define shot reference frame
    h_a2r = hFOV_global.getTargetImage.h_a2r;
    % Define "unwobbled" shot reference frame
    % Review of hgTransforms contained in h.Frames
    %   h_b2c - Barrel relative to Camera   (FIXED TRANSFORM)
    %   h_r2b - Room relative to Barrel
    %   h_w2r - West relative to Room       (FIXED TRANSFORM)
    %
    % Additional frame definitions
    %   Frame aw - "wobbled" target "aim" frame (target parent)
    %   Frame a  - "unwobbled" target "aim" frame
    
    H_aw2r = get(h_a2r,'Matrix'); % Wobbled frame
    H_r2b = get(hFOV_global.Frames.h_r2b,'Matrix');
    H_b2r = H_r2b^-1;
    H_a2b = Rx(pi/2);       % This does not account for correct position
    H_a2r = H_b2r * H_a2b;  % This does not account for correct position
    % Isolate rotation elements
    R_aw2r = H_aw2r(1:3,1:3);
    R_a2r = H_a2r(1:3,1:3);
    R_a2aw = (R_aw2r^(-1))*R_a2r;
    % Define relative transform
    H_a2aw = eye(4);
    H_a2aw(1:3,1:3) = R_a2aw;
    
    % Define unwobbled frame relative to room
    H_a2r = H_aw2r*H_a2aw;
    % Define barrel frame relative to room
    % H_b2r (already calculated)
    % Calculate unwobbled xy plane relative to room
    abcd_xy_a2r(1,1:3) = H_a2r(1:3,3).';
    adcd_xy_a2r(1,4) = -abcd_xy_a2r(1:3,1)*H_a2r(1:3,4);
    % Calculate parametric line pointing in the y-direction of Frame b
    p1 = H_b2r(1:3,4);
    p2 = p1 + H_b2r(1:3,2);
    M = [p1,p2]*[0,1; 1,1];
    % Calculate line/plane intersection
    % abc*M*[s; 1] + d = 0;
    % abc*M(:,1)*s + abc*M(:,2) + d = 0
    % s = -(abc*M(:,2) + d)/abc*M(:,1)
    abc = abcd_xy_a2r(1,1:3);
    d = abcd_xy_a2r(1,4);
    s = -(abc*M(:,2) + d)/abc*M(:,1);
    pnt_s2r = M*[s; 1];   % Point of intersection. 
                          % This should be the origin of our shot pattern.
    H_s2r = H_a2r;
    H_s2r(1:3,4) = pnt_s2r;
    H_r2a = H_a2r^(-1);
    H_s2a = H_r2a*H_s2r;
    
    % Define unwobbled frame
    h_a2aw = triad('Parent',h_a2r,'Scale',150,'LineWidth',1.5,'Matrix',H_a2aw);
    hideTriad(h_a2aw); % Hide the "triad" visualization
    h_s2a  = triad('Parent',h_a2aw,'Scale',150,'LineWidth',1.5,'Matrix',H_s2a);
    hideTriad(h_s2a); % Hide the "triad" visualization
    
    % Find xy plane of 
    % Overwrite shot pattern parent
    % -> This bastardizes the notation for this one special case
    h_a2r = h_s2a;
    
    hNEW = hFOV_global;
end

%% Get Shot Pattern
[x,y] = getShotPattern(rangeCM,nShots);

%% Render shot pattern
objs = renderShotPattern(h_a2r,x,y);
drawnow;
im = getFOVSnapshot(hNEW);

%% Return FOV to original state
if useGlobal && (nargin == 1)
    % Get Info
    hFOV_global.getShotPatternImage.x = x;
    hFOV_global.getShotPatternImage.y = y;
else
    hNEW.Frames.h_r2b = h.H_r2b;
    hNEW.H_r2b = h.H_r2b;
    
    % Debugging calculations
    %{
    H_a2r = h_a2r.Matrix;
    H_r2b = h.Frames.h_r2b.Matrix;
    H_b2c = h.Frames.h_b2c.Matrix;

    H_r2c = H_a2r^(-1);
    H_a2c = H_b2c*H_r2b*H_a2r;
    %}
    
    delete(h_a2r);
end
