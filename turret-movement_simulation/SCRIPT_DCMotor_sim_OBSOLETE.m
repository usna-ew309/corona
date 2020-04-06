%% Description
% This script performs basic analysis and comparison between the nonlinear
% DC motor model and the experimentally collected data from the turret
% apparatus. The nonlinearities in the model include static friction and
% coulumb friction (Stribeck effect) along with a dead zone input
% nonlinearity. These two effects when incorporated into the basic DC motor
% dynamics appear to emulate the experimental data with reasonable
% agreement.
%
% The state-space model consists of:
% Three motor states: 
%       position (rad)
%       velocity (rad/s) and current (amps)
% One state to implement integral control:
%       time integral of position error (rad*s)
%
% Parameters of the model are organized in a MATLAB data structure. These
% parameters include:
%   motParams.Ra: motor armature resistance (Ohms)
%   motParams.La: motor armature inducatnce (H)
%   motorParams.Bm: coefficient of linear friction (Nm*s/rad)
%   motorParams.Km: transducer constant (Nm*s/rad) (amp*H/rad)
%   motorParams.J: moment of inertia (Kg*m^2)
%   motorParams.friction.a0: positive spin static friction (Nm)
%   motorParams.friction.a1: positive spin coulumb friction coefficient (Nm)
%   motorParams.friction.a2: speed decay constant on coulumb friction (unitless
%   motorParams.friction.a3: negative spin static friction (Nm)
%   motorParams.friction.a4: negative spin coulumb friction coefficient
%   motorParams.friction.a5: speed decay constant on coulumb friction
%   motorParams.friction.del: approximation of stiction range (rad/s)
%   motorParams.dzone.pos: dead zone for positive inputs (duty cycle)
%   motorParams.dzone.neg: dead zone for negative inputs (duty cycle)
%   motorParams.case: operational case to simulate
%                       1 = sinusoidal input, amplitude 1, period 10 second
%                       2 = step input, magnitude 0.45 (45% duty cycle)
%                       3 = closed loop control
%
% To implement an open or closed-loop linear control scheme (P, PI, PD,
% PID) a control parameters structure is included in the model to
% efficiently pass variables to necessary locations in the simulation
% framework. The control parameters can include:
%   cntrlParams.mode: operational mode, 'closed' or 'open'
%   cntrlParams.despos: desired position (orientation) of the turret (rad)
%   cntrlParams.Kp: gain of proportional control term
%   cntrlParams.Ki: gain of integral control term
%   cntrlParams.Kd: gain of derivative control term
%   cntrlParams.stepPWM: duty cycle of open loop step input



%% Import experimental data

% add path to folder with experimental data
addpath([pwd '\Turret Data'])

% file name of sine data
fname_sine = 'EncoderForMike_PWM_Sinev2.xlsx';
% file name of step input data
fname_step = 'EncoderForMike_PWM_45.xlsx';

% read in data from excel spreadsheet
dat_sine = readtable(fname_sine);
dat_step = readtable(fname_step);

% extract quantities (sine)
time_sine = dat_sine{:,2};  % time vector
dc_sine = dat_sine{:,1};    % duty cycle vector
enc_sine = dat_sine{:,3};   % encoder counts
pos_sine = dat_sine{:,4};   % position (in radians)

% interpolate data to sample at equal time intervals
time_unisin = 0:.01:max(time_sine)-8; % crop data to relevant time window
pos_unisin = interp1(time_sine,pos_sine,time_unisin);
pos_unisin(1:2) = 0; % get rid of NaN initial values

% extract quantities (step)
time_step = dat_step{:,2};  % time vector
dc_step = 0.45*ones(size(time_step));    % duty cycle vector
dc_step(time_step<=1) = 0;
enc_step = dat_step{:,3};   % encoder counts
pos_step = dat_step{:,4};   % position (in radians)

% interpolate data to sample at equal time intervals
time_unistep = 0:.01:max(time_step);
pos_unistep = interp1(time_step,pos_step,time_unistep);
pos_unistep(1:2) = 0;


%% Establish motor model parameters

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

% controller parameters (initialized to zero for comparison to open loop)
cntrlprms.despos = 0;
cntrlprms.Kp = 0;
cntrlprms.Ki = 0;
cntrlprms.Kd = 0;

% Simulate model with sine input and compare to experimental data

% initial conditions
theta0 = 0; % position
dtheta0 = 0; % angular velocity
i0 = 0; % initial current
q0 = [theta0;dtheta0;i0;0]; % initial state vector


% integrate EOM
motorParams.case = 1; % (for testing/development) case one, sinusoidal input
[~,Q_sin] = ode45(@MotDynHF,time_unisin,q0,[],motorParams,cntrlprms);


% plot result
fig = figure(1); clf
ax1 = subplot(2,1,1);
plot(ax1,time_unisin,Q_sin(:,1))
set(ax1,'NextPlot','add')
plot(ax1,time_unisin,pos_unisin)
xlabel('Time (s)')
ylabel('Orientation (rad)')
title('Simulation vs. Experiment')
set(ax1,'XLim',[0 40],'YLim', [0 45])
legend('Simulation','Experimental Data')
ax2 = subplot(2,1,2);
plot(ax2,time_unisin,Q_sin(:,2))
xlabel('Time (s)')
ylabel('speed (rad/s)')
% subplot(3,1,3)
% plot(time_unisin,Q(:,3))
% xlabel('Time (s)')
% ylabel('current (amp)')


% Simulate model with step input and compare to experimental data


% initial conditions
theta0 = 0; % position (rad)
dtheta0 = 0; % angular velocity (rad/s)
i0 = 0; % amps
q0 = [theta0;dtheta0;i0;0];


% integrate EOM
motorParams.case = 2; % (for testing/development) case one, sinusoidal input
cntrlprms.stepPWM = 0.45;
[~,Q_step] = ode45(@MotDynHF,time_unistep,q0,[],motorParams,cntrlprms);


% plot result
fig2 = figure(2); clf
axa = subplot(2,1,1);
plot(axa,time_unistep,Q_step(:,1))
set(axa,'NextPlot','add')
plot(axa,time_unistep,pos_unistep)
xlabel('Time (s)')
ylabel('Orientation (rad)')
title('Simulation Result')
set(axa,'XLim',[0 6],'YLim',[0 15])
legend('Simulation','Experimental Data')
axb = subplot(2,1,2);
plot(axb,time_unistep,Q_step(:,2))
xlabel('Time (s)')
ylabel('speed (rad/s)')
% subplot(3,1,3)
% plot(t,Q(:,3))
% xlabel('Time (s)')
% ylabel('current (amp)')

%% Test out a controller on the motor model

% configure control parameters
cntrlprms.despos = pi/4;
cntrlprms.Kp = .4;
cntrlprms.Ki = 0.1;
cntrlprms.Kd = 0.1;


% initial condition
theta0 = 0;
dtheta0 = 0;
i0 = 0;
q0 = [theta0;dtheta0;i0;0];

% simulation time array
t = 0:.1:10;

% integrate EOM
motorParams.case = 3;
[~,Q_cl] = ode45(@MotDynHF,t,q0,[],motorParams,cntrlprms);


% plot results
fig3 = figure(3); clf
plot(t,Q_cl(:,1))
hold on
plot(t,cntrlprms.despos*ones(size(t)),'--r')
legend('Closed-loop Response', 'Desired Position')
xlabel('Time (s)')
ylabel('Orientation (rad)')



%% Optimize parameters based on both trials (not working!)

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


