function dQ = MotDynHF(t,Q,params,cntrlprms)
%MotDynHF simulates high fidelity dynamics of a DC motor. The model
%includes nonlinear input deadzone and Stribeck Friction.
%   TODO: FINISH DOCUMENTATION
%
% state vector: Q = [theta; omega; current];


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
        if t<=1
            dc = 0;
        else
            dc = 0.45;
        end
        err = 0;
    case 3 % closed loop control, for students
        err = cntrlprms.despos - Q(1);
 
        % PID controller
        dc = cntrlprms.Kp*err + cntrlprms.Ki*Q(4) + cntrlprms.Kd*(0-Q(2));
end

% introduce deadzone here! Use EW305 results to quantify!
if dc<params.dzone.high && dc>-params.dzone.low
    dc = 0;
end

% voltage from duty cycle
u = 12*dc;

% motor torque (generated from current state Q(3))
% ia = 1/params.Ra*(u-params.Km*Q(2));
% Tm = params.Km*ia;

Tm = params.Km*Q(3);

% equations of motion (EOM)
dQ(1,1) = Q(2); % dtheta = omega
dQ(2,1) = 1/params.J*(Tm - params.Bm*Q(2) - frictionNL(Q(2),params)); % domega = torques and friction

dQ(3,1) = 1/params.La*(u - params.Km*Q(2) - params.Ra*Q(3)); % di/dt = circuit equation with inductance
dQ(4,1) = err; % error integral term
end
