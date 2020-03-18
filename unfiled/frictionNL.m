function Tf = frictionNL(omega,params)

Tf = (params.friction.a0 + params.friction.a1)/params.friction.del*omega;

indmd = omega <0 & omega > -params.friction.del;
Tf(indmd) = (params.friction.a3 + params.friction.a4)/params.friction.del*omega(indmd);

indp = omega>=params.friction.del;
Tf(indp) =   params.friction.a0 + params.friction.a1*exp( - (params.friction.a2*abs( omega(indp) - params.friction.del) )) ;

indm = omega <= -params.friction.del;
Tf(indm) = -(params.friction.a3 + params.friction.a4*exp( - (params.friction.a5*abs( omega(indm) + params.friction.del) )));

end