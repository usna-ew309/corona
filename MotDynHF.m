function dQ = MotDynHF(t,Q,params)
%MotDynHF simulates high fidelity dynamics of a DC motor. The model
%includes nonlinear input deadzone and Stribeck Friction.
%   TODO: FINISH DOCUMENTATION
%
% state vector: q = [theta; omega; current];


% control input
u = 12*sin(2*pi/3*t);

% introduce deadzone here! Use EW305 results to quantify!
if abs(u)<params.ddzne
    u = 0;
end

% motor torque (generated from current state Q(3))
Tm = params.Km*Q(3);

% equations of motion (EOM)
dQ(1,1) = Q(2); % dtheta = omega
dQ(2,1) = Tm - params.Bm*Q(2) - frictionNL(Q(2),params); % domega = torques and friction
dQ(3,1) = 1/params.La*(u - params.Km*Q(2) - params.Ra*Q(3)); % di/dt = circuit equation with inductance
end


function Tf = frictionNL(omega,params)

% update here with simplified model from EW305 work!
% T1 = (params.a0 + params.a1*exp(-params.a2*abs(omega)))*sgn1(omega);
% T2 = (params.a3 + params.a4*exp(-params.a5*abs(omega)))*sgn2(omega);
% Tf = T1+T2;

% use saturation function with specified up and lower bounds
% T1 = params.a0*omega


% Tf = params.a0*omega;
% 
% if Tf > params.ahigh
%     Tf = params.ahigh;
% end
% 
% if Tf < -params.alow
%     Tf = params.alow;
% end

end

function out = sgn1(omega)
out = ones(size(omega));
out(omega<0) = 0;
end

function out = sgn2(omega)
out = zeros(size(omega));
out(omega<0) = -1;
end