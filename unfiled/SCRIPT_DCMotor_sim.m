addpath('G:\My Drive\Courses\EW309 AY20\10. Turret System Modeling\Turret Data')

fname = 'EncoderForMike_PWM_Sinev2.xlsx';

dat = readtable(fname);

time = dat{:,2};
dc = dat{:,1};
enc = dat{:,3};
pos = dat{:,4};

time_uniform = 0:.01:max(time)-8;
pos_uniform = interp1(time,pos,time_uniform);
pos_uniform(1:2) = 0;
inds = find(dc==-1);


% Motor constants
params.case = 1; % (for testing/development) case one, sinusoidal input
params.Ra = 5; % Armature resistance (Ohms)
params.La = 0.2*10^-1; % Armature inductance (H) (~10^-3)
params.Bm = .027; % coefficient of friction (Nm*s/rad)
params.Km = .95; % transducer constant (Nm*s/rad) (amp*H/rad)
params.J = 0.16*10^0; % moment of inertial
params.friction.a0 = 0.14; % positive spin static friction (Nm)
params.friction.a1 = 0.3; % positive spin coulumb friction coefficient
params.friction.a2 = 1.3; % speed decay constant on coulumb friction

params.friction.a3 = .4; % negative spin static friction (Nm)
params.friction.a4 = 0.2; % negative spin coulumb friction coefficient
params.friction.a5 = 1; % speed decay constant on coulumb friction
params.friction.del = 0.02; % rad/s "linear zone" of friction
params.dzone.high = 0.25; % ten percent duty cycle on positive side 0.25 comes from trials 
params.dzone.low = 0.25; % twenty percent on negative side 0.25 comes from trials


cntrlprms.despos = 0;
cntrlprms.Kp = 0;
cntrlprms.Ki = 0;
cntrlprms.Kd = 0;


% initial condition
t = 0:.01:max(time)-8;
theta0 = 0;
dtheta0 = 0;
i0 = 0;
q0 = [theta0;dtheta0;i0;0];

%

% integrate EOM
[~,Q] = ode45(@MotDynHF,t,q0,[],params,cntrlprms);

%


% plot result
figure(1); clf
% subplot(3,1,1)
plot(t,Q(:,1))
hold on
plot(time_uniform,pos_uniform)
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
axis([0 40 0 45])
% legend('Experimental Data','Simulation')


% % animate turning
% fig = figure(2); clf
% ax = axes('Parent',fig);

%

fname = 'EncoderForMike_PWM_45.xlsx';

dat = readtable(fname);

time = dat{:,2};
dc = 0.45*ones(size(time));
dc(time<=1) = 0;
enc = dat{:,3};
pos = dat{:,4};

time_unistep = 0:.01:max(time);
pos_unistep = interp1(time,pos,time_unistep);
pos_unistep(1:2) = 0;


params.case = 2; % (for testing/development) case one, sinusoidal input

% initial condition
t = 0:.01:max(time);
theta0 = 0;
dtheta0 = 0;
i0 = 0;
q0 = [theta0;dtheta0;i0;0];

%

% integrate EOM
[~,Q] = ode45(@MotDynHF,t,q0,[],params,cntrlprms);

%


% plot result
figure(2); clf
% subplot(3,1,1)
plot(t,Q(:,1))
hold on
plot(time_unistep,pos_unistep)
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
% legend('Experimental Data','Simulation')
axis([0 6 0 15])



% %% Optimize parameters based on both trials
% data(1).time = time_uniform;
% data(1).pos = pos_uniform;
% 
% data(2).time = time_unistep;
% data(2).pos = pos_unistep;
% x = fmincon(@(x) objFunc(x,params,data),[9 0.03 1 0.9*10^-1 0.1 01]);
% 
% 
% params.La = x(1);
% params.Bm = x(2);
% params.Km = x(3);
% params.J = x(4);
% params.friction.a0 = x(5);
% params.friction.a1 = x(6);
% 
% params.case = 1;
% [~,Qsin] = ode45(@MotDynHF,data(1).time,[0;0;0],[],params);
% params.case = 2;
% [~,Qstep] = ode45(@MotDynHF,data(2).time,[0;0;0],[],params);
% 
% 
% figure(3); clf
% subplot(1,2,1)
% plot(data(1).time,Qsin(:,1),data(1).time,data(1).pos)
% 
% subplot(1,2,2)
% plot(data(2).time,Qstep(:,1),data(2).time,data(2).pos)
% 


%% test out a controller on the motor model

params.case = 3;
cntrlprms.despos = pi/4;
cntrlprms.Kp = .4;
cntrlprms.Ki = 0.06;
cntrlprms.Kd = 0;


% initial condition
t = 0:.01:40;
theta0 = 0;
dtheta0 = 0;
i0 = 0;
q0 = [theta0;dtheta0;i0;0];

%

% integrate EOM
[~,Q] = ode45(@MotDynHF,t,q0,[],params,cntrlprms);



figure(4); clf
plot(t,Q(:,1))
hold on
plot(t,cntrlprms.despos*ones(size(t)),'--r')
legend('Closed-loop Response', 'Desired Position')
xlabel('Time (s)')
ylabel('Orientation (rad)')