function im = getCalibrationImage(varargin)
% GETCALIBRATIONIMAGE creates a simulated image of a calibration grid on 
% the SW chalkboard of the Ri080.
%   im = GETCALIBRATIONIMAGE(range) creates a simulated image of a
%   calibration grid on an EW309 classroom chalkboard. The variable "range"
%   must be specified in *centimeters*.
%
%   im = GETCALIBRATIONIMAGE(h,range) creates a simulated image of a
%   calibration grid on an EW309 classroom chalkboard. The variable "h" is
%   the structured array returned by "createEW309RoomFOV" and "range" must 
%   be specified in *centimeters*.
%
%   M. Kutzer, 30Mar2020, USNA

%% Define global FOV simulation
% Yes, I realize that globals are generally lazy coding, but I am doing
% this to (a) simplify the function syntax, and (b) speed up simplified
% execution.
global hFOV_global

%% Check input(s)
narginchk(1,2);

if nargin == 1
    range = varargin{1};
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
end

if nargin == 2
    h = varargin{1};
    range = varargin{2};
end

%% Convert range to millimeters
range = 10*range;

%% Get image
walls = {'NE','NW','SW','SE'};
% Set room defaults
switch h.Room
    case 'Ri078'
        error('Offset settings for Ri078 are not defined, please use Ri080.');
    case 'Ri080'
        hBias = 0;
        vBias = h.H_b2c(2,4);   % Align the target with the camera
        hOffset = -6*12*25.4;
        vOffset = 0.5*25.4;
        theta = 0;
        w = 3;
    otherwise
        error('Room "%s" is not recognized.',h.Room);
end

% Define target specs
targetSpecs.Diameter = 5*25.4;      % Unused
targetSpecs.HorizontalBias = hBias; % Horizontal bias
targetSpecs.VerticalBias = vBias;   % Vertical bias
targetSpecs.Color = 'w';            % Crosshair color
targetSpecs.Wobble = 0;             % Wobble
targetSpecs.Shape = 'Crosshair';    % Type
%targetSpecs.Shape = 'Circle';

% Define turret specs
turretSpecs.HorizontalOffset = hOffset;
turretSpecs.VerticalOffset = vOffset;
turretSpecs.Angle = theta;

wall = walls{w};

[hNEW,h_a2r] = setupTurretAndTarget(h,targetSpecs,range,turretSpecs,wall);
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
