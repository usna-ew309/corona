
% Motor constants
params.Ra = 5; % Armature resistance (Ohms)
params.La = 1.5*10^-3; % Armature inductance (H)
params.Bm = .01; % coefficient of friction (Nm*s/rad)
params.Km = 10^-1; % transducer constant (Nm*s/rad) (amp*H/rad)
params.J = 10^-1; % moment of inertial
params.friction.a0 = 0.2; % positive spin static friction (Nm)
params.friction.a1 = 0.3; % positive spin coulumb friction coefficient
params.friction.a2 = 1; % speed decay constant on coulumb friction
params.friction.a3 = 1; % negative spin static friction (Nm)
params.friction.a4 = 0.5; % speed decay constant on coulumb friction
params.friction.a5 = 1; % speed decay constant on coulumb friction
params.friction.del = 0.02; % rad/s "linear zone" of friction
params.dzone.high = 0.1; % ten percent duty cycle on positive side 
params.dzone.low = 0.15; % twenty percent on negative side

% initial condition
t = 0:.01:15;
theta0 = 0;
dtheta0 = 0;
i0 = 0;
q0 = [theta0;dtheta0;i0];

%%


% integrate EOM
[~,Q] = ode45(@MotDynHF,t,q0,[],params);

%%


% plot result
figure(1); clf
plot(t,Q(:,1))
xlabel('Time (s)')
ylabel('Orientation (rad)')


% % animate turning
% fig = figure(2); clf
% ax = axes('Parent',fig);





