function [hg,ptc] = drawTarget(varargin)
% DRAWTARGET draws a target of specified shape, size, and color and returns
% the graphics object(s) associated with the target.
%   [hg,ptc] = DRAWTARGET(shape,diameter,color) creates a shape specified
%   by a string argument whose overall size fits within a bounding circle
%   of the specified diameter in millimeters. The specified color is then
%   used to fill the patch object that is created. Both the patch object
%   and an hgtransform parent of the patch of object are returned.
%
%   [hg,ptc] = DRAWTARGET(axs,shape,diameter,color) specifies the axes
%   handle for the target.
%
%   Valid shape selections include:
%       'Circle'
%       'Square'
%       'Random Rectangle'
%       'Equilateral Triangle'
%       'Random Triangle'
%       'Random Polygon'
%
%   Valid color selections include:
%       'Bright Yellow'
%       'Bright Pink'
%       'Bright Green'
%       'Dark Orange'
%       'Light Orange'
%       'Dark Red'
%       'Light Red'
%
%   M. Kutzer, 25Mar2020, USNA

%% Check input(s)
narginchk(3,4);

if nargin == 3
    axs = gca;
    shape = varargin{1};
    diameter = varargin{2};
    color = varargin{3};
end

if nargin == 4
    axs = varargin{1};
    shape = varargin{2};
    diameter = varargin{3};
    color = varargin{4};
end

if ~ishandle(axs)
    error('Specified axes must be a valid axes handle.');
end
if ~isscalar(diameter)
    error('Diameter must be specified as a scalar value in millimeters.');
end

%% Parse Shape
r = diameter/2;
switch lower(shape)
    case 'circle'
        n = 100;
        theta_i = 0;
        theta_f = 2*pi;
        theta = linspace(theta_i,theta_f,n+1);
        theta(end) = [];
        verts = [r*cos(theta); r*sin(theta)].';
        faces = 1:n;
    case 'square'
        n = 4;
        theta_i = 0;
        theta_f = 2*pi;
        theta = linspace(theta_i,theta_f,n+1) + (pi/4)*ones(1,n+1);
        theta(end) = [];
        verts = [r*cos(theta); r*sin(theta)].';
        faces = 1:n;
    case 'random rectangle'
        n = 4;
        theta_i = (pi/2) * rand;
        alpha_i = pi/2 - theta_i;
        theta = [theta_i, theta_i + 2*alpha_i, 3*theta_i + 2*alpha_i, 3*theta_i + 4*alpha_i];
        verts = [r*cos(theta); r*sin(theta)].';
        faces = 1:n;
    case 'equilateral triangle'
        n = 3;
        theta_i = 0;
        theta_f = 2*pi;
        theta = linspace(theta_i,theta_f,n+1) + (pi/2)*ones(1,n+1);
        theta(end) = [];
        verts = [r*cos(theta); r*sin(theta)].';
        faces = 1:n;
    case 'isosceles triangle'
        n = 3;
        theta_i = (pi/2) * rand;
        alpha_i = pi/2 - theta_i;
        theta = [theta_i, theta_i + 2*alpha_i, 3*pi/2] + pi * ones(1,3);
        verts = [r*cos(theta); r*sin(theta)].';
        faces = 1:n;
    case 'random triangle'
        n = 3;
        dtheta = sort( (2*pi/3)*rand(1,n) );
        theta = dtheta + [(1/2)*(2*pi/3), (3/2)*(2*pi/3), (5/2)*(2*pi/3)] + (pi+pi/4)*ones(1,n);%cumsum(dtheta);
        verts = [r*cos(theta); r*sin(theta)].';
        faces = 1:n;
    case 'random polygon'
        n = randi([3,10],1);
        theta = sort( 2*pi*rand(1,n) );
        verts = [r*cos(theta); r*sin(theta)].';
        faces = 1:n;
    otherwise
        error('Specified shape "%s" is not recognized.',shape);
end

%% Create patch object and triad
hold(axs,'on');
daspect(axs,[1 1 1]);

hg = triad('Parent',axs,'Scale',0.75*r,'LineWidth',1.5);
ptc = patch('Parent',hg,'Vertices',verts,'Faces',faces,...
    'FaceColor','b','EdgeColor','k','LineWidth',1.5);

% Plot circle for debugging
%{
n = 100;
theta_i = 0;
theta_f = 2*pi;
theta = linspace(theta_i,theta_f,n+1);
verts = [r*cos(theta); r*sin(theta)].';
plot(hg,verts(:,1),verts(:,2),'m');
%}

%% Load color
% TODO - update color based on dpi and diameter.
res = [200,200];
cPatch = createTargetColorPatch(color,res);