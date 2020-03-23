function h = moveTurretFOV(h,varargin)
% MOVETURRETFOV rotates and potentially positions an EW309 turret within an
% existing EW309 room.
%
%   h = MOVETURRETFOV(h,theta) rotates the turret by a specified angle 
%   (theta) defined in ratians. The first parameter is the structured array
%   returned by createEW309RoomFoV.m
%
%   h = MOVETURRETFOV(h,x,y) changes the x/y position of the turret The
%   first parameter is the structured array returned by 
%   createEW309RoomFoV.m
%
%   M. Kutzer, 23Mar2020, USNA

%% Check input(s) 
narginchk(2,3);

% TODO - check h!
% TODO - check theta, x, and y

if nargin == 2
    theta = varargin{1};
    x = 0;
    y = 0;
end

if nargin == 3
    theta = 0;
    x = varargin{1};
    y = varargin{2};
end

%% Update turret FOV
H_r2b = Tx(-x)*Ty(-y)*Rz(-theta);

h.H_r2b = H_r2b;
set(h.Frames.h_r2b,'Matrix',H_r2b);