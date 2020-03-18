addpath('G:\My Drive\Courses\EW309 AY20\10. Turret System Modeling\Turret Data')

fname = 'EncoderForMike_PWM_Sinev2.xlsx';

dat = readtable(fname);

time = dat{:,2};
dc = dat{:,1};
enc = dat{:,3};
pos = dat{:,4};

inds = find(dc==-1);


% Motor constants
params.Ra = 5; % Armature resistance (Ohms)
params.La = 0.7*10^1; % Armature inductance (H) (~10^-3)
params.Bm = .07; % coefficient of friction (Nm*s/rad)
params.Km = 1; % transducer constant (Nm*s/rad) (amp*H/rad)
params.J = 0.9*10^-1; % moment of inertial
params.friction.a0 = 0.12; % positive spin static friction (Nm)
params.friction.a1 = 0.15; % positive spin coulumb friction coefficient
params.friction.a2 = 1; % speed decay constant on coulumb friction

params.friction.a3 = .45; % negative spin static friction (Nm)
params.friction.a4 = 0.3; % negative spin coulumb friction coefficient
params.friction.a5 = 1; % speed decay constant on coulumb friction
params.friction.del = 0.05; % rad/s "linear zone" of friction
params.dzone.high = 0.1; % ten percent duty cycle on positive side 0.25 comes from trials 
params.dzone.low = 0.1; % twenty percent on negative side 0.25 comes from trials

% initial condition
t = 0:.01:max(time)-8;
theta0 = 0;
dtheta0 = 0;
i0 = 0;
q0 = [theta0;dtheta0;i0];

%%


% integrate EOM
[~,Q] = ode45(@MotDynHF,t,q0,[],params);

%%


figure(1); clf
% subplot(2,1,1)
plot(time,pos)
axis([0 15 -inf inf])
xlabel('Time (s)')
ylabel('Orientation (rad)')
title('Experimental Data')
% figure(2); clf
% % subplot(2,1,2)
% plot(time,dc)
% hold on
% plot(time(inds),dc(inds),'*')

% axis([0 15 -inf inf])

% figure(3); clf
% plot(enc,pos)




% plot result
figure(1); clf
% subplot(3,1,1)
plot(t,Q(:,1))
hold on
plot(time,pos)
xlabel('Time (s)')
ylabel('Orientation (rad)')
% title('Simulation Result')
% subplot(3,1,2)
% plot(t,Q(:,2))
% xlabel('Time (s)')
% ylabel('speed (rad/s)')
% subplot(3,1,3)
% plot(t,Q(:,3))
% xlabel('Time (s)')
% ylabel('current (amp)')

legend('Experimental Data','Simulation')


% % animate turning
% fig = figure(2); clf
% ax = axes('Parent',fig);







