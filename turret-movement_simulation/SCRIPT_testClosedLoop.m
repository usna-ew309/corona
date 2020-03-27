cntrlprms.despos = pi/4;
cntrlprms.Kp = 3;
cntrlprms.Ki = 0.02;
cntrlprms.Kd = 1;
t = 0:.05:10;
[SSE,t,theta,omega,eint] = sendCmdtoDcMotor('closed',cntrlprms,t);

figure(1); clf
plot(t,theta)