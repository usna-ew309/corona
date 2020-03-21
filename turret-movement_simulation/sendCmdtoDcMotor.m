function [SSE,varargout] = sendCmdtoDcMotor(des_orientation,Kp,Ki,Kd,varargin)
% TODO: FINISH Documentation!!!! 
%
%
% Example usage:
%   des_theta = pi/4;
%   Kp = 0.5;
%   Ki = 0.02;
%   Kd = 0.02;
%   t = 0:.05:10;
%   [SSE,t,theta,omega,eint] = sendCmdtoDcMotor(pi/4,0.5,0.01,0.01,t);  
% OR
%   SSE = sendCmdtoDcMotor(pi/4,0.5,0.01,0.01,t);  
%
%
%   L. DeVries, USNA, EW309, AY2020



% configure control parameters
cntrlprms.despos = des_orientation;
cntrlprms.Kp = Kp;
cntrlprms.Ki = Ki;
cntrlprms.Kd = Kd;


if nargin == 5
    t = varargin{1};
    % initial condition
    theta0 = 0;
    dtheta0 = 0;
    i0 = 0;
    q0 = [theta0;dtheta0;i0;0];
elseif nargin == 6
    t = varargin{1};
    q0 = varargin{2};
elseif nargin > 6
    error('Too many inputs')
else
    t = 0:.01:10;
    % initial condition
    theta0 = 0;
    dtheta0 = 0;
    i0 = 0;
    q0 = [theta0;dtheta0;i0;0];
end


% Motor constants
motorParams.Ra = 5; % Armature resistance (Ohms)
motorParams.La = 0.2*10^-1; % Armature inductance (H) (~10^-3)
motorParams.Bm = .027; % coefficient of friction (Nm*s/rad)
motorParams.Km = .95; % transducer constant (Nm*s/rad) (amp*H/rad)
motorParams.J = 0.15*10^0; % moment of inertial
motorParams.friction.a0 = 0.15; % positive spin static friction (Nm)
motorParams.friction.a1 = 0.25; % positive spin coulumb friction coefficient
motorParams.friction.a2 = 1.3; % speed decay constant on coulumb friction
motorParams.friction.a3 = .36; % negative spin static friction (Nm)
motorParams.friction.a4 = 0.25; % negative spin coulumb friction coefficient
motorParams.friction.a5 = 1; % speed decay constant on coulumb friction
motorParams.friction.del = 0.05; % rad/s "linear zone" of friction
motorParams.dzone.pos = 0.25; % ten percent duty cycle on positive side 0.25 comes from trials 
motorParams.dzone.neg = 0.25; % twenty percent on negative side 0.25 comes from trials
motorParams.case = 3;

% integrate EOM
[~,Q] = ode45(@MotDynHF,t,q0,[],motorParams,cntrlprms);


% % % plot results
% % fig3 = figure(3); clf
% % plot(t,Q_cl(:,1))
% % hold on
% % plot(t,cntrlprms.despos*ones(size(t)),'--r')
% % legend('Closed-loop Response', 'Desired Position')
% % xlabel('Time (s)')
% % ylabel('Orientation (rad)')

% orientation
out(:,1) = t; % time vector
out(:,2) = Q(:,1); % theta
out(:,3) = Q(:,2); % omega
out(:,4) = Q(:,4); % error integral
lng = ceil(0.1*length(Q(:,1))); % last 10% of data points

% steady-state error
SSE = des_orientation - mean(Q(end-lng:end,1));

% Optional outputs
nout = max(nargout,1)-1;
for k = 1:nout
    varargout{k} = out(:,k);
end

end