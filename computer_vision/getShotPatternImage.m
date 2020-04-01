function im = getShotPatternImage(varargin)
% GETSHOTPATTERNIMAGE creates a simulated image of a shot pattern on the SW
% chalkboard of Ri080.
%   im = GETSHOTPATTERNIMAGE(range,nShots) creates a simulated image of a 
%   shot pattern and point of ain on an EW309 chalkboard. The variable 
%   "range" must be specified in *centimeters*. The number of shots is  
%   specified using "nShots". The variable "nShots" must be an integer 
%   value greater than 0. 
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
narginchk(2,3);

% Set default(s)
targetSpecs.Diameter = 20;             % Diameter in millimeters
targetSpecs.HorizontalBias = 0;        % Horizontal bias in millimeters
targetSpecs.VerticalBias = 0;          % Vertical bias in millimeters
targetSpecs.Color = 'Bright Green';    % Target color
targetSpecs.Wobble = 0;                % Wobble in radians
targetSpecs.Shape = 'Circle';          % Target shape

% Use global FOV
if nargin < 3
    useGlobal = false;
    if isstruct(hFOV_global)
        if isfield(hFOV_global,'Figure')
            if ishandle(hFOV_global.Figure)
                useGlobal = true;
            end
        end
    end
    
    if useGlobal
        h = hFOV_global;
    else
        h = createEW309RoomFOV('Ri080');
        hFOV_global = h;
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

%% Set room defaults
[turretSpecs,wall] = getDefaultsEW309RoomFOV(h,0);

%% Place target frame
[hNEW,h_a2r,objs] = setupTurretAndTarget(h,targetSpecs,rangeMM,turretSpecs,wall); % Range must be spefi
drawnow;

% Hide target
set(objs,'Visible','off');

%% Get Shot Pattern
[x,y] = getShotPattern(rangeCM,nShots);

%% Render shot pattern
objs = renderShotPattern(h_a2r,x,y);
drawnow;
im = getFOVSnapshot(hNEW);

%% Return FOV to original state
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
