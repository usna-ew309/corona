function metric = objFunc(x,params,dat)


params.La = x(1);
params.Bm = x(2);
params.Km = x(3);
params.J = x(4);
params.friction.a0 = x(5);
params.friction.a1 = x(6);

params.case = 1;
[~,Qsin] = ode45(@MotDynHF,dat(1).time,[0;0;0],[],params);
params.case = 2;
[~,Qstep] = ode45(@MotDynHF,dat(2).time,[0;0;0],[],params);

quan1 = (Qsin(:,1)-dat(1).pos').^2;
quan2 = (Qstep(:,1)-dat(2).pos').^2;

qu = [quan1;quan2];
metric = sqrt(mean(qu));

end