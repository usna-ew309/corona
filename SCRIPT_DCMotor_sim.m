
% Motor constants
params.Ra = 10; % Armature resistance (Ohms)
params.La = 1; % Armature inductance (H)
params.Bm = 1; % coefficient of friction (Nm*s/rad)
params.Km = 10^-3; % transducer constant (Nm*s/rad) (amp*H/rad)
params.a0 = 1; % positive spin static friction (Nm)
params.a1 = 0.1; % positive spin coulumb friction coefficient
params.a2 = 1; % speed decay constant on coulumb friction
params.a3 = 1.4; % negative spin static friction (Nm)
params.a4 = 0.1; % speed decay constant on coulumb friction
params.a5 = 1; % speed decay constant on coulumb friction
params.alow = 0.3;
params.ahigh = 0.2;
params.ddzne = 12*0.2;

% initial condition
t = 0:.01:10;
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
plot(t,Q)
xlabel('Time (s)')
ylabel('Orientation (rad)')


% % animate turning
% fig = figure(2); clf
% ax = axes('Parent',fig);





