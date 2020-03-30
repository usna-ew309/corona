function im = getCalibrationImage(varargin)
% GETCALIBRATIONIMAGE creates a simulated image of a calibration grid on a 
% chalkboard.
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

persistent h_persistent

%% Check input(s)
narginchk(1,2);

if nargin == 1
    range = varargin{1};
    usePersistent = false;
    if isstruct(h_persistent)
        if isfield(h_persistent,'Figure')
            if ishandle(h_persistent.Figure)
                usePersistent = true;
            end
        end
    end
    
    if usePersistent
        h = h_persistent;
    else
        h = createEW309RoomFOV('Ri080');
        h_persistent = h;
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
walls    = {'NE','NW','SW','SE'};

switch h.Room
    case 'Ri078'
        
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
