function varargout = setupTurretAndTarget(h,varargin)
% SETUPTURRETANDTARGET creates a target and sets a designated range between
% the turret and the target.
%
%   h = SETUPTURRETANDTARGET(h,targetSpecs,range)
%
%       targetSpecs.Diameter - target diameter
%       targetSpecs.VerticalOffset - change in height 
%       targetSpecs.HorizontalOffset - change in left/right position
%       targetSpecs.Color
%       targetSpecs.Wobble - target wobble
%
%   h = SETUPTURRETANDTARGET(h,targetSpecs,range,turretAng)
%
%   h = SETUPTURRETANDTARGET(h,targetSpecs,range,turretAng,wall)
%
%       wall = {['NE'],'NW','SW','SE'};
%
%   [h,h_a2r] = SETUPTURRETANDTARGET(___)
%
%   M. Kutzer, 28Mar2020, USNA

%% Check input(s)
narginchk(3,5);

% Set defaults
turretAng = 0;
wall = 'NE';
wobble = deg2rad(10); % TODO - allow user to specify target wobble
color = 'Light Orange';

% Parse input(s)
if nargin > 1
    targetSpecs = varargin{1};
end

if nargin > 2
    range = varargin{2};
end

if nargin > 3
    turretAng = varargin{3};
end

if nargin > 4
    wall = varargin{4};
end

%% Check target specs
fieldNames = {'Diameter','VerticalOffset','HorizontalOffset','Color','Wobble'};
bin = isfield(targetSpecs,fieldNames);
for i = 1:3
    if ~bin(i)
        error('The "%s" field of the target specifications input must be specified by the user.',fieldNames{i});
    end
end 
if ~bin(4) 
    targetSpecs.Color = color;
end
if ~bin(5) 
    targetSpecs.Wobble = wobble;
end

%% Specify position & orientation of target and turret
barrelLength = 356; % Offset between the barrel frame origin and the end 
                    % of the barrel

% Define turret position
switch wall
    case 'NE'
        target.XYZ(1) = targetSpecs.HorizontalOffset;
        target.XYZ(2) = h.Room_Length/2 - targetSpecs.Diameter/2;
        target.XYZ(3) = targetSpecs.VerticalOffset;
        target.theta = 0;
        target.diameter = targetSpecs.Diameter;
        target.color = targetSpecs.Color;
        target.wobble = targetSpecs.Wobble;
        
        turret.XYZ(1) = target.XYZ(1);
        turret.XYZ(2) = target.XYZ(2) - (range + barrelLength);
        turret.XYZ(3) = 0;
        turret.theta = target.theta + turretAng;
    case 'NW'
        target.XYZ(1) = -(h.Room_Width/2 - targetSpecs.Diameter/2);
        target.XYZ(2) = -(targetSpecs.HorizontalOffset);
        target.XYZ(3) = targetSpecs.VerticalOffset;
        target.theta = pi/2;
        target.diameter = targetSpecs.Diameter;
        target.color = targetSpecs.Color;
        target.wobble = targetSpecs.Wobble;
        
        turret.XYZ(1) = target.XYZ(1) + (range + barrelLength);
        turret.XYZ(2) = target.XYZ(2);
        turret.XYZ(3) = 0;
        turret.theta = target.theta + turretAng;
    case 'SW'
        target.XYZ(1) = -(targetSpecs.HorizontalOffset);
        target.XYZ(2) = -(h.Room_Length/2 - targetSpecs.Diameter/2);
        target.XYZ(3) = targetSpecs.VerticalOffset;
        target.theta = pi;
        target.diameter = targetSpecs.Diameter;
        target.color = targetSpecs.Color;
        target.wobble = targetSpecs.Wobble;
        
        turret.XYZ(1) = target.XYZ(1);
        turret.XYZ(2) = target.XYZ(2) - (range + barrelLength);
        turret.XYZ(3) = 0;
        turret.theta = target.theta + turretAng;
    case 'SE'
        target.XYZ(1) = h.Room_Width/2 - targetSpecs.Diameter/2;
        target.XYZ(2) = targetSpecs.HorizontalOffset;
        target.XYZ(3) = targetSpecs.VerticalOffset;
        target.theta = 3*pi/2;
        target.diameter = targetSpecs.Diameter;
        target.color = targetSpecs.Color;
        target.wobble = targetSpecs.Wobble;
        
        turret.XYZ(1) = target.XYZ(1) - (range + barrelLength);
        turret.XYZ(2) = target.XYZ(2);
        turret.XYZ(3) = 0;
        turret.theta = target.theta + turretAng;
    otherwise
        error('Specified wall "%s" is undefined.',wall);
end

%% Move turret 
h = moveTurretFOV(h,turret.XYZ(1),turret.XYZ(2));
h = moveTurretFOV(h,turret.theta);

%% Create and place the target
h_a2r = createTarget(h.Frames.h_r2b,'Circle',target.diameter,target.color);
h_a2r = placeTarget(h_a2r,target.XYZ,target.theta,target.wobble);

%% Package Output
if nargout > 0
    varargout{1} = h;
end
if nargout > 1
    varargout{2} = h_a2r;
end