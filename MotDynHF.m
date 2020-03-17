function dQ = MotDynHF(t,Q,params)
%MotDynHF simulates high fidelity dynamics of a DC motor. The model
%includes nonlinear input deadzone and Stribeck Friction.
%   TODO: FINISH DOCUMENTATION
%
% state vector: q = [theta; omega; current];


% control input
if t<0.45
    dc = 0;
else
    dc = 0.45*sin(2*pi/3*t);
end

% introduce deadzone here! Use EW305 results to quantify!
if dc<params.dzone.high && dc>-params.dzone.low
    dc = 0;
end

% voltage from duty cycle
u = 12*dc;

% motor torque (generated from current state Q(3))
Tm = params.Km*Q(3);

% equations of motion (EOM)
dQ(1,1) = Q(2); % dtheta = omega
dQ(2,1) = 1/params.J*(Tm - params.Bm*Q(2) - frictionNL(Q(2),params)); % domega = torques and friction
dQ(3,1) = 1/params.La*(u - params.Km*Q(2) - params.Ra*Q(3)); % di/dt = circuit equation with inductance
end
