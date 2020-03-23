function dQ = MotDynHF(t,Q,params,cntrlprms)
%MotDynHF simulates high fidelity dynamics of a DC motor. The model
%includes nonlinear input deadzone and Stribeck Friction.
%   INPUTS:
%       t: time, scalar value for current time of integration
%       Q: 4x1 dimensional state vector at time t, Q = [position; velocity;
%       current; error integral]
%       params: data structure containing motor parameters
%           params.Ra: motor armature resistance (Ohms)
%           params.La: motor armature inducatnce (H)
%           params.Bm: coefficient of linear friction (Nm*s/rad)
%           params.Km: transducer constant (Nm*s/rad) (amp*H/rad)
%           params.J: moment of inertia (Kg*m^2)
%           params.friction.a0: positive spin static friction (Nm)
%           params.friction.a1: positive spin coulumb friction coefficient (Nm)
%           params.friction.a2: speed decay constant on coulumb friction (unitless
%           params.friction.a3: negative spin static friction (Nm)
%           params.friction.a4: negative spin coulumb friction coefficient
%           params.friction.a5: speed decay constant on coulumb friction
%           params.friction.del: approximation of stiction range (rad/s)
%           params.dzone.pos: dead zone for positive inputs (duty cycle)
%           params.dzone.neg: dead zone for negative inputs (duty cycle)
%           params.case: operational case to simulate
%                       1 = sinusoidal input, amplitude 1, period 10 second
%                       2 = step input, user-specified magnitude (0-1),
%                       step input is applied at t=1.0 second
%                       3 = closed loop control
%            
%       cntrlprms: data structure containing operational mode (open- or closed-loop)
%                  and parameters of operation (PID control gains or
%                  open-loop step input duty cycle)
%           cntrlprms.mode: operational mode ('open' or 'closed')
%           cntrlprms.despos: desired position (rad)
%           cntrlprms.Kp: proportional gain
%           cntrlprms.Ki: integral gain
%           cntrlprms.Kd: derivative gain
%           cntrlprms.stepPWM: duty cycle magnitude of step input (0-1)
%   OUTPUT:
%       dQ: 4x1 derivative of state vector Q at time t
%
%   Example Usage: (open-loop sine wave input)
%       motorParams.Ra = 5; % Armature resistance (Ohms)
%       motorParams.La = 0.2*10^-1; % Armature inductance (H) (~10^-3)
%       motorParams.Bm = .027; % coefficient of friction (Nm*s/rad)
%       motorParams.Km = .95; % transducer constant (Nm*s/rad) (amp*H/rad)
%       motorParams.J = 0.15*10^0; % moment of inertial
%       motorParams.friction.a0 = 0.15; % positive spin static friction (Nm)
%       motorParams.friction.a1 = 0.25; % positive spin coulumb friction coefficient
%       motorParams.friction.a2 = 1.3; % speed decay constant on coulumb friction 
%       motorParams.friction.a3 = .36; % negative spin static friction (Nm)
%       motorParams.friction.a4 = 0.25; % negative spin coulumb friction coefficient
%       motorParams.friction.a5 = 1; % speed decay constant on coulumb friction
%       motorParams.friction.del = 0.05; % rad/s "linear zone" of friction
%       motorParams.dzone.pos = 0.25; % ten percent duty cycle on positive side 0.25 comes from trials 
%       motorParams.dzone.neg = 0.25; % twenty percent on negative side 0.25 comes from trials
%       cntrlprms.despos = 0;
%       cntrlprms.Kp = 0;
%       cntrlprms.Ki = 0;
%       cntrlprms.Kd = 0;
%       cntrlprms.stepPWM = 0.45;
% 
%       % initial conditions
%       t = 0:.01:3;
%       theta0 = 0; % position
%       dtheta0 = 0; % angular velocity
%       i0 = 0; % initial current
%       q0 = [theta0;dtheta0;i0;0]; % initial state vector
%       motorParams.case = 1; % (for testing/development) case one, sinusoidal input
%       [~,Q] = ode45(@MotDynHF,t,q0,[],motorParams,cntrlprms);
%
% L. DeVries, Ph.D., USNA
% EW309, AY2020
% Last edited 3/22/2020



% control input
switch params.case % test cases for simulation 
    case 1 % sinusoidal data, compare to experimental data
        if t<0.45
            dc = 0;
        else
            dc = sin(2*pi/10*t);
        end
        err = 0;
    case 2 % positive step input, compare to experimental data
        if t<1
            dc = 0;
        else
            dc = cntrlprms.stepPWM;
        end
        err = 0;
    case 3 % closed loop control, for students
        err = cntrlprms.despos - Q(1);
 
        % PID controller
        dc = cntrlprms.Kp*err + cntrlprms.Ki*Q(4) - cntrlprms.Kd*Q(2);
        if dc>1.0
            dc = 1.0;
        elseif dc<-1.0
            dc = -1.0;
        end
end

% introduce deadzone here! Use EW305 results to quantify!
if dc<params.dzone.pos && dc>-params.dzone.neg
    dc = 0;
end

% voltage from duty cycle
u = 12*dc;

% motor torque when assuming inductance is negligible
ia = 1/params.Ra*(u-params.Km*Q(2)); % armature current
Tm = params.Km*ia; % torque

% use this motor torque when assuming inductance is not negligible
% Tm = params.Km*Q(3);

% equations of motion (EOM)
dQ(1,1) = Q(2); % dtheta = omega
dQ(2,1) = 1/params.J*(Tm - params.Bm*Q(2) - frictionNL(Q(2),params)); % domega = torques and friction

% electrical circuit EOM (assumes non-negligible inductance) (set to zero
% if ignoring inductance)
dQ(3,1) = 0;%1/params.La*(u - params.Km*Q(2) - params.Ra*Q(3)); % di/dt = circuit equation with inductance

% avoid windup
alp = (err/50).^4; % weighting function approaches zero sharply as error approaches 100 rad*s

dQ(4,1) = (1-alp)*err; % error integral term
end
