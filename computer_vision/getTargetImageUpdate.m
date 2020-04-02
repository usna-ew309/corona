function im = getTargetImageUpdate(relative_angle)
%GETTARGETIMAGEUPDATE update global FOV simulation with relative angle
%information.
%   im = GETTARGETIMAGEUPDATE(relative_angle) moves the current turret FOV
%   by a designated relative angle in radians.
%
%   M. Kutzer, 02Apr2020, USNA


%% Define global FOV simulation
% Yes, I realize that globals are generally lazy coding, but I am doing
% this to (a) simplify the function syntax, and (b) speed up simplified
% execution.
global hFOV_global

%% Check input(s)
narginchk(1,1);

% Check global
useGlobal = false;
if isstruct(hFOV_global)
    if isfield(hFOV_global,'Figure')
        if ishandle(hFOV_global.Figure)
            useGlobal = true;
        end
    end
end

errSTR = 'You need to run "getTargetImage.m" before using this function.';
if ~useGlobal
    error(errSTR);
end

if isfield(hFOV_global,'getTargetImage')
    % Get absolute angle
    angle = hFOV_global.getTargetImage.angle + relative_angle;
    % Update turret struct
    h = hFOV_global;
else
    error(errSTR);
end

%% Move the turret
hNEW = moveTurretFOV(h,angle);
drawnow;

%% Get an image
im = getFOVSnapshot(hNEW);

%% Update global angle
% Update global
hFOV_global = hNEW;
% Append zero configuration
hFOV_global.getTargetImage.H_r2b_0 = h.H_r2b;
% Append parent of target(s)
hFOV_global.getTargetImage.h_a2r = h_a2r;
% Append angle information
hFOV_global.getTargetImage.angle = angle;